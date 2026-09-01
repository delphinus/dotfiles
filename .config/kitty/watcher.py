# 全ウィンドウに掛かる watcher。kitty.conf の `watcher` で登録する。
#
# WezTerm の keys.lua reap_orphan_editprompt の移植。相方 (Claude Code) が居なく
# なって 1 枚だけ取り残された editprompt ペインを閉じる。
#
# close_pane.py が拾えるのは ⌘W の経路だけで、Claude Code 自身が終了したとき
# (^D / /exit / クラッシュ) はそちらを通らない。WezTerm 版は update-status の
# たびに全タブを走査するポーリングだったが、kitty には on_close があるので
# イベントで拾える。
#
# ついでに、翌朝レイアウトを復元するための書き出し (session_state.py) もここから
# 蹴る。Claude Code のタブが増減するのは「刻印が付いたとき」と「ウィンドウが
# 閉じたとき」だけなので、その 2 つを見ていれば足りる。

import os
import sys

# watcher は runpy.run_path で読まれる。これは tab_bar.py と違ってスクリプトの
# ディレクトリを sys.path に積まないので (実測)、兄弟モジュールを import する前に
# 自分で積む。tab_bar.py:28 と同じ処置。どちらが先に読まれるかは保証が無いので、
# あちらに任せない。
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import session_state  # noqa: E402


def on_set_user_var(boss, window, data):
    # claude-code-hooks stamp が session id を書いた = Claude Code のタブが
    # 増えた (または別の会話に変わった)。
    if data.get("key") == session_state.CLAUDE_SESSION_VAR and data.get("value"):
        session_state.schedule()


def on_close(boss, window, data):
    session_state.schedule()
    tab = boss.tab_for_id(window.tab_id)
    if tab is None:
        return
    # on_close は Window.destroy() の先頭で呼ばれ、この時点で閉じるウィンドウが
    # まだタブに残っていることがある。id で明示的に除く。
    remaining = [w for w in tab.windows if w.id != window.id]
    if len(remaining) != 1:
        return
    orphan = remaining[0]
    if not orphan.user_vars.get("editprompt"):
        return
    # editprompt ペインは必ず split で作られるので、タブに 1 枚きりで残っていれば
    # 相方を失った証拠とみなしてよい。mark_window_for_close は child monitor に
    # 予約するだけなので、destroy() の途中から呼んでも再入にはならない。
    boss.mark_window_for_close(orphan)
