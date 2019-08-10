#!/usr/bin/env python3

from os import getloadavg
from iterm2 import Connection, StatusBarComponent, StatusBarRPC, run_forever
from iterm2.statusbar import Knob
from typing import List


async def main(connection: Connection) -> None:
    component: StatusBarComponent = StatusBarComponent(
        "Load Average",
        "Show load average",
        [],
        "0.01 0.12 1.23",
        30,
        "dev.delphinus.load_average",
    )

    @StatusBarRPC
    async def load_average(knobs: List[Knob]) -> str:
        return " ".join([f"{f:.2f}" for x in getloadavg()])

    await component.async_register(connection, load_average, timeout=None)


if __name__ == "__main__":
    run_forever(main)
