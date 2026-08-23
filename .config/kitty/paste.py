# WezTerm の keys.lua paste_or_forward_image (Cmd-V) を kitty へ移したもの。
#
# editprompt のペインに居て、かつクリップボードが画像なら、生の ^V を相方
# (Claude Code) へ流す。Claude Code は ^V を受けると自分でクリップボードから
# 画像を読むので、こちらでデータを運ぶ必要はない (そもそもクリップボードの
# テキストしか運べない)。それ以外の場合は普通のペースト。

from kittens.tui.handler import result_handler


def main(args):
    pass


def _clipboard_has_image():
    # osascript の `clipboard info` はクリップボードに載っている型を列挙する。
    # 画像なら PNGf か TIFF が現れる。
    import subprocess

    try:
        out = subprocess.run(
            ["osascript", "-e", "clipboard info"],
            capture_output=True,
            text=True,
            timeout=2,
        )
    except Exception:
        return False
    return out.returncode == 0 and ("PNGf" in out.stdout or "TIFF" in out.stdout)


def _notify(message):
    # 端末組み込みの通知は許可が無いと黙って落ちるので、WezTerm 版で実際に頼りに
    # なっていた osascript を使う。
    import subprocess

    try:
        subprocess.Popen(
            ["osascript", "-e", f'display notification "{message}" with title "kitty"'],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception:
        pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    if window.user_vars.get("editprompt") and _clipboard_has_image():
        tab = boss.tab_for_id(window.tab_id)
        if tab is not None:
            for w in tab.windows:
                if w.id != target_window_id:
                    # bracketed paste で包まず生の ^V を流す。Claude Code はこれを
                    # 受けて自分でクリップボードから画像を読む。
                    w.write_to_child("\x16")
                    _notify("🖼 画像を Claude Code へ貼り付けました")
                    return
    boss.paste_from_clipboard()
