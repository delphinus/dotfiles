# 右ステータスの項目を出す / 隠すの状態。切り替えは status_toggle.py (キッテン) が行い、
# 参照するのは tab_bar.py の _segments()。
#
# 状態は poller と同じ理由でモジュールの外 (sys の私有キー) に置く。tab_bar.py は
# 設定リロードのたびに兄弟モジュールを sys.modules から落として読み直すので、
# モジュール変数に持つと ⌘⇧R のたびに隠したものが戻ってしまう。

import sys

# 既定は「出す」。一度切ったものだけ False で覚える。
_state = sys.__dict__.setdefault("_kitty_status_toggles", {})


def enabled(name):
    return _state.get(name, True)


def toggle(name):
    """切り替えたあとの状態を返す。"""
    value = not enabled(name)
    _state[name] = value
    return value
