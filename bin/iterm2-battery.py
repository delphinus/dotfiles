#!/usr/bin/env python3

import asyncio
import iterm2
import sys
from subprocess import CalledProcessError, check_output

async def main(connection, argv):
    app = await iterm2.async_get_app(connection)
    component = iterm2.StatusBarComponent(
        "Battery",
        "Show battery remaining",
        "Show remaining time for battery",
        [],
        "xx%",
        60)

    async def coro(knobs):
        try:
            out = check_output(args=["/usr/bin/pmset", "-g", "batt"])
        except CalledProcessError as err:
            return "`pmset` cannot be executed"
        if b"AC Power" in out:
            return "🔌"
        return "🔋"


    await app.async_register_status_bar_component(component, coro)

    future = asyncio.Future()
    await connection.async_dispatch_until_future(future)


if __name__ == "__main__":
    iterm2.Connection().run(main, sys.argv)
