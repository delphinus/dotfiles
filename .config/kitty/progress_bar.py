# ブロック文字による進捗バー。WezTerm の progress_bar.lua の移植。
# タブの OSC 9;4 表示 (tab_bar.py) と TimeMachine (timemachine.py) が使う。

GLYPHS = "▏▎▍▌▋▊▉█"


def render(size, percent):
    """size 桁のバーを返す。percent は 0..1。"""
    count = int(size * len(GLYPHS) * percent)
    full, rest = divmod(count, len(GLYPHS))
    out = GLYPHS[-1] * full
    spaces = size - full
    if rest:
        out += GLYPHS[rest - 1]
        spaces -= 1
    return out + " " * max(spaces, 0)
