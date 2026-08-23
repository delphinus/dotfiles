# タブバーの描画。WezTerm の tab_title.lua + status_bar.lua に相当する。
#
# WezTerm から持ち越さずに済んだもの:
#   - 角丸チップの手描き (半円キャップ) → tab_powerline_style round が素で出す
#   - tab_bar_metrics.lua の幅配分の回避策 → draw_tab() が幅を全部握るので不要
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

# kitty は設定リロード (load_config_file) のたびにこのファイルを読み直すが、
# ここから import する兄弟モジュールは sys.modules に残るため古いままになる。
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

# WezTerm 側は config.colors.ansi[N] (1 始まり) を使っていた。kitty の color0..7 が
# 同じ ANSI パレットなので、ansi[N] は color{N-1} に対応する。
_ANSI = ("color0", "color1", "color2", "color3", "color4", "color5", "color6", "color7")

# キーボードモードの表示色。WezTerm の key_table 表示 (copy_mode / resize_pane /
# search_mode の色分け) に相当する。kitty で自前に持っているのは resize だけ。
MODE_BG = {"resize": 5}


def _color(index):
    """WezTerm の ansi[index] (1 始まり) と同じ色を kitty のパレットから引く。"""
    return as_rgb(int(getattr(get_options(), _ANSI[index - 1])))


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


#: 右ステータス {{{


def _ids(os_window_id):
    """<OS ウィンドウ>:<タブ>:<ペイン>。WezTerm の window_id:tab_id:pane_id と同じ位置付け。"""
    tm = get_boss().os_window_map.get(os_window_id)
    tab = tm.active_tab if tm else None
    window = tab.active_window if tab else None
    return "%s  %d:%d:%d " % (
        WINDOW,
        os_window_id,
        tab.id if tab else 0,
        window.id if window else 0,
    )


def _cells(os_window_id):
    """(テキスト, 前景, 背景) の並び。背景が None なら地の色。左から並ぶ順。"""
    out = [(" ", None, None)]
    text = battery.text()
    if text:
        out.append((text + " ", 3, None))
    text = timemachine.text()
    if text:
        out.append((text + " ", 2, None))
    out.append((_ids(os_window_id), 4, None))
    out.append(("%s  %s " % (CLOCK, time.strftime("%b %e %T")), 5, None))
    mode = get_boss().mappings.current_keyboard_mode_name
    if mode:
        out.append((" %s  %s " % (MODE, mode), 1, MODE_BG.get(mode, 6)))
    return out


def _draw_right_status(draw_data, screen):
    # ここは描画パスなので、例外を投げるとタブバーごと出なくなる。ステータスは
    # 飾りなので、組み立てに失敗したら黙って諦める。
    try:
        cells = _cells(draw_data.os_window_id)
    except Exception:
        return
    # 日本語も nerdfont も 2 桁を占めるので、コードポイント数ではなく表示幅で測る。
    width = sum(wcswidth(c[0]) for c in cells)
    x = screen.columns - width
    if x <= screen.cursor.x:
        # タブが詰まっていて場所が無い。WezTerm では右ステータスが左から黙って
        # 削られていた (tab_bar_metrics.lua の冒頭コメント) が、ここでは出さない。
        return
    screen.cursor.x = x
    # 直前に描いたタブの属性が cursor に残るので明示的に落とす。
    screen.cursor.bold = False
    screen.cursor.italic = False
    default_bg = as_rgb(int(draw_data.default_bg))
    for text, fg, bg in cells:
        screen.cursor.fg = _color(fg) if fg else as_rgb(int(draw_data.inactive_fg))
        screen.cursor.bg = _color(bg) if bg else default_bg
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


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
    prefix = _progress_prefix(tab)
    if prefix:
        # kitty.conf 側のテンプレートを尊重したまま、タイトルの直前へ差し込む。
        draw_data = draw_data._replace(title_template=draw_data.title_template.replace("{title}", prefix + "{title}"))

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
