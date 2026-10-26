#!/usr/bin/python3 -I
# 選んだファイルごとに長さ・ビットレート・タグ・カバーアートなどを ffprobe で読み、HTML にして小さなウインドウで表示する
import html
import json
import os
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor



def homebrew_bin(name):
    """Automator から呼ばれると PATH に Homebrew が入っていないので、決まった場所を探す"""
    for prefix in ("/opt/homebrew", "/usr/local"):
        path = f"{prefix}/bin/{name}"
        if os.access(path, os.X_OK):
            return path
    return None


FFPROBE = homebrew_bin("ffprobe")
FFMPEG = homebrew_bin("ffmpeg")
LABELS = {"audio": "音声", "video": "映像", "subtitle": "字幕", "data": "データ"}

CSS = """
:root { color-scheme: light dark; --bg: #f5f5f7; --card: #fff; --sub: #6e6e73; --line: #e5e5ea; --accent: #0a84ff; }
@media (prefers-color-scheme: dark) { :root { --bg: #1c1c1e; --card: #2c2c2e; --sub: #98989d; --line: #3a3a3c; } }
body { margin: 0; padding: 20px; background: var(--bg); font: 13px -apple-system, "Hiragino Sans", sans-serif; }
.card { background: var(--card); border-radius: 12px; padding: 16px 20px; margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,.12); }
.card:last-child { margin-bottom: 0; }
header { display: flex; gap: 16px; margin-bottom: 14px; align-items: flex-start; }
.cover { width: 96px; height: 96px; object-fit: cover; border-radius: 6px; flex: none; box-shadow: 0 1px 4px rgba(0,0,0,.3); }
h1 { font-size: 16px; margin: 0 0 3px; word-break: break-all; }
.artist { font-size: 13px; font-weight: 500; margin-bottom: 2px; }
.album { color: var(--sub); margin-bottom: 6px; }
.path { color: var(--sub); font-size: 11px; word-break: break-all; }
dl { display: grid; grid-template-columns: max-content 1fr; gap: 4px 16px; margin: 12px 0 0; padding-top: 10px; border-top: 1px solid var(--line); }
dt { color: var(--sub); font-size: 11px; padding-top: 1px; }
dd { margin: 0; word-break: break-all; }
.stats { display: flex; gap: 28px; margin-bottom: 14px; }
.stat .label { color: var(--sub); font-size: 11px; }
.stat .value { font-size: 22px; font-weight: 600; font-variant-numeric: tabular-nums; }
.stat .value.accent { color: var(--accent); }
.stat .value.small { font-size: 14px; font-weight: 500; padding-top: 6px; }
.stat .unit { font-size: 12px; font-weight: 400; color: var(--sub); margin-left: 2px; }
table { width: 100%; border-collapse: collapse; font-variant-numeric: tabular-nums; }
th { text-align: left; color: var(--sub); font-weight: 500; font-size: 11px; padding: 4px 8px; border-bottom: 1px solid var(--line); }
td { padding: 6px 8px; border-bottom: 1px solid var(--line); }
tr:last-child td { border-bottom: none; }
td.num, th.num { text-align: right; }
td:first-child, td:nth-child(3), td.num { white-space: nowrap; }
.badge { display: inline-block; font-size: 10px; font-weight: 600; padding: 1px 6px; border-radius: 4px; color: #fff; }
.audio { background: #30a14e; } .video { background: #8e44ad; } .subtitle { background: #8e8e93; }
.error { color: #ff453a; }
"""

