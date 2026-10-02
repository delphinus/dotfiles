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
#
# codediff (codediff.py) のペインが同じタブにあるときは、stack にすると codediff
# まで隠れてしまうので、隠し方を変える。詳細は aux_panes.py。

import glob
import importlib
import os

from kittens.tui.handler import result_handler

import aux_panes

# kitten は押すたびに exec し直されるが、import した aux_panes は sys.modules に
# 残ったままになる。読み直しておかないと、aux_panes.py を直しても kitty を再起動
# するまで反映されない。
aux_panes = importlib.reload(aux_panes)
from aux_panes import FISH

# バッファのファイル置き場。editprompt バイナリの --mux は tmux と wezterm しか
# 受け付けないため、ここでは通さずに nvim を直接起動する。
#
# ファイル名は必ずウィンドウごとに分ける。固定パスを共有すると、タブごとに開いた
# editprompt が同じファイルを掴み、片方が送信時に書き出したとたん、下書きを持った
# まま裏で待っている側が checktime で W12 (ファイルもバッファも変わった) を出す。
BUFFER_DIR = os.path.expanduser("~/.cache/kitty-editprompt")
BUFFER_GLOB = "prompt-*.md"


def main(args):
    pass


def _prune(boss):
    """生きていないウィンドウのバッファを掃除する。

    ウィンドウ id は kitty を起動し直すと 1 から振り直されるので、放っておくと
    溜まるだけでなく、新しいウィンドウが昔の下書きを掴んでしまう。
    """
    try:
        alive = {w.id for tab in boss.all_tabs for w in tab.windows}
    except Exception:
        # kitty の内部 API が変わっても本題 (editprompt を開く) は止めない。
        return
    for path in glob.glob(os.path.join(BUFFER_DIR, BUFFER_GLOB)):
        name = os.path.basename(path)
        try:
            window_id = int(name[len("prompt-") : -len(".md")])
        except ValueError:
            continue
        if window_id not in alive:
            try:
                os.remove(path)
            except OSError:
                pass


def _spawn(boss, tab, main, codediff):
    os.makedirs(BUFFER_DIR, exist_ok=True)
    _prune(boss)
    # stack のままだと split しても見えないので splits に戻してから開く。
    tab.goto_layout("splits")
    # codediff にフォーカスしているときに押しても、codediff ではなく相方を割る。
    near = [f"--next-to=id:{main.id}", f"--source-window=id:{main.id}"] if main else []
    # nvim を直接起動すると GUI から起動した kitty の貧弱な PATH を継承して
    # deno (denops) や direnv が見つからないので、通常のウィンドウと同じく
    # fish のログインシェル経由で起動して PATH を揃える (open_uri.lua と同じ理由)。
    boss.launch(
        "--location=hsplit",
        *near,
        f"--bias={aux_panes.editprompt_bias(main, codediff) if main else aux_panes.EDITPROMPT_BIAS}",
        "--cwd=current",
        "--var", "editprompt=1",
        "--env", "EDITPROMPT=1",
        "--env", "NVIM_APPNAME=nvim-dev/skkeleton",
        FISH, "-l", "-c",
        # ファイル名は起動したウィンドウ自身の $KITTY_WINDOW_ID で決める。id が
        # 分かるのは起動後なので、kitten 側では組み立てられない。
        f'exec nvim \'+se laststatus=0\' +startinsert "{BUFFER_DIR}/prompt-$KITTY_WINDOW_ID.md"',
    )


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    tab = aux_panes.tab_of(boss, target_window_id) or boss.active_tab
    if tab is None:
        return
    main, editprompt, codediff = aux_panes.find(tab)

    if editprompt is None:
        # 初回。
        _spawn(boss, tab, main, codediff)
    elif main is None:
        # 相方が居ない。editprompt へフォーカスするだけ。
        tab.set_active_window(editprompt)
    elif aux_panes.editprompt_hidden(tab, editprompt):
        aux_panes.show_editprompt(tab, main, editprompt, codediff)
    else:
        aux_panes.hide_editprompt(tab, main, editprompt, codediff)
