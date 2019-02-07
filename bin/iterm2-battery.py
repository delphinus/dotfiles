#!/usr/bin/env python3

import asyncio
from iterm2 import StatusBarComponent, StatusBarRPC, run_forever
from math import floor
import re
from subprocess import CalledProcessError, check_output
from datetime import datetime

chars = ["▏", "▎", "▍", "▌", "▋", "▊", "▉", "█"]
thunder = "ϟ"
width = 5


class Timer:
    interval_seconds: float = 30
    updated: float = 0
    last: str = ""

    def can_run(self) -> bool:
        print("checking")
        now: float = datetime.now().timestamp()
        return now - self.updated >= self.interval_seconds

    def last_text(self) -> str:
        return self.last

    def interval(self) -> float:
        return self.interval_seconds

    def update(self, text) -> None:
        print("updated: " + text)
        self.updated = datetime.now().timestamp()
        self.last = text


async def main(connection) -> None:
    timer: Timer = Timer()
    component: StatusBarComponent = StatusBarComponent(
        "Battery",
        "Show battery remaining",
        [],
        "|███▎  | 66% 2:34",
        timer.interval(),
        "cx.remora.battery",
    )
    plugged = "🔌"

    @StatusBarRPC
    async def coro(knobs) -> str:
        if not timer.can_run():
            return timer.last_text()
        try:
            out: str = check_output(args=["/usr/bin/pmset", "-g", "batt"]).decode(
                "utf-8"
            )
        except CalledProcessError as err:
            return "`pmset` cannot be executed"

        matched1 = re.match(r".*; (.*);", out, flags=re.S)
        if matched1:
            status: str = matched1[1]
        else:
            return plugged

        matched2 = re.match(r".*?(\d+)%", out, flags=re.S)
        if matched2:
            percent: int = int(matched2[1])
        else:
            return plugged

        battery: str
        if status == "charged":
            battery = width * chars[-1]
        elif status == "charging":
            mid: int = floor(width / 2)
            battery = mid * " " + thunder + (width - mid - 1) * " "
        elif status == "discharging":
            unit: int = len(chars)
            total_char_len: int = len(chars) * width
            char_len: int = floor(total_char_len * percent / 100)
            full_len: int = floor(char_len / unit)
            remained: int = char_len % unit
            space_len: int = width - full_len - (0 if remained == 0 else 1)
            battery = chars[-1] * full_len
            if remained != 0:
                battery += chars[remained - 1]
            battery += " " * space_len
        else:
            battery = " " * width

        matched = re.match(r".*?(\d+:\d+)", out, flags=re.S)
        elapsed: str = matched[1] if matched and matched[1] != "0:00" else ""
        last_status: str = "{0} |{1}| {2:d}% {3}".format("🔋", battery, percent, elapsed)
        timer.update(last_status)
        return last_status

    await component.async_register(connection, coro, timeout=None)


run_forever(main)
