# TimeMachine のバックアップ状況。WezTerm の timemachine.lua の移植。
#
# 叩くコマンドは同じ (tmutil / plutil)。WezTerm 版が最終更新時刻の整形に呼んで
# いた date(1) は Python で済むので落とした。

import datetime
import json
import re

import poller
import progress_bar

TMUTIL = "/usr/bin/tmutil"
PLUTIL = "/usr/bin/plutil"

STOP = ""  # oct-stop
SEARCH = ""  # oct-search
STOPWATCH = ""  # oct-stopwatch

BAR_SIZE = 12

PHASES = {
    "Preparing": None,
    "ThinningPreBackup": None,
    "FindingBackupVol": "バックアップディスクに接続中…",
    "FindingChanges": "変更を検出中…",
    "Copying": "コピー",
    "ThinningPostBackup": "クリーンアップ中…",
    "Finishing": "バックアップを終了中…",
    "Idle": None,
    "Stopping": None,
    "MountingDiskImage": "バックアップ作成を準備中…",
    "PreparingSourceVolumes": "バックアップ作成を準備中…",
}

_LATEST = re.compile(r"(\d\d)(\d\d)\d\d\.backup")


def _commify(value, unit=False):
    """WezTerm の commify。大きい値は GB / MB に丸め、3 桁区切りにする。"""
    try:
        n = float(value)
    except (TypeError, ValueError):
        n = 0.0
    if n > 1e9:
        num, suffix = n / 1e9, "GB"
    elif n > 1e6:
        num, suffix = n / 1e6, "MB"
    else:
        num, suffix = n, "KB"
    whole, _, frac = ("%f" % num if num % 1 else "%d" % num).partition(".")
    grouped = "{:,}".format(int(whole))
    if len(grouped) < 3 and frac:
        grouped = "%s.%s" % (grouped, frac[: max(4 - len(grouped), 1)])
    return "%s %s" % (grouped, suffix) if unit else grouped


def _status():
    out = poller.run(["/bin/sh", "-c", "%s status | tail -n +2 | %s -convert json -o - -- -" % (TMUTIL, PLUTIL)])
    if not out:
        return None
    try:
        return json.loads(out)
    except ValueError:
        return None


def _latest_backup():
    out = poller.run([TMUTIL, "latestbackup"], timeout=30)
    if not out:
        return ""
    m = _LATEST.search(out)
    return "%s 最新 %d:%02d" % (STOP, int(m.group(1)), int(m.group(2))) if m else ""


def _refreshed(info):
    raw = info.get("DateOfStateChange")
    if not raw:
        return ""
    try:
        # WezTerm 版は date(1) に "+ 最終更新 %H:%m" を渡していたが、%m は「月」で
        # 分ではない (実測で「20:08」のように時:月が出ていた)。%M に直してある。
        stamp = datetime.datetime.strptime(raw, "%Y-%m-%d %H:%M:%S %z")
    except ValueError:
        return ""
    return stamp.astimezone().strftime(" 最終更新 %H:%M ")


def _running_text(info):
    phase = info.get("BackupPhase", "")
    label = PHASES.get(phase, phase) or phase
    refreshed = _refreshed(info)

    if phase == "FindingChanges":
        return "%s %s %s changes%s" % (SEARCH, label, _commify(info.get("ChangedItemCount")), refreshed)

    progress = info.get("Progress")
    if not progress:
        return "%s %s%s" % (STOPWATCH, label, refreshed)

    remaining = progress.get("TimeRemaining")
    elapsed = ""
    if remaining:
        try:
            secs = int(float(remaining))
            elapsed = " 残り %d:%02d" % (secs // 3600, secs % 3600 // 60)
        except (TypeError, ValueError):
            pass
    try:
        percent = float(progress.get("Percent") or 0)
    except (TypeError, ValueError):
        percent = 0.0
    return "%s %s ▐%s▌ %s %s files%s%s" % (
        STOPWATCH,
        label,
        progress_bar.render(BAR_SIZE, percent),
        _commify(progress.get("bytes"), unit=True),
        _commify(progress.get("files")),
        elapsed,
        refreshed,
    )


def _read():
    dest = poller.run([TMUTIL, "destinationinfo"], timeout=30)
    if dest is None or "No destinations configured" in dest:
        return None
    info = _status()
    if info is None:
        return None
    running = info.get("Running") or (info.get("LastReport") or {}).get("Running")
    if running != "1":
        return _latest_backup()
    return _running_text(info)


# バックアップ中は進捗が動くので少し短めに。tmutil status はそこそこ重い。
_poller = poller.Poller("timemachine", 3, _read)


def text():
    return _poller.get()
