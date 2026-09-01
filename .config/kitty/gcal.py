# 今いちばん気に掛けるべき予定。google-calendar-cli を poller で叩いて、今日の予定
# から一つだけ選んで出す。
#
#   󰃰 14:00 定例 あと 25分     … これから始まる。開始までのカウントダウン
#   󰃰 ~15:00 定例 残り 25分    … 開催中。終了までのカウントダウン
#
# 選び方は MeetingBar.app の既定 (ongoingEventVisibility = showTenMinBeforeNext) に
# 倣う (_pick 参照)。開催中の予定は終わるまで出し続け、次の予定が近付いたらそちらへ
# 譲る。始まった途端に消えていた頃は「今出ている会議が何時までか」を思い出すのに
# カレンダーを開き直す羽目になっていた。
#
# 認証は ~/.config/google-calendar-cli/ に置いてある (dotfiles の
# secret_config_files が全端末へ配っている)。ログインしていない端末ではコマンドが
# 失敗するだけで、poller の値が None のままになるのでステータスには何も出ない。
#
# モジュール名を calendar.py にしないのは、tab_bar.py が設定ディレクトリを
# sys.path の先頭に挿すため、標準ライブラリの calendar を隠してしまうから。

import collections
import datetime
import json
import os
import time
import unicodedata

import meeting
import poller

CLI = os.path.expanduser("~/.go/bin/google-calendar-cli")

ICON = "\U000f00f0"  # md-calendar_clock

# これより先の予定は出さない。朝のうちから夕方の予定を出しても行動は変わらない。
# 開催中の予定は「開始まで」が負になるので、この網には掛からない。
LOOKAHEAD = 4 * 3600

# 開催中の予定は残りがこれを切ったら引っ込める。終わりかけの数十秒まで粘っても
# 動きようがないし、"残り 0分" が出るのも嬉しくない。MeetingBar も候補を
# 「終了が 1 分より先」で切っている。
ENDING = 60

# 開催中の予定より、これだけの内に始まる次の予定を優先する。MeetingBar の
# showTenMinBeforeNext (既定) と同じ幅。
SWITCH = 10 * 60

# 開始までがこれを切ったら色を変える (tab_bar.py が "soon" を見る)。
SOON = 10 * 60

# 予定名を切り詰める桁数。
MAX_WIDTH = 16

# 開始からこれだけの間を「今始まった」とみなす (due 参照)。スリープから戻ったときに、
# とっくに始まっていた会議で叩き起こされないための窓。
GRACE = 120

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


# ステータスに出す予定。時刻は epoch 秒。id は Google Calendar のもので、繰り返しの
# 回ごとに別になるため「一度知らせたか」の目印に使える (meeting.tick 参照)。
# url は会議に入るリンクで、持たない予定 (対面など) では None。
Event = collections.namedtuple("Event", "id at until summary url")


def _event(item):
    """ステータスに出す予定なら Event。出さないものは None。"""
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
    end = (item.get("end") or {}).get("dateTime")
    try:
        until = datetime.datetime.fromisoformat(end).timestamp()
    except (TypeError, ValueError):
        # 終了時刻を読めない予定は幅の無い点として扱う。_pick() の網に掛かって
        # 始まった時点で消えるので、この機能を足す前と同じ振る舞いになる。
        until = at
    return Event(item.get("id") or start, at, until, item.get("summary") or "(名称未設定)", meeting.url_for(item))


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


def _pick(events, now):
    """今この瞬間に出す予定。無ければ None。

    MeetingBar の EventSelection.nextEvent (showTenMinBeforeNext) と同じ選び方:

    1. 開催中の予定と、これから始まる予定を開始順に並べる
    2. 先頭を選ぶ (= 開催中のものがあればそれ、無ければ直近のもの)
    3. 選んだのが開催中の予定で、次が SWITCH 以内に始まるならそちらへ譲る。
       譲った先も開催中 (予定が重なっている) ならさらに次へ譲る

    3 の条件に「選んだのが開催中」を足したのは MeetingBar との違い。あちらは
    そこを見ないので、10 分の内に 2 つ始まる朝に、まだ始まっていない手前の予定を
    飛ばして後ろのものを出してしまう。開催中の予定を退ける理由が「そろそろ次へ
    移れ」である以上、退けられるのは既に始まっているものだけでよい。
    """
    # 開催中のものは残りが ENDING を切ったら落とす。これから始まるものは終了時刻を
    # 見るまでもない (必ず先にある)。並べ替えは開始時刻だけで決める。Event を丸ごと
    # 比べると、開始も終了も名前も同じ予定が二つあったとき url の None と文字列を
    # 比べて落ちる。
    live = sorted(
        (event for event in events if event.at - now <= LOOKAHEAD and (event.at > now or event.until - now > ENDING)),
        key=lambda event: event.at,
    )
    if not live:
        return None
    chosen = live[0]
    for event in live[1:]:
        if chosen.at > now or event.at - now >= SWITCH:
            break
        chosen = event
    return chosen


def _hhmm(at):
    return time.strftime("%H:%M", time.localtime(at))


def _span(secs):
    """カウントダウンの数値部分。"""
    minutes = int(secs // 60)
    if minutes < 60:
        return "%d分" % minutes
    return "%d:%02d" % (minutes // 60, minutes % 60)


# 予定は分単位でしか動かないので、取り直しは控えめでよい。カウントダウンは取れた
# 予定から描画のたびに計算するので、この間隔でも秒単位で減っていく。
_poller = poller.Poller("gcal", 60, _read)


def status():
    """(表示文字列, "now" | "soon" | "later", 予定) の組。出す予定が無ければ None。
    表示色は tab_bar.py が決める。

    予定そのものも返すのは、クリックで会議に入れるようにするため (status_click)。
    表示と押し先を別々に引くと、境目をまたいだ瞬間に食い違いうる。

    開催中の予定は開始ではなく終了を指して "~15:00 … 残り 25分" と出す。始まって
    しまえば知りたいのは「いつ終わるか」であって、開始時刻はもう役に立たない。

    --today なので日付を跨ぐ予定は拾えない。夜中に翌朝の予定が出ないのは承知の上
    (その時間に見せたい情報でもない)。
    """
    events = _poller.get()
    if not events:
        return None
    now = time.time()
    chosen = _pick(events, now)
    if not chosen:
        return None
    at, until, summary = chosen.at, chosen.until, chosen.summary
    if at <= now:
        return "%s ~%s %s 残り %s" % (ICON, _hhmm(until), _clip(summary), _span(until - now)), "now", chosen
    left = at - now
    ahead = "まもなく" if left < 60 else "あと %s" % _span(left)
    return "%s %s %s %s" % (ICON, _hhmm(at), _clip(summary), ahead), ("soon" if left <= SOON else "later"), chosen


def due(now):
    """今まさに始まった予定を開始順に。無ければ空。

    poller のキャッシュを見るだけで、取り直しの周期は status() と共有している。
    ここから呼ばれても google-calendar-cli の実行回数は増えない。

    status() と違って一つに絞らないのは、予定が重なっている朝に後ろのものを
    黙って捨てないため。どれを知らせるか (と、二枚重ねない加減) は
    meeting.tick() が決める。
    """
    events = _poller.get()
    if not events:
        return []
    return sorted((event for event in events if 0 <= now - event.at <= GRACE), key=lambda event: event.at)
