# Claude Code の下に codediff.nvim のペインを出す。
#
# Claude Code 本体の diff パネル (/diff) は claude を起動したディレクトリの git
# しか見ないので、別の場所に作った worktree で作業していると空のままになる。
# codediff.nvim はカレントディレクトリのリポジトリを監視して変更に追従するので、
# 編集されたファイルのリポジトリで nvim を起動すれば、どこで作業していても映る。
#
# 呼び出し方は 2 通り。
#
#   ⌘D (toggle): 出ていれば閉じ、出ていなければ開く。
#   フック (auto <root>): Claude Code がファイルを変更したあと (Write / Edit の
#       ほか Bash も)、そのリポジトリのルートを渡して呼ぶ
#       (bin/claude-codediff-hook)。まだ出ていなければ開く。別のリポジトリを
#       映していれば開き直す。
#
# ⌘D や :qa で閉じたら、同じリポジトリのあいだはフックで開き直さない (相方の
# user var codediff_off に覚えておく)。別のリポジトリを編集したら、また開く。
#
# 隠すのではなく閉じる。codediff は git の状態を映しているだけなので、開き直しても
# 失うものが無い。editprompt と違い、隠すための仕掛けも要らない。
#
# no-UI kitten として動く。フックからは `kitten @ action --self` で
# 呼ぶので、target_window_id は Claude Code のウィンドウになる ($KITTY_WINDOW_ID を
# 受け継いでいるため)。--match を使うと、指定したウィンドウではなくアクティブな
# ウィンドウが渡ってくる。

import importlib
import subprocess

from kittens.tui.handler import result_handler
from kitty.launch import launch, parse_launch_args

import aux_panes

# kitten は押すたびに exec し直されるが、import した aux_panes は sys.modules に
# 残ったままになる。読み直しておかないと、aux_panes.py を直しても kitty を再起動
# するまで反映されない。
aux_panes = importlib.reload(aux_panes)
from aux_panes import CODEDIFF_VAR, FISH

# codediff ペインが取る高さの割合 (%)。
CODEDIFF_BIAS = 50

# 相方に付ける user var。
#   ROOT_VAR: フックが最後に渡してきたリポジトリ。⌘D で開くときに使う。
#   OFF_VAR: 手で閉じたリポジトリ。フックはこれと同じリポジトリなら開かない。
ROOT_VAR = "codediff_root"
OFF_VAR = "codediff_off"


def main(args):
    pass


