# 次の予定。google-calendar-cli を poller で叩いて、今日これから始まる予定のうち
# 直近のものを出す。
#
#   󰃰 14:00 定例 あと 25分
#
# 認証は ~/.config/google-calendar-cli/ に置いてある (dotfiles の
# secret_config_files が全端末へ配っている)。ログインしていない端末ではコマンドが
# 失敗するだけで、poller の値が None のままになるのでステータスには何も出ない。
#
# モジュール名を calendar.py にしないのは、tab_bar.py が設定ディレクトリを
# sys.path の先頭に挿すため、標準ライブラリの calendar を隠してしまうから。

import datetime
import json
import os
import time
import unicodedata

import poller

CLI = os.path.expanduser("~/.go/bin/google-calendar-cli")

ICON = "\U000f00f0"  # md-calendar_clock

# これより先の予定は出さない。朝のうちから夕方の予定を出しても行動は変わらない。
LOOKAHEAD = 4 * 3600

# 残りがこれを切ったら色を変える (tab_bar.py が "soon" を見る)。
SOON = 10 * 60

# 予定名を切り詰める桁数。
MAX_WIDTH = 16

# 予定ではない飾り。workingLocation は終日の「オフィス」「在宅」で、放っておくと
# 一日中これが「次の予定」になる。
NOT_EVENTS = ("workingLocation", "birthday", "fromGmail", "focusTime")


def _width(text):
    """和字を 2 桁として数えた表示幅。kitty の wcswidth と同じ結果になればよいので、
    ここでは標準ライブラリだけで済ませる (このモジュールを kitty の外でも動かせる
    ようにしておく)。"""
    return sum(2 if unicodedata.east_asian_width(c) in "WF" else 1 for c in text)


def _clip(text):
    if _width(text) <= MAX_WIDTH:
        return text
    out = ""
    for char in text:
        # 末尾の … のぶんを 1 桁空けておく。
        if _width(out) + _width(char) > MAX_WIDTH - 1:
            break
        out += char
    return out + "…"


def _event(item):
    """ステータスに出す予定なら (開始時刻の epoch 秒, 名前)。出さないものは None。"""
    if item.get("status") == "cancelled":
        return None
    if item.get("eventType") in NOT_EVENTS:
        return None
    # 終日の予定は start.date しか持たない。時刻を持たないものは「次の予定」に
    # ならないので落とす。
    start = (item.get("start") or {}).get("dateTime")
    if not start:
        return None
    for attendee in item.get("attendees") or []:
        if attendee.get("self") and attendee.get("responseStatus") == "declined":
            return None
    try:
        at = datetime.datetime.fromisoformat(start).timestamp()
    except (TypeError, ValueError):
        return None
    return at, item.get("summary") or "(名称未設定)"


def _read():
    out = yield [CLI, "events", "list", "--today", "-o", "json"]
    if not out:
        return None
    try:
        items = json.loads(out)
    except ValueError:
        return None
    if not isinstance(items, list):
        return None
    return [event for event in (_event(item) for item in items) if event]


def _left(secs):
    minutes = int(secs // 60)
    if minutes < 1:
        return "まもなく"
    if minutes < 60:
        return "あと %d分" % minutes
    return "あと %d:%02d" % (minutes // 60, minutes % 60)


# 予定は分単位でしか動かないので、取り直しは控えめでよい。カウントダウンは取れた
# 予定から描画のたびに計算するので、この間隔でも秒単位で減っていく。
_poller = poller.Poller("gcal", 60, _read)


def status():
    """(表示文字列, "soon" | "later") の組。次の予定が無ければ None。表示色は
    tab_bar.py が決める。

    --today なので日付を跨ぐ予定は拾えない。夜中に翌朝の予定が出ないのは承知の上
    (その時間に見せたい情報でもない)。
    """
    events = _poller.get()
    if not events:
        return None
    now = time.time()
    # 始まってしまった予定は出さない。その中に居るか遅れているかのどちらかで、
    # 会議のあいだ中ステータスに残しても仕方がない。
    coming = [event for event in events if 0 < event[0] - now <= LOOKAHEAD]
    if not coming:
        return None
    at, summary = min(coming)
    left = at - now
    text = "%s %s %s %s" % (ICON, time.strftime("%H:%M", time.localtime(at)), _clip(summary), _left(left))
    return text, ("soon" if left <= SOON else "later")
