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
#
# 落とした表示 (使っていなかった):
#   - window:tab:pane … タブ番号は tab_title_template の {index} が既にタブチップに
#     出しており、OS ウィンドウ id とペイン id は `kitten @ --match` を手で打つとき
#     にしか要らなかった

import collections
import importlib
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
# 読み込む前に落としておく。poller も含めて全部落とす。ポーラーの状態は poller が
# モジュールの外 (sys の私有キー) に持っているので、読み直しても最後に取れた値と
# 進行中のコマンドはそのまま引き継がれる。toggles も同じ持ち方なので、隠した項目は
# リロードしても隠れたままになる。
for _stale in ("battery", "gcal", "meeting", "running", "timemachine", "progress_bar", "poller", "status_click", "toggles"):
    sys.modules.pop(_stale, None)

import battery  # noqa: E402
import gcal  # noqa: E402
import progress_bar  # noqa: E402
import running  # noqa: E402
import status_click  # noqa: E402
import timemachine  # noqa: E402
import toggles  # noqa: E402
from kitty.fast_data_types import add_timer, get_boss, get_options, wcswidth  # noqa: E402
from kitty.progress import ProgressState  # noqa: E402
from kitty.tab_bar import as_rgb, draw_tab_with_powerline  # noqa: E402

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

# 次の予定の切迫度に対応する ansi の番号。gcal.py は色を知らない。
#
# 開催中 ("now") に緑を当てると左隣のバッテリーと被る。あちらは残量 30% 以上か
# 充電中がずっと緑 (BATTERY_FG の "ok") なので、事実上いつも隣に緑が居ることになる。
# 右ステータスで他に使っていない色は紫だけなので、そこへ逃がす。
CALENDAR_FG = {"later": 7, "now": 6, "soon": 4}

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
    # 会議が始まったらオーバーレイで知らせる (meeting.tick)。描画関数ではなく
    # ここから呼ぶ理由と、タイミングの決め方は向こうのコメントに書いてある。
    #
    # モジュールは呼ぶたびに sys.modules から引き直す。このコールバックは最初に
    # 読まれた世代のものが残り続ける (_ensure_timer) ので、冒頭の import で束縛
    # したものを使うと meeting.py を直しても ⌘⇧R で反映されない。
    #
    # 知らせは飾りなので、失敗しても再描画は止めない。
    try:
        importlib.import_module("meeting").tick()
    except Exception:
        pass
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


def _clock():
    """時計。%b はロケールで "8月" になってしまうので使わず、8/24 11:11:32 の形で出す。"""
    return time.strftime("%-m/%-d %H:%M:%S")


# 右ステータスの一項目。name はクリックの当たり判定に使う名前で、payload は押した
# ときに使う値 (予定なら会議の URL)。何に反応するかは status_click.ACTIONS が決める。
Segment = collections.namedtuple("Segment", "name text fg payload")

# 実際に描く一片。項目のほかに区切り線やモードのチップも混ざるので、それらは
# name を持たない (押しても何も起きない)。
Cell = collections.namedtuple("Cell", "text fg bg name payload")


