# 予定から会議 URL を取り出して開く。MeetingBar.app の「次の会議に入る」に相当する。
#
# 使う側は 3 つ:
#   - gcal.py … 予定を読むときに URL も一緒に持たせる (url_for)
#   - meeting_alert.py … オーバーレイの Enter で会議を開く (open_url / label)
#   - tab_bar.py の毎秒タイマー … 始まった予定を知らせる (tick)
#
# 通知は Calendar.app に任せる。ここが埋めるのは「kitty での作業に集中していて
# OS 通知に気付かなかった」パターンだけなので、知らせ方は kitty の中で完結する
# オーバーレイ 1 つに絞ってある。
#
# tick() だけは kitty の中でしか動かないが、get_boss の import を関数の中に
# 閉じ込めてあるので、このモジュール自体は kitty の外でも読み込める (gcal.py と
# 同じ方針)。手元で試すなら:
#
#     python3 -c 'import json,meeting; print([meeting.url_for(i) for i in json.load(open("events.json"))])'

import os
import re
import subprocess
import sys
import time
from urllib.parse import parse_qs, urlsplit

# Meet を開くブラウザ。MeetingBar の meetBrowser に合わせてある。既定のブラウザ
# 任せにしないのは、リンクを Safari で開く設定の端末があると分かれてしまうから。
BROWSER = "Google Chrome"
BROWSER_APP = "/Applications/Google Chrome.app"

# Zoom の招待 URL。Meet と違って構造化データでは来ず、location か description に
# 生で入っている (直近 6 週間 156 件の実測で location 30 件 / description 36 件)。
_ZOOM = re.compile(r"https://[\w.-]*zoom\.us/(?:j|my)/[^\s<>\"']+")

# 本文から拾う Meet。会議コードの形 (xxx-yyyy-zzz) でだけ見る。
_MEET = re.compile(r"https://meet\.google\.com/[a-z]{3}-[a-z]{4}-[a-z]{3}")

# 本文から拾った URL の末尾に食い込みやすい文字。description は HTML なので、
# 閉じ括弧や句点がそのまま続いていることがある。
_TRAILING = ".,;:!?)]}>\"'、。」』"

# 次の知らせを出すまでの間隔。同じ時刻に複数の予定が始まっても、一枚目を読む間は
# 差し替えない。
COOLDOWN = 60

# 知らせた予定を覚えておく時間。予定 id は繰り返しの回ごとに別なので、放って
# おくと溜まる一方になる。
FORGET = 24 * 3600

# 覚え先は poller や toggles と同じく sys の私有キー。設定リロードでこのモジュールは
# 読み直されるので、モジュール変数に持つと ⌘⇧R のたびに知らせ直してしまう。
# kitty の再起動では忘れるが、出し直しが起きるのは gcal.GRACE の間だけなので許容する。
_state = sys.__dict__.setdefault("_kitty_meeting_alert", {"seen": {}, "quiet_until": 0.0, "window_id": 0})
# 私有キーはモジュールより長生きなので、キーを足した版を後から読み込むことがある。
_state.setdefault("window_id", 0)


def url_for(item):
    """予定 (Google Calendar API の JSON) から会議 URL。無ければ None。

    Meet は conferenceData に構造化されて入っているので確実に取れる。Zoom は
    本文からの拾い読みになるので、location を description より先に見る
    (description には過去のやり取りが引用されていることがある)。
    """
    for entry in (item.get("conferenceData") or {}).get("entryPoints") or []:
        if entry.get("entryPointType") == "video" and entry.get("uri"):
            return entry["uri"]
    if item.get("hangoutLink"):
        return item["hangoutLink"]
    for field in ("location", "description"):
        text = item.get(field) or ""
        match = _ZOOM.search(text) or _MEET.search(text)
        if match:
            return match.group(0).rstrip(_TRAILING)
    return None


