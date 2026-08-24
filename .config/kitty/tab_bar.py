# タブバーの描画。WezTerm の tab_title.lua + status_bar.lua に相当する。
#
# WezTerm から持ち越さずに済んだもの:
#   - 角丸チップの手描き (半円キャップ) → tab_powerline_style round が素で出す
#   - tab_bar_metrics.lua の publish/参照の二段構え → draw_tab() が幅を全部握るので不要
#     (右ステータスのぶんを予約する話自体は要る。_tab_length() 参照)
#   - claude_state のタブ着色 → `kitten @ set-tab-color` で外から塗れるので不要
#
# 落とした表示 (kitty に対応する概念が無い):
#   - SSH ドメイン名 … kitty に mux ドメインが無い (リモートは kitten ssh + tmux)
#   - is_tardy の遅延表示 … mux クライアントの応答遅れを示す WezTerm 固有の指標

import os
import sys
import time

# このファイルは kitty から runpy.run_path で実行される。run_path は対象ファイルの
# ディレクトリを sys.path に足さないので、兄弟モジュールを import する前に自分で
# 足す。これを忘れると ImportError になり、kitty は例外を握り潰して既定の
# draw_tab_with_fade に落ちる (タブバーが黙って素の見た目に戻る)。
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# kitty は設定リロード (load_config_file) のたびにこのファイルを読み直す。ただし
# 反映は 1 回遅れる: リロードは「タブバーへ描画関数を割り当てる (apply_new_options)」
# → 「custom tab bar のキャッシュを捨てる (tab_bar.clear_caches)」の順に動くので、
# 1 回目はキャッシュに残っていた古いモジュールが割り当たり、2 回目でようやく新しい
# ものが使われる。このファイルを直したら kitten @ load-config を 2 回叩くこと
# (cmd+shift+r は keys.conf 側で 2 回叩くように combine してある)。
#
# 読み直しに際して、ここから import する兄弟モジュールは sys.modules に残るため
# 古いままになる。
# battery.py などを直しても反映されない、という分かりにくい状態を避けるため、
# 読み込む前に落としておく。poller も含めて全部落とす。世代の登録簿は poller が
# モジュールの外 (sys の私有キー) に持っているので、読み直しても前の世代の
# スレッドはきちんと止まる。
for _stale in ("battery", "timemachine", "progress_bar", "poller"):
    sys.modules.pop(_stale, None)

import battery  # noqa: E402
import progress_bar  # noqa: E402
import timemachine  # noqa: E402
from kitty.fast_data_types import add_timer, get_boss, get_options, wcswidth  # noqa: E402
from kitty.progress import ProgressState  # noqa: E402
from kitty.tab_bar import as_rgb, draw_tab_with_powerline  # noqa: E402

WINDOW = "\U000f05af"  # md-window_maximize
CLOCK = "\U000f0150"  # md-clock_outline
MODE = "\U000f04eb"  # md-table

# 項目の区切り。地の色より一段明るいだけの細線にして、区切り自体は目立たせない。
SEPARATOR = " │ "

# WezTerm 側は config.colors.ansi[N] (1 始まり) を使っていた。kitty の color0..7 が
# 同じ ANSI パレットなので、ansi[N] は color{N-1} に対応する。brights[N] は color8.. 。
_ANSI = ("color0", "color1", "color2", "color3", "color4", "color5", "color6", "color7")
_BRIGHT = ("color8", "color9", "color10", "color11", "color12", "color13", "color14", "color15")

# キーボードモードの表示色。WezTerm の key_table 表示 (copy_mode / resize_pane /
# search_mode の色分け) に相当する。kitty で自前に持っているのは resize だけ。
MODE_BG = {"resize": 5}

# バッテリーの深刻度に対応する ansi の番号。battery.py は色を知らない。
BATTERY_FG = {"ok": 3, "warn": 4, "critical": 2}

# 右ステータスの項目を落とす順 (小さいものから落ちる)。KEEP は落とさない。
DROP_IDS = 1
DROP_TIMEMACHINE = 2
DROP_BATTERY = 3
KEEP = 99