# HTML を表示する小さなウインドウ (JavaScript for Automation)。
# 読み込みが終わったら高さを中身に合わせてから前面に出し、Esc・スペース・⌘W で閉じる
VIEWER = r"""
ObjC.import("Cocoa");
ObjC.import("WebKit");

function run(argv) {
  const WIDTH = 680;
  const app = $.NSApplication.sharedApplication;
  app.setActivationPolicy($.NSApplicationActivationPolicyAccessory);

  const rect = $.NSMakeRect(0, 0, WIDTH, 50);  // 中身より低くしておかないと scrollHeight がこの高さになる
  const style = $.NSWindowStyleMaskTitled | $.NSWindowStyleMaskClosable | $.NSWindowStyleMaskMiniaturizable | $.NSWindowStyleMaskResizable;
  const win = $.NSWindow.alloc.initWithContentRectStyleMaskBackingDefer(rect, style, $.NSBackingStoreBuffered, false);
  win.title = "メディア情報";
  win.releasedWhenClosed = false;

  const web = $.WKWebView.alloc.initWithFrameConfiguration(rect, $.WKWebViewConfiguration.alloc.init);
  web.autoresizingMask = $.NSViewWidthSizable | $.NSViewHeightSizable;
  win.contentView = web;

  const show = (height) => {
    const max = $.NSScreen.mainScreen.visibleFrame.size.height - 60;
    win.setContentSize($.NSMakeSize(WIDTH, Math.min(Math.max(height, 120), max)));
    win.center;
    win.makeKeyAndOrderFront(null);
    app.activateIgnoringOtherApps(true);
  };
  // 起動を急ぐため HTML ができる前に起動される。できたら読み込み、読み込み終わったら表示する
  let loaded = false, shown = false;
  const timer = $.NSTimer.scheduledTimerWithTimeIntervalRepeatsBlock(0.02, true, (t) => {
    if (!loaded) {
      if (!$.NSFileManager.defaultManager.fileExistsAtPath(argv[0])) return;
      const url = $.NSURL.fileURLWithPath(argv[0]);
      web.loadFileURLAllowingReadAccessToURL(url, url.URLByDeletingLastPathComponent);
      loaded = true;
      return;
    }
    if (web.isLoading) return;
    t.invalidate;
    web.evaluateJavaScriptCompletionHandler("document.documentElement.scrollHeight", (h, err) => {
      if (!shown) { shown = true; show(Number(ObjC.unwrap(h)) || 400); }
    });
  });

  $.NSEvent.addLocalMonitorForEventsMatchingMaskHandler($.NSEventMaskKeyDown, (ev) => {
    const cmd = (ev.modifierFlags & $.NSEventModifierFlagCommand) !== 0;
    if (ev.keyCode === 53 || ev.keyCode === 49 || (cmd && ev.keyCode === 13)) {  // Esc / スペース / ⌘W
      app.terminate(null);
      return null;
    }
    return ev;
  });
  // 閉じるボタンで閉じたら終了する (Dock に出ないアプリなので、そのままだとプロセスが残る)
  ObjC.registerSubclass({
    name: "MediaInfoWindowDelegate",
    protocols: ["NSWindowDelegate"],
    methods: {
      "windowWillClose:": { types: ["void", ["id"]], implementation: () => app.terminate(null) },
    },
  });
  const delegate = $.MediaInfoWindowDelegate.alloc.init;
  win.delegate = delegate;

  app.run;
}
"""


def kbps(v):
    try:
        return f"{int(v) / 1000:.0f}"
    except (TypeError, ValueError):
        return "-"


def duration(v):
    try:
        t = round(float(v))
    except (TypeError, ValueError):
        return "-"
    h, m, s = t // 3600, t // 60 % 60, t % 60
    return f"{h}:{m:02d}:{s:02d}" if h else f"{m}:{s:02d}"


def channels(n):
    return {1: "モノラル", 2: "ステレオ"}.get(n, f"{n} ch" if n else "-")


def fps(v):
    try:
        a, b = (int(x) for x in v.split("/"))
        return f"{a / b:.2f} fps" if b else "-"
    except (AttributeError, ValueError):
        return "-"


