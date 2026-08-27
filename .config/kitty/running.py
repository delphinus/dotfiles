# 長く走っているコマンドと、その経過時間。
#
#   󰔟 docker 2:14      … 見ているタブで走っている
#   󰔟 3: docker 2:14   … 別のタブ (⌘3) で走っている
#
# OSC 9;4 で進捗を出すコマンド (Claude Code など) はタブのバーが見せてくれるが、
# make や docker build のように何も言わないものは、走っているのか終わったのかが
# タブを覗くまで分からない。
#
# 外部コマンドは要らない。シェル統合 (OSC 133) が握っているコマンドの開始時刻を
# kitty がウィンドウごとに持っているので、それを読むだけで済む:
#
#   window.last_cmd_output_start_time … 走り出した monotonic の時刻。プロンプトに
#                                       戻ると 0.0 に落ちる (Window.handle_cmd_end)
#   window.last_cmd_cmdline           … シェルが報告したコマンドライン
#
# 後者はコマンドが終わっても最後の値が残るので、走っているかどうかの判定は必ず
# 前者で行う。

import os

# 経過時間は必ず kitty の monotonic() で測る。標準ライブラリの time.monotonic() は
# 原点が違う (システム起動から / kitty の起動から) ので、混ぜると last_cmd_output_-
# start_time との差が桁違いになる (実測で 35 秒のコマンドが 110:37:12 と出た)。
from kitty.fast_data_types import get_boss, monotonic

ICON = "\U000f051f"  # md-timer_sand

# これより短いものは出さない。すぐ終わるコマンドで点滅させても読めない。
THRESHOLD = 30

# 走っているのではなく「開いている」もの。名前で弾くのは、代替画面を使わずに
# 居座り続けるものだけでよい (nvim・ページャ・top の類は下の
# is_using_alternate_linebuf で落ちる)。
IGNORE = frozenset(
    """
    claude ssh mosh tmux screen fish bash zsh sh tail watch kitten kitty
    """.split()
)

# コマンドの前に付いて実体を隠すもの。
WRAPPERS = frozenset(("sudo", "doas", "env", "command", "time", "nohup", "exec"))

# コマンド名を切り詰める桁数。ここに来るのはプログラム名なので、和字は考えない。
MAX_NAME = 12


def _name(cmdline):
    """コマンドラインから見出しに使う名前を取り出す。取れなければ空文字。"""
    wrapper = ""
    for token in cmdline.split():
        base = os.path.basename(token)
        # FOO=bar のような環境変数の指定。
        if not base or "=" in base:
            continue
        if base in WRAPPERS:
            # sudo や env そのものを出しても中身が分からないので後ろを見に行く。
            wrapper = wrapper or base
            continue
        if base.startswith("-"):
            # ラッパーのオプション。値を取るかどうか (sudo -u root cmd の root) は
            # ここでは判じられないので、深追いせずラッパー名で妥協する。option の
            # 値を実体と取り違えて "root" と出すよりましなため。
            break
        return base[:MAX_NAME]
    return wrapper[:MAX_NAME]


def _elapsed(secs):
    secs = int(secs)
    if secs < 3600:
        return "%d:%02d" % (secs // 60, secs % 60)
    return "%d:%02d:%02d" % (secs // 3600, secs % 3600 // 60, secs % 60)


def _running(window, now):
    """このウィンドウで長く走っているものがあれば (開始時刻, 名前)。無ければ None。"""
    start = getattr(window, "last_cmd_output_start_time", 0.0) or 0.0
    if not start or now - start < THRESHOLD:
        return None
    # 代替画面を使っているものは、走っているのではなく開いている (nvim、less、
    # top、lazygit、ページャ越しの git log)。読んでいるあいだ中ステータスに
    # 出しても仕方がない。
    #
    # is_using_alternate_linebuf はプロパティではなくメソッド。呼ばずに真偽を見ると
    # 束縛メソッドが常に真になり、何もかも弾いてしまう。
    try:
        if window.screen.is_using_alternate_linebuf():
            return None
    except Exception:
        pass
    name = _name(getattr(window, "last_cmd_cmdline", "") or "")
    if not name or name in IGNORE:
        return None
    return start, name


def status(os_window_id):
    """表示文字列。出すものが無ければ None。表示色は tab_bar.py が決める。

    出せるのは 1 つだけなので、いちばん後に始まったものを選ぶ。裏で回りっぱなしの
    ものより「今さっき投げたもの」のほうが気に掛かるし、それが終われば古いほうに
    自然と戻る。
    """
    tm = get_boss().os_window_map.get(os_window_id)
    if tm is None:
        return None
    now = monotonic()
    active = tm.active_tab
    best = None
    for index, tab in enumerate(tm.tabs, 1):
        for window in tab.windows:
            found = _running(window, now)
            if found is None:
                continue
            start, name = found
            if best is None or start > best[0]:
                # 目の前で走っているものにタブ番号は要らない。別のタブに居るとき
                # だけ、⌘1..9 で飛べる番号を添える。
                best = (start, name, None if tab is active else index)
    if best is None:
        return None
    start, name, index = best
    prefix = "%d: " % index if index else ""
    return "%s %s%s %s" % (ICON, prefix, name, _elapsed(now - start))