# 最後のタブと右ステータスの間に必ず残す余白。
GUTTER = 2
# タブをこれ以上は狭めない。ここまで詰まったらステータス側が項目を落とす。
MIN_TAB_LENGTH = 12


def _color(index):
    """WezTerm の ansi[index] (1 始まり) と同じ色を kitty のパレットから引く。"""
    return as_rgb(int(getattr(get_options(), _ANSI[index - 1])))


def _bright(index):
    """WezTerm の brights[index] (1 始まり) と同じ色。"""
    return as_rgb(int(getattr(get_options(), _BRIGHT[index - 1])))


_TIMER_KEY = "_kitty_tab_bar_clock_timer"


def _redraw_tab_bar(_unused_timer_id):
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()


#: タブに差し込む OSC 9;4 の進捗 {{{

BAR_SIZE = 8


def _progress_prefix(tab):
    if not tab.last_focused_window_with_progress_id:
        return ""
    window = get_boss().window_id_map.get(tab.last_focused_window_with_progress_id)
    if window is None:
        return ""
    state = window.progress.state
    if state is ProgressState.unset:
        return ""
    if state is ProgressState.error:
        return "! "
    if state is ProgressState.indeterminate:
        return "~ "
    # 進捗を持つウィンドウが複数あるタブでは平均を出す (kitty の
    # tab.active_progress_percent と同じ計算)。
    if tab.num_of_windows_with_progress > 1:
        percent = tab.total_progress / tab.num_of_windows_with_progress
    else:
        percent = window.progress.percent
    return progress_bar.render(BAR_SIZE, percent / 100) + " "


#: }}}


#: タブ名 {{{


def _title(tab):
    """editprompt にフォーカスしている間も、タブ名を相方 (Claude Code) のものに保つ。

    kitty のタブ名はアクティブなウィンドウのタイトルそのもの (Tab.title は
    active_window の title_changed でしか動かない) なので、⌘E で editprompt へ
    移った瞬間にタブが "fish" になる。editprompt は相方への入力欄でしかないので、
    タブバーには相方のタイトル (Claude Code が出す会話の要約) を出し続けたい。

    相方のタイトルは editprompt に居る間も更新され続ける。タブバーは時計のための
    毎秒の再描画 (_ensure_timer) で dirty になるので、ここで拾い直せば追従する。
    """
    real = get_boss().tab_for_id(tab.tab_id)
    # kitten @ set-tab-title で名前が付いていれば、そちらが窓のタイトルより強い。
    if real is None or real.name:
        return tab.title
    active = real.active_window
    if active is None or not active.user_vars.get("editprompt"):
        return tab.title
    for window in real.windows:
        if window.id != active.id and not window.user_vars.get("editprompt"):
            return window.title
    return tab.title


#: }}}


#: 右ステータス {{{


def _ids(os_window_id):
    """<OS ウィンドウ>:<タブ>:<ペイン>。WezTerm の window_id:tab_id:pane_id と同じ位置付け。"""
    tm = get_boss().os_window_map.get(os_window_id)
    tab = tm.active_tab if tm else None
    window = tab.active_window if tab else None
    return "%s %d:%d:%d" % (
        WINDOW,
        os_window_id,
        tab.id if tab else 0,
        window.id if window else 0,
    )


def _clock():
    """時計。%b はロケールで "8月" になってしまうので使わず、8/24 11:11:32 の形で出す。"""
    return time.strftime("%-m/%d %H:%M:%S")


def _segments(draw_data):
    """左から並べる項目。(優先度, テキスト, 前景) で、幅が足りないと優先度の低い順に落ちる。

    大事なものほど右へ置く。場所が無くなるのは左端 (タブが押してくる側) なので、
    並び順と落ちる順が一致していれば、狭まるにつれて左から素直に減っていく。
    """
    muted = as_rgb(int(draw_data.inactive_fg))
    out = []
    # window:tab:pane は普段使わない補助情報なので、暗い色に落として目を引かせない。
    out.append((DROP_IDS, _ids(draw_data.os_window_id), muted))
    text = timemachine.text()
    if text:
        out.append((DROP_TIMEMACHINE, text, _color(2)))
    status = battery.status()
    if status:
        text, level = status
        out.append((DROP_BATTERY, text, _color(BATTERY_FG[level])))
    out.append((KEEP, "%s %s" % (CLOCK, _clock()), _color(5)))
    return out


