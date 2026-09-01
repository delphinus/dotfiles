# 走っている Claude Code のタブを kitty のセッションファイルに書き出しておき、
# 次の起動で復元する。
#
# 退社時に Mac の電源を落とす運用なので、走っている Claude Code は毎晩 kitty ごと
# 死ぬ。会話そのものは transcript に残っていて `claude --resume <id>` で戻せるが、
# 「どのタブがどのプロジェクトの、どの会話だったか」は kitty が忘れてしまう。
# 朝それを並べ直すのが目的。
#
# セッション id はターミナル側からは見えない。フックの JSON にしか出てこないので、
# claude-code-hooks の SessionStart (`claude-code-hooks stamp`) がウィンドウの
# user var claude_session に書き込んでいる。ここはそれを読むだけ。
#
# 復元するのは Claude Code のウィンドウだけにする。理由が 2 つある:
#
#   * editprompt の相方ペインは戻さない。バッファ名がウィンドウ id 由来
#     (editprompt.py の prompt-$KITTY_WINDOW_ID.md) で、id は kitty を起動し直すと
#     1 から振り直される。復元しても中身が噛み合わないうえ、editprompt.py の
#     _prune が「生きていないウィンドウのバッファ」として消しに掛かる。⌘E で
#     張り直せばよい。
#   * nvim やシェルだけのタブも戻さない。何が走っていたかを再現するのは当たらない
#     推測になるし、cwd だけ戻したタブが増えても嬉しくない。

import os
import shlex
import tempfile

from kitty.fast_data_types import (
    NO_CLOSE_REQUESTED,
    add_timer,
    current_application_quit_request,
    get_boss,
)

# claude-code-hooks stamp が書く user var。値は Claude Code のセッション id。
CLAUDE_SESSION_VAR = "claude_session"

# 生成物なので設定ディレクトリ (git 管理下) ではなく state に置く。kitty.conf の
# startup_session が同じパスを指している。
SESSION_FILE = os.path.expanduser("~/.local/state/kitty/session.conf")

# editprompt.py と同じ理由でログインシェルを噛ませる。GUI から起動した kitty の
# PATH には Homebrew が入っておらず、claude を直接 launch しても見つからない。
# -C は「対話セッションに入る前に実行する」ので、claude を抜けても fish が残る。
# exec で置き換えてしまうと、会話を閉じた瞬間にタブごと消えて驚く。
FISH = "/opt/homebrew/bin/fish"

# 書き出しをまとめる間隔 (秒)。タイマーは常に 1 本しか持たない。glfw のタイマー枠は
# 128 本しかなく (tab_bar.py の _redraw_tab_bar に同じ注意書きがある)、イベントごとに
# add_timer すると溢れて以後どのタイマーも動かなくなる。
DEBOUNCE = 10.0

_pending = False


def _claude_window(tab):
    """タブ内の Claude Code ウィンドウと、その session id を返す。無ければ None。"""
    for window in tab.windows:
        session_id = window.user_vars.get(CLAUDE_SESSION_VAR)
        if session_id:
            return window, session_id
    return None


def render(boss):
    """今のレイアウトを kitty のセッションファイルの中身として組み立てる。

    Claude Code のタブが 1 つも無ければ空文字列を返す。
    """
    chunks = []
    for tab in boss.all_tabs:
        found = _claude_window(tab)
        if found is None:
            continue
        window, session_id = found

        # タブ名は付けない。new_tab に名前を渡すとその文字列で固定され、Claude Code
        # が OSC 2 で流してくる会話のタイトルを追わなくなる。人が読む用の手掛かりは
        # コメントで足りる (セッションファイルの # 行は読み飛ばされる)。
        lines = [f"# {tab.title}", "new_tab"]

        cwd = window.cwd_of_child
        if cwd:
            lines.append(f"cd {cwd}")

        # launch の引数だけは kitty 側で展開されず shlex で分割されるので、ここで
        # 引用しておく。
        lines.append(
            "launch "
            + shlex.join([FISH, "-l", "-C", f"claude --resume {session_id}"])
        )
        chunks.append("\n".join(lines))

    if not chunks:
        return ""

    header = (
        "# kitty の startup_session。session_state.py が自動生成する。\n"
        "# 手で編集しても次の書き出しで消える。\n"
    )
    return header + "\n" + "\n\n".join(chunks) + "\n"


def save(boss=None):
    """レイアウトを SESSION_FILE へ書き出す。"""
    # 終了処理中は触らない。⌘Q でも macOS のシャットダウンでも、kitty はウィンドウを
    # 順に閉じてから落ちる。その途中で書くと、減っていく最中のレイアウト (最悪は空)
    # で上書きしてしまい、翌朝復元するものが無くなる。
    if current_application_quit_request() != NO_CLOSE_REQUESTED:
        return

    boss = boss or get_boss()
    try:
        body = render(boss)
    except Exception:
        # kitty の内部 API が変わっても、本業 (ターミナルとして動くこと) は止めない。
        return

    # Claude Code のタブが 1 つも無いときは前回の内容を残す。全部閉じた直後に空で
    # 上書きするより、昨日のタブが余分に復元されるほうが取り返しがつく。
    if not body:
        return

    directory = os.path.dirname(SESSION_FILE)
    try:
        os.makedirs(directory, exist_ok=True)
        # 書き出し中に kitty が落ちても半端なファイルを残さないよう、同じ
        # ファイルシステム上に書いてから rename する。
        fd, tmp = tempfile.mkstemp(dir=directory, prefix=".session-")
        try:
            with os.fdopen(fd, "w") as f:
                f.write(body)
            os.replace(tmp, SESSION_FILE)
        except Exception:
            try:
                os.unlink(tmp)
            except OSError:
                pass
            raise
    except OSError:
        pass


def _flush(timer_id):
    global _pending
    _pending = False
    save()


def schedule():
    """レイアウトが変わったことを知らせる。DEBOUNCE 秒後にまとめて書き出す。"""
    global _pending
    if _pending:
        return
    _pending = True
    add_timer(_flush, DEBOUNCE, False)
