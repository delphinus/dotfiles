#!/usr/bin/env python3

from asyncio import create_subprocess_exec
from asyncio.subprocess import PIPE
from iterm2 import Connection, StatusBarComponent, StatusBarRPC, StringKnob, run_forever
from iterm2.statusbar import Knob
from re import compile
from typing import List


async def main(connection: Connection) -> None:
    component: StatusBarComponent = StatusBarComponent(
        "Ping",
        "Show ping status",
        [StringKnob("Target", "host.example.com", "8.8.8.8", "target")],
        "3.21 ms",
        30,
        "dev.delphinus.ping",
    )
    capture_avg_ms = compile(r" = \d+\.\d+/(\d+\.\d+)/\d+\.\d+/\d+\.\d+\s*(\S+)$")

    @StatusBarRPC
    async def ping(knobs: List[Knob]) -> str:
        proc = await create_subprocess_exec(
            "/sbin/ping", "-c", "3", knobs["target"], stdout=PIPE
        )
        while True:
            l: bytes = await proc.stdout.readline()
            if l == b"":
                break
            line = l.decode("utf-8").rstrip()
            m = capture_avg_ms.search(line)
            if m:
                return f"{m.group(1)} {m.group(2)}"
        return "🔻"

    await component.async_register(connection, ping, timeout=None)


if __name__ == "__main__":
    run_forever(main)