def _cells(draw_data, segments):
    """(テキスト, 前景, 背景) の並び。色は解決済みの rgb で、背景 None は地の色。"""
    muted = as_rgb(int(draw_data.inactive_fg))
    out = [(" ", muted, None)]
    for index, (_priority, text, fg) in enumerate(segments):
        if index:
            out.append((SEPARATOR, _bright(1), None))
        out.append((text, fg, None))
    # キーボードモードは状態を強く示すものなので、他と違って背景を塗ったチップにする。
    mode = get_boss().mappings.current_keyboard_mode_name
    if mode:
        out.append((" %s %s " % (MODE, mode), _color(1), _color(MODE_BG.get(mode, 6))))
    out.append((" ", muted, None))
    return out


def _width(cells):
    """日本語も nerdfont も 2 桁を占めるので、コードポイント数ではなく表示幅で測る。"""
    return sum(wcswidth(c[0]) for c in cells)


def _full_width(draw_data):
    """全項目を出したときの桁数。タブ側に空けてもらう幅の目安。"""
    return _width(_cells(draw_data, _segments(draw_data)))


def _fit(draw_data, budget):
    """budget 桁に収まるまで優先度の低い項目を落とした cells。時計すら入らなければ None。"""
    segments = _segments(draw_data)
    while True:
        cells = _cells(draw_data, segments)
        if _width(cells) <= budget:
            return cells
        droppable = [s for s in segments if s[0] != KEEP]
        if not droppable:
            return None
        segments.remove(min(droppable, key=lambda s: s[0]))


def _draw_right_status(draw_data, screen):
    # ここは描画パスなので、例外を投げるとタブバーごと出なくなる。ステータスは
    # 飾りなので、組み立てに失敗したら黙って諦める。
    try:
        cells = _fit(draw_data, screen.columns - screen.cursor.x - GUTTER)
    except Exception:
        return
    if not cells:
        # 時計すら入らない。WezTerm では右ステータスが左から黙って削られて
        # 意味を成さない断片が残っていた (tab_bar_metrics.lua の冒頭コメント) が、
        # ここまで来たら出さない。
        return
    screen.cursor.x = screen.columns - _width(cells)
    # 直前に描いたタブの属性が cursor に残るので明示的に落とす。
    screen.cursor.bold = False
    screen.cursor.italic = False
    default_bg = as_rgb(int(draw_data.default_bg))
    for text, fg, bg in cells:
        screen.cursor.fg = fg
        screen.cursor.bg = bg if bg else default_bg
        screen.draw(text)


#: }}}


def _ensure_timer():
    """時計を進めるための毎秒の再描画タイマーを、kitty のプロセスに 1 本だけ張る。

    kitty はイベント駆動でしかタブバーを描き直さないので、自分から dirty にする
    必要がある (WezTerm の update-status が毎秒呼ばれていたのに相当)。

    張ったかどうかの印はモジュールではなく sys の私有キーに置く。設定リロードの
    たびにこのファイルは読み直されるので、モジュール変数に持つと毎回 None に
    戻り、リロードの回数だけタイマーが積み上がる。GLFW のタイマー表は 128 枠
    しかなく (glfw/backend_utils.c の Timer timers[128])、溢れると add_timer が
    0 を返して kitty 自身のタイマーまで張れなくなる。

    古いタイマーを消して張り直すのではなく「一度だけ張る」ようにしているのは、
    id での削除に頼らないため。コールバックは最初に読まれた世代のものが残るが、
    中身は再描画を促すだけでこのモジュールの他のコードに依存しないので問題ない。
    """
    if sys.__dict__.get(_TIMER_KEY):
        return
    timer_id = add_timer(_redraw_tab_bar, 1.0, True)
    # 0 は「枠が尽きた」の意。記録しないでおけば次の読み込みで再挑戦できる。
    if timer_id:
        sys.__dict__[_TIMER_KEY] = timer_id


