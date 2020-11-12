#!/usr/bin/env python3

from datetime import datetime
from asyncio import create_subprocess_exec
from asyncio.subprocess import PIPE
from iterm2 import Connection, StatusBarComponent, StatusBarRPC, StringKnob, run_forever
from iterm2.statusbar import Knob
from re import compile
from typing import List, Union


class Cache:
    __cached = 0
    __value: Union[str, None] = None

    def __init__(self, expires: int = 3) -> None:
        self.expires = expires

    def is_old(self, now=datetime.now().timestamp()) -> bool:
        return now > self.__cached + self.expires

    @property
    def value(self) -> Union[str, None]:
        return None if self.is_old else self.__value

    @value.setter
    def value(self, v: str, now=datetime.now().timestamp()) -> None:
        self.__value = v
        self.__cached = now


class Pinger:
    __target = ""

    def __init__(self) -> None:
        self.__re = compile(r"time=(\S+)")

    async def get(self, target) -> Union[str, None]:
        if target != self.__target:
            self.__target = target
            self.__proc = await create_subprocess_exec(
                "/sbin/ping", self.__target, stdout=PIPE
            )
        if self.__proc:
            l = await self.__proc.stdout.readline()
            line = l.decode("utf-8").rstrip()
            m = self.__re.search(line)
            return m.group(1) if m else ""
        return ""


async def main(connection: Connection) -> None:
    component: StatusBarComponent = StatusBarComponent(
        "Ping",
        "Show ping status",
        [StringKnob("Target", "host.example.com", "8.8.8.8", "target")],
        "3.21 ms",
        1,
        "dev.delphinus.ping",
    )
    pinger = Pinger()

    @StatusBarRPC
    async def ping(knobs: List[Knob]) -> str:
        print("call")
        result = await pinger.get(knobs["target"])
        if result:
            return f"{result} ms"
        return "🔻"

    await component.async_register(connection, ping, timeout=None)


if __name__ == "__main__":
    run_forever(main)