def probe(path, out, n):
    """ffprobe とカバーアートの取り出しを同時に実行する。カバーアートのファイル名 (無ければ None) も返す"""
    cover = os.path.join(out, f"cover-{n}")
    # 0:v から 0:V (カバーアート以外の映像) を除く = 埋め込まれた画像だけ
    ff = subprocess.Popen(
        [FFMPEG, "-v", "quiet", "-y", "-i", path, "-map", "0:v", "-map", "-0:V", "-frames:v", "1", "-c", "copy", "-f", "image2", cover],
        stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    r = subprocess.run(
        [FFPROBE, "-v", "error", "-of", "json", "-show_format", "-show_streams", path],
        capture_output=True, text=True,
    )
    ff.wait()
    name = None
    if os.path.exists(cover):
        with open(cover, "rb") as fp:
            magic = fp.read(8)
        ext = "jpg" if magic.startswith(b"\xff\xd8") else "png" if magic.startswith(b"\x89PNG") else None
        if ext:
            name = f"cover-{n}.{ext}"
            os.rename(cover, os.path.join(out, name))
        else:
            os.remove(cover)
    if r.returncode != 0:
        raise RuntimeError(r.stderr.strip() or "ffprobe が失敗しました")
    return json.loads(r.stdout), name


def stat(label, value, unit="", accent=False, small=False):
    u = f'<span class="unit">{unit}</span>' if unit and value != "-" else ""
    cls = "value" + (" accent" if accent else "") + (" small" if small else "")
    return f'<div class="stat"><div class="label">{label}</div><div class="{cls}">{html.escape(value)}{u}</div></div>'


def header(path, tags, cover):
    e = html.escape
    name = os.path.basename(path)
    folder = os.path.dirname(path).replace(os.path.expanduser("~"), "~", 1)
    title = tags.get("title")
    track = tags.get("track", "").split("/")[0]
    album = " · ".join(x for x in [
        tags.get("album"),
        f"#{track}" if track else "",
        (tags.get("date") or tags.get("year") or "")[:4],
        tags.get("genre"),
    ] if x)
    img = f'<img class="cover" src="{e(cover)}">' if cover else ""
    return (
        f'<header>{img}<div>'
        f'<h1>{e(title or name)}</h1>'
        + (f'<div class="artist">{e(tags["artist"])}</div>' if tags.get("artist") else "")
        + (f'<div class="album">{e(album)}</div>' if album else "")
        + f'<div class="path">{e(name + " — " if title else "")}{e(folder)}</div>'
        + "</div></header>"
    )


def extra_tags(tags):
    e = html.escape
    rows = []
    if tags.get("album_artist") and tags["album_artist"] != tags.get("artist"):
        rows.append(("アルバムアーティスト", tags["album_artist"]))
    for key, label in [("composer", "作曲者"), ("disc", "ディスク"), ("publisher", "レーベル"), ("comment", "コメント")]:
        if tags.get(key):
            rows.append((label, tags[key]))
    if not rows:
        return ""
    return "<dl>" + "".join(f"<dt>{e(k)}</dt><dd>{e(v)}</dd>" for k, v in rows) + "</dl>"


def card(path, out, n):
    e = html.escape
    try:
        info, cover = probe(path, out, n)
    except Exception as ex:  # noqa: BLE001
        return f'<div class="card">{header(path, {}, None)}<div class="error">{e(str(ex))}</div></div>'

    fmt = info.get("format", {})
    tags = {k.lower(): v.strip() for k, v in fmt.get("tags", {}).items() if isinstance(v, str)}
    streams = [s for s in info.get("streams", []) if not s.get("disposition", {}).get("attached_pic")]
    audio = next((s for s in streams if s.get("codec_type") == "audio"), {})
    # 音声だけのファイルは音声ストリームのビットレートを主役にする (全体はタグやカバーアートを含む)
    main_br = audio.get("bit_rate") if not any(s.get("codec_type") == "video" for s in streams) else None

    stats = stat("長さ", duration(fmt.get("duration")))
    if main_br:
        stats += stat("ビットレート", kbps(main_br), "kbps", accent=True)
        stats += stat("全体", kbps(fmt.get("bit_rate")), "kbps")
    else:
        stats += stat("ビットレート", kbps(fmt.get("bit_rate")), "kbps", accent=True)
    stats += stat("形式", fmt.get("format_long_name") or fmt.get("format_name") or "-", small=True)

    rows = []
    for s in streams:
        ty = s.get("codec_type", "")
        if ty == "audio":
            detail = f'{int(s["sample_rate"]) / 1000:.1f} kHz · {channels(s.get("channels"))}' if s.get("sample_rate") else channels(s.get("channels"))
        elif ty == "video":
            detail = f'{s.get("width")}×{s.get("height")} · {fps(s.get("avg_frame_rate"))}'
        else:
            detail = s.get("tags", {}).get("language", "")
        codec = s.get("codec_long_name") or s.get("codec_name") or "-"
        mode = s.get("profile", "")
        rows.append(
            f'<tr><td><span class="badge {e(ty)}">{e(LABELS.get(ty, ty))}</span></td>'
            f'<td>{e(codec)}{" (" + e(mode) + ")" if mode and mode != "unknown" else ""}</td>'
            f'<td>{e(detail)}</td><td class="num">{kbps(s.get("bit_rate"))} kbps</td></tr>'
        )
    table = (
        '<table><tr><th>種類</th><th>コーデック</th><th>詳細</th><th class="num">ビットレート</th></tr>'
        + "".join(rows) + "</table>"
    ) if rows else ""
    return f'<div class="card">{header(path, tags, cover)}<div class="stats">{stats}</div>{table}{extra_tags(tags)}</div>'


def main(paths):
    out = tempfile.mkdtemp(prefix="media-info.")
    f = os.path.join(out, "メディア情報.html")
    preview = not os.environ.get("MEDIA_INFO_NO_PREVIEW")
    if preview:
        # 表示側の起動 (osascript と WebKit) に時間が掛かるので先に起動し、その間に読み取る。
        # ウインドウを閉じたら一時ファイルを消す。Automator を待たせないよう切り離して起動する
        viewer = os.path.join(out, "viewer.js")
        with open(viewer, "w", encoding="utf-8") as fp:
            fp.write(VIEWER)
        subprocess.Popen(
            ["/bin/sh", "-c", 'osascript -l JavaScript "$1" "$2" >/dev/null 2>&1; rm -rf "$3"', "sh", viewer, f, out],
            start_new_session=True, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    if FFPROBE and FFMPEG:
        with ThreadPoolExecutor(max_workers=4) as pool:
            body = "".join(pool.map(lambda a: card(a[1], out, a[0]), enumerate(paths)))
    else:
        body = '<div class="card"><h1>ffmpeg が見つかりません</h1><p>Homebrew で入れてください: <code>brew install ffmpeg</code></p></div>'
    doc = f'<!doctype html><html><head><meta charset="utf-8"><title>メディア情報</title><style>{CSS}</style></head><body>{body}</body></html>'
    # 表示側が書きかけを読まないよう、書き終えてから名前を付ける
    with open(f + ".part", "w", encoding="utf-8") as fp:
        fp.write(doc)
    os.rename(f + ".part", f)
    if not preview:
        print(f)


if __name__ == "__main__":
    main(sys.argv[1:])
