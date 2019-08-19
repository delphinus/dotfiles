#!/usr/bin/env python3
from iterm2 import (
    App,
    Connection,
    LocalWriteOnlyProfile,
    Profile,
    RPC,
    Session,
    async_get_app,
    run_forever,
)
from typing import Union
from re import compile

SMALL = 14
MEDIUM = 16


async def main(connection: Connection) -> None:
    app: App = await async_get_app(connection)
    name_and_size = compile(r"^(.* )(\d*)$")

    @RPC
    async def toggle_font_size(session_id: str) -> None:
        session: Session = app.get_session_by_id(session_id)
        if not session:
            return
        profile: Profile = await session.async_get_profile()
        match = name_and_size.search(profile.normal_font)
        if not match:
            return
        name = match.group(1)
        size = int(match.group(2))
        toggled_size = SMALL if size == MEDIUM else MEDIUM
        replacement = name + str(toggled_size)
        new_profile = LocalWriteOnlyProfile()
        new_profile.set_normal_font(replacement)

        await session.async_set_profile_properties(new_profile)

    await toggle_font_size.async_register(connection)


if __name__ == "__main__":
    run_forever(main)
