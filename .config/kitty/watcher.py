# 全ウィンドウに掛かる watcher。kitty.conf の `watcher` で登録する。
#
# WezTerm の keys.lua reap_orphan_editprompt の移植。相方 (Claude Code) が居なく
# なって取り残された補助ペイン (editprompt / codediff) を閉じる。
#
# close_pane.py が拾えるのは ⌘W のときだけで、Claude Code 自身が終了したとき
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
# ディレクトリを sys.path に積まないので、兄弟モジュールを import する前に
# 自分で積む。tab_bar.py:28 と同じ処置。どちらが先に読まれるかは保証が無いので、
# あちらに任せない。
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import aux_panes  # noqa: E402
import session_state  # noqa: E402

# codediff.py が見る user var。:qa などで codediff を手で閉じたら、同じ
# リポジトリのあいだはフックで開き直さない。
CODEDIFF_OFF_VAR = "codediff_off"


def on_set_user_var(boss, window, data):
    if data.get("key") != session_state.CLAUDE_SESSION_VAR:
        return
    if data.get("value"):
        # claude-code-hooks stamp が session id を書いた = Claude Code のタブが
        # 増えた (または別の会話に変わった)。急がないのでまとめ書きに任せる。
        session_state.schedule()
    else:
        # SessionEnd の `stamp --clear` で刻印が消えた = 会話が終わった。ここは
        # DEBOUNCE を待たずに書く。⌃D で終えた直後に ⌘Q することがあり、待つと
        # 書き出す前に kitty が落ちて、終わった会話が翌朝復元されてしまう。
        #
        # window.user_vars は watcher を呼ぶ前に更新されている (kitty の
        # window.py の set_user_var) ので、今の状態をそのまま書いてよい。
        #
        # /clear と /resume も SessionEnd を通るため、一瞬 nvim だけのファイルに
        # なり、直後の SessionStart の刻印で書き直されるまで 10 秒空く。どちらも
        # 使わない運用なので、⌃D を取りこぼさないほうを採る。
        session_state.save(boss)


def on_close(boss, window, data):
    session_state.schedule()
    tab = boss.tab_for_id(window.tab_id)
    if tab is None:
        return
    # on_close は Window.destroy() の先頭で呼ばれ、この時点で閉じるウィンドウが
    # まだタブに残っていることがある。id で明示的に除く。
    remaining = [w for w in tab.windows if w.id != window.id]
    root = window.user_vars.get(aux_panes.CODEDIFF_VAR)
    if root:
        main, editprompt, _ = aux_panes.find(tab)
        if main is not None:
            main.user_vars[CODEDIFF_OFF_VAR] = root
            # editprompt を 1 行に縮めて隠していたら、codediff.py の _close と
            # 同じく stack で隠す形へ戻す。⌘D で閉じたときは _close が済ませて
            # いるので、ここに来るのは :qa などで閉じたときだけ。
            if editprompt is not None and editprompt.user_vars.get(aux_panes.EDITPROMPT_SQUEEZED_VAR):
                aux_panes.unsqueeze_editprompt(tab, main, editprompt, None)
                aux_panes.hide_editprompt(tab, main, editprompt, None)
    if not remaining or not all(aux_panes.is_aux(w) for w in remaining):
        return
    # 補助ペインは必ず split で作られるので、タブに補助ペインしか残っていなければ
    # 相方を失った証拠とみなしてよい。mark_window_for_close は child monitor に
    # 予約するだけなので、destroy() の途中から呼んでも再入にはならない。
    for orphan in remaining:
        boss.mark_window_for_close(orphan)
