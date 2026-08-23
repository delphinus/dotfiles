# 全ウィンドウに掛かる watcher。kitty.conf の `watcher` で登録する。
#
# WezTerm の keys.lua reap_orphan_editprompt の移植。相方 (Claude Code) が居なく
# なって 1 枚だけ取り残された editprompt ペインを閉じる。
#
# close_pane.py が拾えるのは ⌘W の経路だけで、Claude Code 自身が終了したとき
# (^D / /exit / クラッシュ) はそちらを通らない。WezTerm 版は update-status の
# たびに全タブを走査するポーリングだったが、kitty には on_close があるので
# イベントで拾える。


def on_close(boss, window, data):
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
