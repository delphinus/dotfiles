# WezTerm の keys.lua show_pstree (Cmd-I) を kitty へ移したもの。
# 相方のペインで動いているプロセスツリーを右のペインに開く。
#
# WezTerm では pane の tty しか取れなかったので、`wezterm cli list` の JSON を
# python でこねて tty を引き、`ps -t <tty>` から一番若い PID を選ぶ、という
# 遠回りをしていた。kitty は各ウィンドウの pid をそのまま持っているので不要。

import os

from kittens.tui.handler import result_handler

PSTREE = os.path.expanduser("~/git/github.com/delphinus/dotfiles/bin/simple-pstree")

# WezTerm の size = { Cells = 60 } 相当。splits レイアウトでは新しいウィンドウが
# 取る割合 (%) で指定する。
PSTREE_BIAS = 35


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    tab = boss.tab_for_id(window.tab_id)
    if tab is None:
        return

    # 相方 = 同じタブの、自分でも editprompt でもないウィンドウ。
    sibling = None
    for w in tab.windows:
        if w.id != target_window_id and not w.user_vars.get("editprompt"):
            sibling = w
            break
    if sibling is None:
        return

    # 前面で走っているプロセスがあればそれを、無ければウィンドウのシェルを追う。
    pids = [p["pid"] for p in sibling.child.foreground_processes if p.get("pid")]
    pid = min(pids) if pids else sibling.child.pid
    if not pid:
        return

    boss.launch(
        "--location=vsplit",
        f"--bias={PSTREE_BIAS}",
        "--type=window",
        PSTREE,
        str(pid),
    )