def _segments(draw_data):
    """左から並べる項目。幅が足りないと左から順に落ちる。

    大事なものほど右へ置く。場所が無くなるのは左端 (タブが押してくる側) なので、
    並び順と落ちる順が一致していれば、狭まるにつれて左から素直に減っていく。
    末尾の時計だけは落とさない (_fit() 参照)。
    """
    muted = as_rgb(int(draw_data.inactive_fg))
    out = []
    # 隠しているあいだは status() を呼ばない。poller は呼ばれたときにしか次のコマンドを
    # 投げないので、これで tmutil ごと止まる (⌘⇧T / status_toggle.py 参照)。
    if toggles.enabled("timemachine"):
        tm = timemachine.status()
        if tm:
            text, state = tm
            # 走っていないときは最後のバックアップ時刻が出ているだけなので、暗い色に
            # 落として目を引かせない。動いている間だけ色を持たせる。
            out.append(Segment("timemachine", text, _color(2) if state == "running" else muted, None))
    # 長く走っているコマンド。外部コマンドを使わないのでトグルは付けていない。
    command = running.status(draw_data.os_window_id)
    if command:
        out.append(Segment("running", command, muted, None))
    status = battery.status()
    if status:
        text, level = status
        out.append(Segment("battery", text, _color(BATTERY_FG[level]), None))
    # 予定も隠しているあいだは google-calendar-cli を走らせない (⌘⇧G)。画面共有で
    # 予定名を映したくないときに落とせる。
    if toggles.enabled("calendar"):
        event = gcal.status()
        if event:
            text, level, chosen = event
            # 押したら会議に入れるよう URL を持たせる。持たない予定 (対面など) では
            # None のままで、その場合クリックは何も起こさない。
            out.append(Segment("calendar", text, _color(CALENDAR_FG[level]), chosen.url))
    out.append(Segment("clock", "%s %s" % (CLOCK, _clock()), _color(5), None))
    return out


def _cells(draw_data, segments):
    """描く一片の並び。色は解決済みの rgb で、背景 None は地の色。"""
    muted = as_rgb(int(draw_data.inactive_fg))
    out = [Cell(" ", muted, None, None, None)]
    for index, segment in enumerate(segments):
        if index:
            out.append(Cell(SEPARATOR, _bright(1), None, None, None))
        out.append(Cell(segment.text, segment.fg, None, segment.name, segment.payload))
    # キーボードモードは状態を強く示すものなので、他と違って背景を塗ったチップにする。
    mode = get_boss().mappings.current_keyboard_mode_name
    if mode:
        out.append(Cell(" %s %s " % (MODE, mode), _color(1), _color(MODE_BG.get(mode, 6)), None, None))
    out.append(Cell(" ", muted, None, None, None))
    return out


def _width(cells):
    """日本語も nerdfont も 2 桁を占めるので、コードポイント数ではなく表示幅で測る。"""
    return sum(wcswidth(cell.text) for cell in cells)


def _full_width(draw_data):
    """全項目を出したときの桁数。タブ側に空けてもらう幅の目安。"""
    return _width(_cells(draw_data, _segments(draw_data)))


def _fit(draw_data, budget):
    """budget 桁に収まるまで左の項目から落とした cells。時計すら入らなければ None。

    _segments() の並び順がそのまま優先度なので、落とす順を別に持たない。項目を
    足すときは並べたい位置に挿すだけでよい。
    """
    segments = _segments(draw_data)
    while True:
        cells = _cells(draw_data, segments)
        if _width(cells) <= budget:
            return cells
        if len(segments) <= 1:
            return None
        segments.pop(0)


def _draw_right_status(draw_data, screen):
    # 何も描かずに戻る道が複数あるので、先に当たり判定を消しておく。残しておくと
    # 前回描いた場所を押したときに反応してしまう。
    status_click.record(draw_data.os_window_id, ())
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
    x = screen.columns - _width(cells)
    screen.cursor.x = x
    # 直前に描いたタブの属性が cursor に残るので明示的に落とす。
    screen.cursor.bold = False
    screen.cursor.italic = False
    default_bg = as_rgb(int(draw_data.default_bg))
    spans = []
    for cell in cells:
        screen.cursor.fg = cell.fg
        screen.cursor.bg = cell.bg if cell.bg else default_bg
        screen.draw(cell.text)
        width = wcswidth(cell.text)
        if cell.name:
            spans.append((x, x + width, cell.name, cell.payload))
        x += width
    # 描いた場所を覚えておく。クリックの当たり判定はこれを見る。
    status_click.record(draw_data.os_window_id, tuple(spans))


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

# 右ステータスをクリックできるようにする。差し替えは一度きりで、二回目以降は
# 何もしない (status_click.install)。
status_click.install()
