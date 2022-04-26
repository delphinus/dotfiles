#!/usr/bin/env python3
from iterm2 import (
    Connection,
    LocalWriteOnlyProfile,
    Profile,
    RPC,
    async_get_app,
    run_forever,
)
from re import compile
from typing import (Any, Optional)

SMALL = {"normal": 11, "non-ascii": 14}
MEDIUM = {"normal": 13, "non-ascii": 16}
LARGE = {"normal": 16, "non-ascii": 20}
EX_LARGE = {"normal": 20, "non-ascii": 24}
NAME_SIZE_RE = compile(r"^(.* )(\d*)$")


async def main(connection: Connection) -> None:
    app = await async_get_app(connection)

    @RPC
    async def toggle_font_size(session_id: str) -> None:
        if not app:
            return
        session = app.get_session_by_id(session_id)
        if not session:
            return
        profile: Profile = await session.async_get_profile()
        new_profile = LocalWriteOnlyProfile()
        normal_font = font_name(profile.normal_font, "normal")
        non_ascii_font = font_name(profile.non_ascii_font, "non-ascii")
        if normal_font and non_ascii_font:
            new_profile.set_normal_font(normal_font)
            new_profile.set_non_ascii_font(non_ascii_font)

        await session.async_set_profile_properties(new_profile)

    await toggle_font_size.async_register(connection)


def font_name(current: Any, kind: str) -> Optional[str]:
    if not current or not isinstance(current, str):
        return
    if m := NAME_SIZE_RE.search(current):
        name = m.group(1)
        current_size = int(m.group(2))
        size = (
            EX_LARGE
            if current_size == LARGE[kind]
            else LARGE
            if current_size == MEDIUM[kind]
            else MEDIUM
            if current_size == SMALL[kind]
            else SMALL
        )
        return name + str(size[kind])


if __name__ == "__main__":
    run_forever(main)