def _git_root(path):
    try:
        out = subprocess.run(
            ["git", "-C", path, "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if out.returncode != 0:
        return None
    return out.stdout.strip() or None


def _root_for(main):
    """⌘D で開くときのリポジトリ。フックが教えてくれたものを優先する。

    どちらも git リポジトリでなければ None。codediff は git リポジトリでないと
    何も開かず、素の nvim が残るだけになる。
    """
    root = main.user_vars.get(ROOT_VAR)
    if root:
        return root
    return _git_root(main.cwd_of_child or main.child.cwd)


def _notify(message):
    # paste.py の _notify と同じ理由で osascript を使う。
    try:
        subprocess.Popen(
            ["osascript", "-e", f'display notification "{message}" with title "codediff"'],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except OSError:
        pass


def _spawn(boss, tab, main, editprompt, root):
    prev = tab.active_window
    # editprompt が stack で隠れていたら、splits に戻すときに 1 行に縮める隠し方へ
    # 移し替える。そうしないと splits に戻したとたん editprompt が現れる。
    editprompt_was_hidden = editprompt is not None and aux_panes.editprompt_hidden(tab, editprompt)
    tab.goto_layout("splits")

    opts, args = parse_launch_args([
        "--location=hsplit",
        f"--next-to=id:{main.id}",
        f"--cwd={root}",
        "--var", f"{CODEDIFF_VAR}={root}",
        # フックは Claude Code が裏のタブで動いているときにも来る。手元の作業から
        # フォーカスを奪わない。
        "--keep-focus",
        # :CodeDiffWatch は nvim の設定 (lua/codediff_watch.lua) で足したもの。素の
        # :CodeDiff は変更が無いと何も開かず、その後の変更も追わない。比べる相手は
        # デフォルトブランチとの分岐点なので、コミット済みの変更も残る。! で起動時の
        # 空のタブを閉じる。
        FISH, "-l", "-c", "exec nvim '+CodeDiffWatch!'",
    ])
    codediff = launch(boss, opts, args, target_tab=tab)
    if codediff is None:
        return

    # 相方を割っただけなので、editprompt があると相方と editprompt の間に挟まる。
    # 画面の下端いっぱいへ移してから高さを決める。
    tab.set_active_window(codediff)
    tab.layout_action("move_to_screen_edge", ["bottom"])
    tab.layout_action("bias", [str(CODEDIFF_BIAS)])

    if editprompt_was_hidden:
        aux_panes.squeeze_editprompt(tab, editprompt)
        if prev is editprompt:
            prev = main
    elif editprompt is not None and not editprompt.user_vars.get(aux_panes.EDITPROMPT_SQUEEZED_VAR):
        aux_panes.resize_editprompt(tab, main, editprompt, codediff)
    tab.set_active_window(prev if prev is not None else main)


def _close(boss, tab, main, editprompt, codediff):
    main.user_vars[OFF_VAR] = codediff.user_vars.get(CODEDIFF_VAR, "")
    if tab.active_window is codediff:
        tab.set_active_window(main)
    # editprompt を 1 行に縮めて隠していたなら、codediff が居なくなったあとは
    # 従来どおり stack で隠す形へ戻す。
    # どちらも codediff が抜けたあとの高さで測るので、codediff は渡さない。
    if editprompt is not None:
        if editprompt.user_vars.get(aux_panes.EDITPROMPT_SQUEEZED_VAR):
            aux_panes.unsqueeze_editprompt(tab, main, editprompt, None)
            aux_panes.hide_editprompt(tab, main, editprompt, None)
        else:
            aux_panes.resize_editprompt(tab, main, editprompt, None)
    boss.mark_window_for_close(codediff)


def _replace(boss, tab, main, editprompt, codediff, root):
    """別のリポジトリを映している codediff を閉じて、root で開き直す。

    _close は通さない。手で閉じたのではないので OFF_VAR を書いてはいけない。
    書くと、元のリポジトリに戻ってきたときにフックが開き直さなくなる。
    watcher.py の on_close も codediff の user var を見て OFF_VAR を書き、
    editprompt を stack で隠す形へ戻そうとするので、閉じる前に外しておく。
    """
    codediff.user_vars.pop(CODEDIFF_VAR, None)
    if tab.active_window is codediff:
        tab.set_active_window(main)
    boss.mark_window_for_close(codediff)
    _spawn(boss, tab, main, editprompt, root)


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    tab = aux_panes.tab_of(boss, target_window_id)
    if tab is None:
        return
    main, editprompt, codediff = aux_panes.find(tab)
    if main is None:
        return
    mode = args[1] if len(args) > 1 else "toggle"

    if mode == "auto":
        if len(args) < 3 or not args[2]:
            return
        root = args[2]
        main.user_vars[ROOT_VAR] = root
        if main.user_vars.get(OFF_VAR) == root:
            return
        if codediff is None:
            _spawn(boss, tab, main, editprompt, root)
        elif codediff.user_vars.get(CODEDIFF_VAR) != root:
            _replace(boss, tab, main, editprompt, codediff, root)
        return

    if codediff is not None:
        _close(boss, tab, main, editprompt, codediff)
    else:
        root = _root_for(main)
        if root is None:
            _notify("git リポジトリが見つかりません。Claude Code がファイルを編集すると、そのリポジトリで開きます。")
            return
        main.user_vars.pop(OFF_VAR, None)
        _spawn(boss, tab, main, editprompt, root)
