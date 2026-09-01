# 右ステータスの項目をクリックできるようにする。今のところ押せるのは予定だけで、
# 押すと会議に入る (meeting.open_url)。
#
# kitty のタブバーには、自前で描いた領域にアクションを結び付ける口が無い。受け取る
# マウス操作は TabManager.handle_tab_bar_mouse (kitty の tabs.py) に直書きされていて
# (タブの選択、ドラッグでの並べ替え、中クリックで閉じる、空き領域のダブルクリックで
# 新しいタブ)、設定から差し込む余地は無い。watcher にマウス系のフックは無く、
# mouse_map はターミナルウィンドウ内にしか効かない。0.48.2 で確認した。
# status_toggle.py の冒頭に「割り当てられない」と書いたのはこの話で、そちらは
# キーで叩く方を選んだ。
#
# ここではメソッドごと差し替える。kitty のソースには触らない。tab_bar.py は kitty と
# 同じプロセスで動く素の Python なので、クラスの属性に代入するだけで以降のクリックが
# こちらへ来る (C 側から呼ばれるのは boss.py の Boss.handle_tab_bar_mouse という
# Python のメソッドで、そこから TabManager へ委譲しているだけ)。
#
# ただしこれは公開 API ではない。kitty 側がシグネチャや内部の持ち方を変えれば黙って
# 壊れる。壊れ方を「クリックが効かないだけ」に留めるため、判定は try で囲んで失敗
# したら元の実装へ素通しする。オーバーレイ (meeting_alert.py) の方は run_kitten と
# いう公開アクションだけで動いているので、ここが壊れても知らせは出続ける。

import importlib
import sys

from kitty.fast_data_types import GLFW_MOUSE_BUTTON_LEFT, GLFW_PRESS, GLFW_RELEASE, get_tab_being_dragged

import meeting

# 描いた場所の記録。os_window_id ごとに (開始桁, 終了桁, 名前, payload) の並びで、
# tab_bar.py の _draw_right_status() が描画のたびに入れ替える。
#
# sys の私有キーに置くのは poller や toggles と同じ事情 + もう一つ。差し替えた
# メソッドは最初に読まれた世代のものが残り続けるので、記録をモジュール変数に持つと
# 設定リロードのあと「書く側は新しい世代、読む側は古い世代」になって当たらなくなる。
_spans = sys.__dict__.setdefault("_kitty_status_spans", {})

# 差し替える前の実装の置き場。ここが埋まっていれば二重に差し替えない。
_ORIGINAL = "_kitty_status_click_original"


def record(os_window_id, spans):
    """描いた項目の桁範囲を覚える。描かなかったときは空を入れて当たり判定を消す。"""
    _spans[os_window_id] = spans


def hit(tm, x, y):
    """ピクセル座標にある項目の (名前, payload)。無ければ None。

    換算は kitty の TabBar.tab_id_at() と同じ。あちらはタブの当たり判定で、こちらは
    自前で描いた領域の当たり判定なので、換算だけ借りて表は別に持つ。

    縦置きのタブバー (tab_bar_edge left/right) では桁の並びが変わるので手を出さない。
    """
    bar = tm.tab_bar
    if not bar.laid_out_once or bar.is_vertical:
        return None
    g = bar.window_geometry
    if not (g.left <= x < g.right and g.top <= y < g.bottom):
        return None
    col = (int(x) - g.left) // bar.cell_width
    for start, end, name, payload in _spans.get(tm.os_window_id) or ():
        if start <= col < end:
            return name, payload
    return None


def _join(url):
    # 会議の URL を持たない予定 (対面など) では何もしない。クリックは飲み込むので、
    # ダブルクリックで新しいタブが開くことはない。
    if url:
        meeting.open_url(url)


# 押せる項目と、押したときにすること。ここに無い名前 (時計、バッテリー等) は
# 素通しする。
ACTIONS = {"calendar": _join}


def dispatch(tm, x, y, button, action):
    """自分の領域での左クリックなら処理して True。それ以外は False で kitty に渡す。"""
    if button != GLFW_MOUSE_BUTTON_LEFT or action not in (GLFW_PRESS, GLFW_RELEASE):
        return False
    # タブをドラッグしている最中の離しは、こちらの領域で起きても kitty に渡す。
    # 掴んだタブが行き場を失う。
    if get_tab_being_dragged()[1]:
        return False
    found = hit(tm, x, y)
    if found is None:
        return False
    handler = ACTIONS.get(found[0])
    if handler is None:
        return False
    # 押した時点では何もしないが、kitty にも渡さない。渡すと press と release が
    # 揃って「空き領域のダブルクリック = 新しいタブ」に数えられてしまう。
    if action == GLFW_RELEASE:
        handler(found[1])
    return True


def install():
    """TabManager.handle_tab_bar_mouse を差し替える。二度目以降は何もしない。"""
    from kitty.tabs import TabManager

    if sys.__dict__.get(_ORIGINAL):
        return
    original = TabManager.handle_tab_bar_mouse
    sys.__dict__[_ORIGINAL] = original

    def handle_tab_bar_mouse(self, x, y, button, modifiers, action):
        # 呼ぶたびにモジュールを引き直す。この関数自体は最初に読まれた世代のものが
        # 残り続けるので、そうしないと status_click.py を直しても ⌘⇧R で反映され
        # ない (tab_bar.py の _redraw_tab_bar と同じ事情)。
        try:
            if importlib.import_module("status_click").dispatch(self, x, y, button, action):
                return
        except Exception:
            pass
        original(self, x, y, button, modifiers, action)

    TabManager.handle_tab_bar_mouse = handle_tab_bar_mouse
