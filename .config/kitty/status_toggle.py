# 右ステータスの項目を出す / 隠すを切り替えるキッテン。
#
#     map cmd+shift+t kitten status_toggle.py timemachine
#
# タブバーのクリックには割り当てられない。kitty のタブバーが受け取るマウス操作は
# TabManager.handle_tab_bar_mouse に直書きされていて (タブの選択、ドラッグでの
# 並べ替え、中クリックで閉じる、空き領域のダブルクリックで新しいタブ)、自前で
# 描いた領域にアクションを結び付ける口が無い。ボタンの代わりにキーで叩く。
#
# 隠している間は tab_bar.py が timemachine.text() を呼ばないので、tmutil も走らなく
# なる (poller は呼ばれたときにしか次のコマンドを投げない)。

import sys

from kittens.tui.handler import result_handler
from kitty.constants import config_dir

# 兄弟モジュール (toggles) を import する前に、置いてあるディレクトリを sys.path へ
# 足す。tab_bar.py の冒頭と同じ事情。ただしキッテンは runpy ではなく「ソースを読んで
# exec」で読み込まれるため __file__ が無く (kittens/runner.py の
# import_kitten_main_module)、自分の場所は config_dir から引く。
if config_dir not in sys.path:
    sys.path.insert(0, config_dir)


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    import toggles

    for name in args[1:]:
        toggles.toggle(name)
    # タブバーはイベント駆動でしか描き直されない。時計のタイマー (tab_bar.py の
    # _ensure_timer) でどのみち 1 秒以内に更新されるが、押した手応えが遅れるので
    # ここで dirty にしておく。
    for tm in boss.all_tab_managers:
        tm.mark_tab_bar_dirty()