def label(url):
    """オーバーレイに出す会議の種類。"""
    if not url:
        return None
    if "zoom.us" in url:
        return "Zoom"
    if "meet.google.com" in url:
        return "Google Meet"
    return urlsplit(url).netloc or "会議"


def open_url(url):
    """会議を開く。

    kitty のプロセスから呼ぶこと (キッテンの handle_result 経由)。キッテン自身の
    プロセスから投げると、オーバーレイが閉じるときに道連れにされうる。
    """
    try:
        subprocess.Popen(_argv(url), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass


def _argv(url):
    parts = urlsplit(url)
    if parts.netloc.endswith("zoom.us"):
        match = re.match(r"/j/(\d+)", parts.path)
        if not match:
            # /my/<個人リンク> は会議 id を持たないので組み替えられない。
            return ["/usr/bin/open", url]
        # zoommtg:// に組み替えると、ブラウザの「zoom.us を開きますか」を挟まずに
        # アプリが直接立ち上がる。MeetingBar と同じ手。
        query = "confno=" + match.group(1)
        pwd = (parse_qs(parts.query).get("pwd") or [""])[0]
        if pwd:
            query += "&pwd=" + pwd
        return ["/usr/bin/open", "zoommtg://zoom.us/join?" + query]
    if os.path.isdir(BROWSER_APP):
        return ["/usr/bin/open", "-a", BROWSER, url]
    return ["/usr/bin/open", url]


def _dismiss(boss):
    """出しっぱなしのオーバーレイを閉じ、それが覆っていたウィンドウを返す。

    閉じずに放っておくと、次の予定の知らせがその上に重なる。オーバーレイは
    ウィンドウグループの積み重ねなので、上の一枚を Esc で消しても下に古い知らせが
    残る (これが「二重」に見える正体)。新しく出す前に必ず一枚に戻す。

    差し替え先を active_window 任せにしないのは、閉じるのが非同期 (child_monitor
    への予約) で、この直後はまだ古いオーバーレイが active なままだから。そこへ
    重ねると結局入れ子になる。覆っていた素のウィンドウを親として返し、呼び出し側で
    明示的に指定する。
    """
    wid = _state.get("window_id") or 0
    _state["window_id"] = 0
    # ウィンドウ id は使い回されないので、既に閉じられていれば単に見付からない。
    window = boss.window_id_map.get(wid) if wid else None
    if window is None:
        return None
    parent = window.overlay_parent
    # 殺されたキッテンは結果を返さないので handle_result は呼ばれない
    # (boss.on_kitten_finish が data None で素通りする)。会議が勝手に開くことはない。
    boss.mark_window_for_close(window)
    return parent


def tick():
    """始まった予定を一件だけオーバーレイで知らせる。tab_bar.py の毎秒タイマーから。

    描画関数からではなくタイマーから呼ぶ。draw_tab() は採寸パスを含めてタブの
    枚数だけ呼ばれるので、副作用を置く場所ではない。タイマーはタブバーが見えて
    いなくても回るので、タブが 1 枚で bar が隠れている間も知らせは出る。

    予定は gcal の poller のキャッシュから読む。取り直しの周期は右ステータスと
    共有しているので、ここが増えても google-calendar-cli の実行回数は変わらない。
    """
    import gcal
    from kitty.fast_data_types import get_boss

    now = time.time()
    seen = _state["seen"]
    for key in [key for key, at in seen.items() if now - at > FORGET]:
        del seen[key]
    if now < _state["quiet_until"]:
        return
    for event in gcal.due(now):
        if event.id in seen:
            continue
        seen[event.id] = now
        _state["quiet_until"] = now + COOLDOWN
        boss = get_boss()
        overlay = boss.run_kitten_with_metadata(
            "meeting_alert.py",
            (str(int(event.at)), str(int(event.until)), event.url or "", event.summary),
            window=_dismiss(boss),
        )
        _state["window_id"] = getattr(overlay, "id", 0) or 0
        return
