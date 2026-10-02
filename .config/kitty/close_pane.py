# WezTerm の keys.lua close_pane (Cmd-W) を kitty へ移したもの。
#
# kitty の cmd+w は既定が close_tab で、ペイン 1 枚のつもりで押すとタブごと消える。
# WezTerm と同じ「いまのペインだけ閉じる」に戻す。確認ダイアログは出さない
# (WezTerm 側も CloseCurrentPane { confirm = false } だった)。
#
# あわせて、Claude Code 側を閉じるときは補助ペイン (editprompt / codediff) も
# 道連れにする。補助ペインだけ残るとタブが消えず、閉じるのに何度も押す羽目になる
# ため。残りが全部補助ペインのときだけにして、自分で足した別のペインがあるときは
# 巻き添えにしないようにする。

import importlib

from kittens.tui.handler import result_handler

import aux_panes

# 理由は editprompt.py の同じ箇所を参照。
aux_panes = importlib.reload(aux_panes)


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    tab = boss.tab_for_id(window.tab_id)
    if tab is not None:
        others = [w for w in tab.windows if w.id != target_window_id]
        if not aux_panes.is_aux(window) and others and all(aux_panes.is_aux(w) for w in others):
            for w in others:
                boss.mark_window_for_close(w)
    boss.mark_window_for_close(window)
