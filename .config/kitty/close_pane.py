# WezTerm の keys.lua close_pane (Cmd-W) を kitty へ移したもの。
#
# kitty の cmd+w は既定で close_tab で、ペイン 1 枚のつもりで押すとタブごと消える。
# WezTerm と同じ「いまのペインだけ閉じる」に戻す。確認ダイアログは出さない
# (WezTerm 側も CloseCurrentPane { confirm = false } だった)。
#
# あわせて、Claude Code 側を閉じるときは editprompt も道連れにする。片方だけ残ると
# タブが消えず、閉じるのに 2 回押す羽目になるため。ウィンドウがちょうど 2 枚の
# ときだけにして、自分で足した 3 枚目を閉じただけで巻き添えにしないようにする。

from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    tab = boss.tab_for_id(window.tab_id)
    if tab is not None:
        windows = list(tab.windows)
        if len(windows) == 2:
            for w in windows:
                if w.id != target_window_id and w.user_vars.get("editprompt"):
                    boss.mark_window_for_close(w)
    boss.mark_window_for_close(window)
