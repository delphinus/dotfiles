# WezTerm の keys.lua toggle_editprompt (Cmd-e) を kitty へ移した PoC。
#
# WezTerm では相方 (Claude Code) のペインを zoom して editprompt を覆い隠して
# いた。kitty に zoom は無いが、stack レイアウトが「アクティブなウィンドウだけを
# 表示する」ので同じ体験になる。
#
#   隠す: 相方へフォーカス → stack へ
#   出す: splits へ戻す → editprompt へフォーカス
#
# ウィンドウの所属は一切動かさない。WezTerm で MuxPane:move_to_new_window と
# move-pane-to-new-tab がどちらもクラッシュした件と同じ方針を踏襲する。
#
# no-UI kitten (画面を奪わずに Boss を触るだけ) として動く。WezTerm の
# wezterm.action_callback に相当する仕組み。

import os

from kittens.tui.handler import result_handler

# editprompt ウィンドウが取る割合 (%)。WezTerm の size = { Cells = 10 } に対し、
# 80 行のウィンドウで概ね同じ高さになる値。
EDITPROMPT_BIAS = 15

# PoC ではバッファのファイルを固定パスに置く。editprompt バイナリの --mux は
# tmux と wezterm しか受け付けないため、ここでは通さずに nvim を直接起動する
# (Phase 3 で「editprompt に kitty 対応を入れる」か「外す」かを決める)。
BUFFER = os.path.expanduser("~/.cache/kitty-editprompt/prompt.md")

FISH = "/opt/homebrew/bin/fish"


def main(args):
    pass


def _find(tab):
    """タブ内の editprompt ウィンドウと相方を返す。"""
    editprompt = sibling = None
    for window in tab.windows:
        if window.user_vars.get("editprompt"):
            editprompt = window
        elif sibling is None:
            sibling = window
    return editprompt, sibling


def _spawn(boss, tab):
    os.makedirs(os.path.dirname(BUFFER), exist_ok=True)
    open(BUFFER, "a").close()
    # stack のままだと split しても見えないので splits に戻してから開く。
    tab.goto_layout("splits")
    # nvim を直接起動すると GUI から起動した kitty の貧弱な PATH を継承して
    # deno (denops) や direnv が見つからないので、通常のウィンドウと同じく
    # fish のログインシェル経由で起動して PATH を揃える (open_uri.lua と同じ理由)。
    boss.launch(
        "--location=hsplit",
        f"--bias={EDITPROMPT_BIAS}",
        "--cwd=current",
        "--var", "editprompt=1",
        "--env", "EDITPROMPT=1",
        "--env", "NVIM_APPNAME=nvim-dev/skkeleton",
        FISH, "-l", "-c",
        f"exec nvim '+se laststatus=0' +startinsert {BUFFER}",
    )


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    tab = boss.active_tab
    if tab is None:
        return
    editprompt, sibling = _find(tab)

    if editprompt is None:
        # 初回。
        _spawn(boss, tab)
    elif sibling is None:
        # 相方が居ない。editprompt へフォーカスするだけ。
        tab.set_active_window(editprompt)
    elif tab.current_layout.name == "stack":
        # 隠れている → 出して editprompt へフォーカスする。
        tab.goto_layout("splits")
        tab.set_active_window(editprompt)
    else:
        # 出ている → 相方をアクティブにしてから stack にして覆い隠す。
        # 順序が要る。stack はアクティブなウィンドウを映すので、先に相方へ
        # 移しておかないと editprompt が映ったままになる。
        tab.set_active_window(sibling)
        tab.goto_layout("stack")
