# バッテリー残量の表示。WezTerm の battery.lua の移植。
#
# WezTerm は wezterm.battery_info() を持っていたが kitty には無いので pmset から
# 読む。バッテリーを持たない機種では pmset に -InternalBattery の行が出ないので、
# WezTerm 側で state_of_charge が NaN のときに何も出さなかったのと同じ結果になる。

import re

import poller

# 0%, 10%, ..., 90%, 満充電 の 11 段階。md-battery_* / md-battery_charging_*。
NORMAL = "\U000f008e\U000f007a\U000f007b\U000f007c\U000f007d\U000f007e\U000f007f\U000f0080\U000f0081\U000f0082\U000f17e2"
CHARGING = "\U000f089f\U000f089c\U000f0086\U000f0087\U000f0088\U000f089d\U000f0089\U000f089e\U000f008a\U000f008b\U000f17e2"
SUSPENDED = "\U000f19e5"  # md-battery_clock

# 例: " -InternalBattery-0 (id=1234)\t87%; discharging; 3:21 remaining present: true"
_LINE = re.compile(r"(\d+)%;\s*([^;]+);\s*(?:(\d+):(\d\d))?")


def _read():
    out = yield ["/usr/bin/pmset", "-g", "batt"]
    if not out:
        return None
    for line in out.splitlines():
        if "InternalBattery" not in line:
            continue
        m = _LINE.search(line)
        if not m:
            continue
        percent = int(m.group(1))
        state = m.group(2).strip().lower()
        remaining = None
        if m.group(3) is not None:
            hours, minutes = int(m.group(3)), int(m.group(4))
            if hours or minutes:
                remaining = (hours, minutes)
        return _format(percent, state, remaining)
    # バッテリーを持たない機種。
    return None


def _format(percent, state, remaining):
    charging = False
    if state == "unknown":
        icon = SUSPENDED
    else:
        # pmset が返すのは charging / discharging / charged / AC attached /
        # finishing charge など。部分一致で見ると discharging が charging を含んで
        # しまうので完全一致で判定する。finishing charge も充電中として扱う。
        charging = state in ("charging", "finishing charge")
        icon = (CHARGING if charging else NORMAL)[min(percent // 10, 10)]
    elapsed = " 残り %d:%02d" % remaining if remaining else ""
    return "%s %d%%%s" % (icon, percent, elapsed), _severity(percent, charging)


def _severity(percent, charging):
    """残量の深刻度。充電中は減らないので常に ok。表示色は tab_bar.py が決める。"""
    if charging:
        return "ok"
    if percent < 15:
        return "critical"
    if percent < 30:
        return "warn"
    return "ok"


# バッテリーの残量は秒単位で変わるものではないので、更新は控えめでよい。
_poller = poller.Poller("battery", 30, _read)


def status():
    """(表示文字列, 深刻度) の組。まだ読めていない / バッテリーが無ければ None。"""
    return _poller.get()
