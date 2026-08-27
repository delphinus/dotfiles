# TimeMachine のバックアップ状況。WezTerm の timemachine.lua の移植。
#
# 叩くコマンドは同じ (tmutil / plutil)。WezTerm 版が最終更新時刻の整形に呼んで
# いた date(1) は Python で済むので落とした。
#
# 表示は隣に並ぶバッテリー (battery.py の "󰂁 87% 残り 3:21") と骨格を揃えてある:
#   <アイコン> <数値> [残り h:mm]
# 進捗はバーではなくアイコンが持つ。バッテリーが残量をアイコンの絵で示すのと
# 同じ手で、8 分割の円グラフが埋まっていく。WezTerm 版が併記していたバイト数・
# ファイル数・最終更新時刻・進捗バー・長い日本語のフェーズ名は落とした
# (コピー中で約 60 桁 → 約 15 桁)。
#
#   コピー中     󰪢 62% 残り 1:02
#   変更を検出中 󰍉 3,726
#   準備中       󰥔 準備中
#   待機中       󰁯 11:26

import json
import re

import poller

TMUTIL = "/usr/bin/tmutil"
PLUTIL = "/usr/bin/plutil"

IDLE = "\U000f006f"  # md-backup_restore … 待機中 (最後に取れたバックアップの時刻)
SEARCH = "\U000f0349"  # md-magnify … 変更を検出中 (進捗ではなく件数が出るフェーズ)
WAITING = "\U000f0954"  # md-clock … 進捗を持たないフェーズ

# 進捗 0/8 .. 8/8。md-checkbox_blank_circle_outline + md-circle_slice_1..8。
PIE = "\U000f0130\U000f0a9e\U000f0a9f\U000f0aa0\U000f0aa1\U000f0aa2\U000f0aa3\U000f0aa4\U000f0aa5"

# 進捗を持たないフェーズに出す短いラベル。macOS 自身の文言 ("バックアップ作成を
# 準備中…" 等) を、状態を表す部分だけに詰めたもの。どれも数秒から数十秒で通り過ぎる。
PHASES = {
    "FindingBackupVol": "接続中",
    "MountingDiskImage": "準備中",
    "PreparingSourceVolumes": "準備中",
    "Preparing": "準備中",
    "ThinningPreBackup": "準備中",
    "Copying": "コピー中",
    "ThinningPostBackup": "クリーンアップ中",
    "Finishing": "終了中",
    "Stopping": "停止中",
    "Idle": "待機中",
}

_LATEST = re.compile(r"(\d\d)(\d\d)\d\d\.backup")


def _commify(value):
    """3 桁区切り。WezTerm 版は GB / MB への丸めも持っていたが、バイト数を出すのを
    やめたので桁区切りだけ残した。"""
    try:
        return "{:,}".format(int(float(value)))
    except (TypeError, ValueError):
        return "0"


def _status():
    out = yield ["/bin/sh", "-c", "%s status | tail -n +2 | %s -convert json -o - -- -" % (TMUTIL, PLUTIL)]
    if not out:
        return None
    try:
        return json.loads(out)
    except ValueError:
        return None


def _latest_backup():
    out = yield [TMUTIL, "latestbackup"]
    if not out:
        return None
    m = _LATEST.search(out)
    return "%s %d:%02d" % (IDLE, int(m.group(1)), int(m.group(2))) if m else None


def _percent(info):
    """0..1 の進捗。このフェーズが進捗を持たなければ None。"""
    try:
        value = float((info.get("Progress") or {}).get("Percent"))
    except (TypeError, ValueError):
        return None
    return min(max(value, 0.0), 1.0)


def _remaining(info):
    secs = (info.get("Progress") or {}).get("TimeRemaining")
    try:
        secs = int(float(secs))
    except (TypeError, ValueError):
        return ""
    # 分未満は "残り 0:00" になって壊れて見えるだけなので出さない。
    if secs < 60:
        return ""
    return " 残り %d:%02d" % (secs // 3600, secs % 3600 // 60)


def _running_text(info):
    phase = info.get("BackupPhase", "")

    # 変更の検出だけは進捗率が出ず、代わりに件数が伸びていく。
    if phase == "FindingChanges":
        return "%s %s" % (SEARCH, _commify(info.get("ChangedItemCount")))

    percent = _percent(info)
    if percent is None:
        return "%s %s" % (WAITING, PHASES.get(phase) or phase or "バックアップ中")

    # 円グラフは 9 段階しかないので四捨五入で一番近い絵を選ぶ。正確な値は隣の
    # パーセントが持っているので、絵は「どのくらい進んだか」が伝わればよい。
    pie = PIE[min(int(percent * 8 + 0.5), 8)]
    # 丸めた上で、終わり切っていないのに 100% と出ないよう 99 で頭を抑える。
    shown = 100 if percent >= 1.0 else min(int(percent * 100 + 0.5), 99)
    return "%s %d%%%s" % (pie, shown, _remaining(info))


def _read():
    dest = yield [TMUTIL, "destinationinfo"]
    if dest is None or "No destinations configured" in dest:
        return None
    info = yield from _status()
    if info is None:
        return None
    running = info.get("Running") or (info.get("LastReport") or {}).get("Running")
    if running != "1":
        text = yield from _latest_backup()
        return (text, "idle") if text else None
    return (_running_text(info), "running")


# バックアップ中は進捗が動くので少し短めに。tmutil status はそこそこ重い。
_poller = poller.Poller("timemachine", 3, _read)


def status():
    """(表示文字列, "idle" | "running") の組。まだ読めていない / バックアップ先が
    設定されていなければ None。表示色は tab_bar.py が決める。"""
    return _poller.get()