def _tab_length(draw_data, screen, max_tab_length):
    """右ステータスの場所を空けるためのタブ幅の上限。WezTerm の tab_bar_metrics.lua 相当。

    kitty はタブ幅を決めるときに右ステータスの領域を予約しない (TabBar.update() は
    columns // タブ数 でしか頭を抑えない) ので、タブが増えるとステータスを描く場所が
    無くなって丸ごと消える。WezTerm と違って draw_tab() がタブ 1 枚の幅を握って
    いるので、実測値を publish して回す必要はなく、ここで絞れば済む。

    draw_tab_with_powerline() はタイトルを削って 1 枚を概ね max_tab_length 桁に
    収めるので、タブ数で割った値をそのまま渡してよい。ただしタブを潰しすぎても
    本末転倒なので MIN_TAB_LENGTH までしか譲らない (そこから先は _fit() が
    優先度の低い項目を落とす)。
    """
    tm = get_boss().os_window_map.get(draw_data.os_window_id)
    count = len(tm.tabs) if tm else 1
    budget = (screen.columns - _full_width(draw_data) - GUTTER) // max(count, 1)
    # 下限も max_tab_length で頭打ちにする。そうしないとタブが極端に多いとき
    # (kitty 側の上限が MIN_TAB_LENGTH を下回るとき) に、場所を空けるはずの
    # この関数がかえってタブを広げてしまう。
    return max(min(max_tab_length, budget), min(MIN_TAB_LENGTH, max_tab_length))


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
    # 採寸パス (for_layout) でも同じ名前にしておく。ここで食い違うと、幅を測った
    # ときと描いたときでタイトルの長さが変わってチップの幅が合わなくなる。
    try:
        tab = tab._replace(title=_title(tab))
    except Exception:
        pass

    prefix = _progress_prefix(tab)
    if prefix:
        # kitty.conf 側のテンプレートを尊重したまま、タイトルの直前へ差し込む。
        draw_data = draw_data._replace(title_template=draw_data.title_template.replace("{title}", prefix + "{title}"))

    # 採寸パス (for_layout) には手を入れない。kitty に本来の理想幅を測らせて
    # おけば、短いタブはそのままの幅で描かれ、ステータスへ回る余白がさらに増える。
    if not extra_data.for_layout:
        try:
            max_tab_length = _tab_length(draw_data, screen, max_tab_length)
        except Exception:
            pass

    end = draw_tab_with_powerline(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data)

    # extra_data.for_layout はタブ幅を測るためだけの空打ち。ここでステータスを
    # 描くとカーソルが行末まで飛び、kitty がそれを最後のタブの「理想の幅」として
    # 採寸してしまう。
    if is_last and not extra_data.for_layout:
        # 長いタイトルは draw_title が一度最後まで書いてから … で上書きするので、
        # チップからはみ出した分が右に残る。kitty はタブを全部描いた後の
        # erase_in_line(0) でそれを消しているが (tab_bar.py の "Ensure no long
        # titles bleed after the last tab")、その時点のカーソルはこちらが
        # ステータスを描き終えた行末付近なので消し残る。先に自分で消す。
        # draw_tab_with_powerline は末尾のスペースを描く前の位置を返すので、
        # ここへ戻すとチップの右端の直後から消せる。消去はカーソルの背景色で
        # 埋まるため、タブの色 (set-tab-color の状態色) が伸びないよう地の色にする。
        screen.cursor.x = end
        screen.cursor.bg = as_rgb(int(draw_data.default_bg))
        screen.erase_in_line(0, False)
        _draw_right_status(draw_data, screen)

    # 右ステータスの分まで返すと最後のタブのクリック範囲がそこまで伸びるので、
    # タブが終わった位置を返す。
    return end


# モジュールの読み込みは設定リロードごとに 1 回なので、ここで張り直す。
_ensure_timer()
