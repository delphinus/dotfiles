# 会議が始まったことを知らせるオーバーレイ。
#
#     kitten meeting_alert.py <開始 epoch> <終了 epoch> <URL または ""> <予定名>
#
# meeting.tick() が毎秒のタイマーから起動する。手で試すなら:
#
#     kitten meeting_alert.py 0 0 https://meet.google.com/aaa-bbbb-ccc テスト
#
# UI を持つキッテンはアクティブなウィンドウに重なるオーバーレイとして開く
# (kitty の boss.py: run_kitten_with_metadata が overlay_window を作る)。新しい
# タブを開くのに比べて:
#   - 今読んでいる画面がそのまま覆われるので、目を逸らす力が強い
#   - 打ちかけのキーはこのキッテンが飲み込む。シェルに流れ込まない
#   - 閉じれば元の画面に戻る。片付けるタブが残らない
#
# ただし何かのキーで消えると、気付かないまま閉じてしまいかねない。受け付けるのは
# Enter (参加) と Esc / q (閉じる) だけにして、それ以外は握り潰す。
#
# キーの行はクリックでも押せる。マウスを掴むと選択やリンクの ctrl+クリックが効かな
# くなるが、読み上げて閉じるだけの画面なので惜しくない。

import sys
import time

from kittens.tui.handler import Handler, result_handler
from kittens.tui.loop import Loop, MouseButton
from kittens.tui.operations import MouseTracking, styled
from kitty.constants import config_dir
from kitty.fast_data_types import wcswidth
from kitty.key_encoding import EventType

# キッテンは runpy ではなくソースを読んで exec する形で読み込まれるため __file__ が
# 無い (kittens/runner.py の import_kitten_main_module)。兄弟モジュールを import
# する前に、置いてある場所を config_dir から引いて sys.path へ足す。
# status_toggle.py の冒頭と同じ事情。
if config_dir not in sys.path:
    sys.path.insert(0, config_dir)

import meeting  # noqa: E402

ICON = "\U000f00f0"  # md-calendar_clock。右ステータスの予定と同じもの


def _hhmm(at):
    return time.strftime("%H:%M", time.localtime(at))


def _span(secs):
    """gcal.py の右ステータスと同じ形。"""
    minutes = int(max(secs, 0) // 60)
    if minutes < 60:
        return "%d分" % minutes
    return "%d:%02d" % (minutes // 60, minutes % 60)


class Alert(Handler):
    # ボタン (press + release) だけ受け取る。移動やドラッグは要らない。
    mouse_tracking = MouseTracking.buttons_only

    def __init__(self, at, until, url, summary):
        self.at = at
        self.until = until
        self.url = url
        self.summary = summary
        # Enter を押されたときだけ URL を返す。main() の戻り値がそのまま
        # handle_result に渡る。
        self.chosen = None
        self.done = False
        # 行番号 → (左端, 右端, 押されたときの処理)。draw_screen が毎回作り直す。
        # 中央寄せなのでウィンドウの大きさで動く。描いた場所をそのまま覚えるのが
        # 確実で、当たり判定を別に計算し直すと画面とずれる。
        self.hits = {}

    def initialize(self):
        self.cmd.set_cursor_visible(False)
        self.cmd.set_line_wrapping(False)
        self.draw_screen()
        self._tick()

    def finalize(self):
        self.done = True
        self.cmd.set_cursor_visible(True)

    def _tick(self):
        """残り時間を毎秒書き換える。閉じずに置いておいても数字が古くならない。"""
        if self.done:
            return
        self.draw_screen()
        try:
            self.asyncio_loop.call_later(1, self._tick)
        except Exception:
            pass

    def on_resize(self, new_size):
        super().on_resize(new_size)
        self.draw_screen()

    def on_key(self, key_event):
        if key_event.type is EventType.RELEASE:
            return
        if key_event.matches("enter") or key_event.matches("kp_enter"):
            self.join()
        elif key_event.matches("esc"):
            self.close()

    def on_text(self, text, in_bracketed_paste=False):
        if text.lower() == "q":
            self.close()

    def on_click(self, mouse_event):
        # 中ボタンの貼り付けや右クリックで会議に入ってしまわないよう、左だけ見る。
        if not mouse_event.buttons & MouseButton.LEFT:
            return
        hit = self.hits.get(mouse_event.cell_y)
        if hit and hit[0] <= mouse_event.cell_x < hit[1]:
            hit[2]()

    def join(self):
        self.chosen = self.url or None
        self.close()

    def on_interrupt(self):
        self.close()

    def on_eot(self):
        self.close()

    def close(self):
        self.done = True
        self.quit_loop(0)

    #: 描画 {{{

    def draw_screen(self):
        if self.done:
            return
        self.cmd.clear_screen()
        lines = self._lines()
        self.hits = {}
        top = max(0, (self.screen_size.rows - len(lines)) // 2)
        for _ in range(top):
            self.print()
        for row, (plain, rendered, action) in enumerate(lines, top):
            # styled() が挟むエスケープは幅を持たないので、余白は素のテキストで測る。
            width = wcswidth(plain)
            left = max(0, (self.screen_size.cols - width) // 2)
            self.print(" " * left + rendered)
            if action is not None:
                self.hits[row] = (left, left + width, action)

    def _lines(self):
        """(素のテキスト, 描くもの, クリックで起きること) の並び。"""
        head = "  %s  会議が始まりました  " % ICON
        when = "%s – %s" % (_hhmm(self.at), _hhmm(self.until))
        left = "残り %s" % _span(self.until - time.time())
        out = [
            (head, styled(head, fg="red", bold=True, reverse=True), None),
            ("", "", None),
            (self.summary, styled(self.summary, bold=True), None),
            ("%s  %s" % (when, left), styled(when, dim=True) + "  " + styled(left, fg="yellow"), None),
            ("", "", None),
        ]
        # キーの行は行まるごとを当たり判定にする。"Enter" の 5 桁を狙わせるより、
        # 説明ごと押せたほうが速い。
        if self.url:
            tail = "  参加する (%s)" % meeting.label(self.url)
            out.append(("Enter" + tail, styled("Enter", fg="green", bold=True) + tail, self.join))
        out.append(("Esc    閉じる", styled("Esc", fg="blue", bold=True) + "    閉じる", self.close))
        return out

    #: }}}


def main(args):
    try:
        at, until, url = int(args[1]), int(args[2]), args[3]
        summary = " ".join(args[4:]) or "(名称未設定)"
    except (IndexError, ValueError):
        return None
    handler = Alert(at, until, url, summary)
    Loop().loop(handler)
    return handler.chosen


@result_handler()
def handle_result(args, answer, target_window_id, boss):
    # 会議を開くのは kitty のプロセス側。キッテンのプロセスから投げると、
    # オーバーレイが閉じるときに道連れにされうる (meeting.open_url 参照)。
    if answer:
        meeting.open_url(answer)
