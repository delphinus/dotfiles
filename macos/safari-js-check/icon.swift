// safari-js-check.app のアイコンを描く。bin/safari-js-check がビルドのときに
//
//   swift icon.swift <出力先の .iconset>
//
// として実行し、iconutil で .icns にする。オレンジの背景に Safari のコンパスを
// 白で描き、右下に警告の三角を重ねる。Safari 本体のアイコンは使わない
// (Safari 自身の通知と見分けがつかなくなる)。

import AppKit

let sizes: [(name: String, size: Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

guard CommandLine.arguments.count == 2 else {
    fputs("usage: swift icon.swift <output.iconset>\n", stderr)
    exit(2)
}
let iconsetPath = CommandLine.arguments[1]
try FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

func drawSymbol(_ name: String, pointSize: CGFloat, color: NSColor, in rect: NSRect) {
    guard let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil),
          let configured = symbol.withSymbolConfiguration(.init(pointSize: pointSize, weight: .semibold))
    else { return }
    let tinted = NSImage(size: configured.size)
    tinted.lockFocus()
    color.set()
    let tintRect = NSRect(origin: .zero, size: configured.size)
    configured.draw(in: tintRect)
    tintRect.fill(using: .sourceAtop)
    tinted.unlockFocus()

    // 縦横比を保って rect の中央に置く
    let scale = min(rect.width / configured.size.width, rect.height / configured.size.height)
    let w = configured.size.width * scale
    let h = configured.size.height * scale
    tinted.draw(in: NSRect(x: rect.midX - w / 2, y: rect.midY - h / 2, width: w, height: h))
}

for entry in sizes {
    let s = CGFloat(entry.size)
    // NSImage.lockFocus は画面の倍率で描くので、ピクセル数を指定した rep に描く
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: entry.size, pixelsHigh: entry.size,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext

    // macOS のアイコンの余白と角丸に合わせる (1024 の中に 824 の角丸四角)
    let inset = s * 100 / 1024
    let body = CGRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    let radius = body.width * 0.225
    ctx.saveGState()
    ctx.addPath(CGPath(roundedRect: body, cornerWidth: radius, cornerHeight: radius, transform: nil))
    ctx.clip()
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.00, green: 0.66, blue: 0.20, alpha: 1),
            CGColor(red: 0.93, green: 0.38, blue: 0.10, alpha: 1),
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: body.maxY), end: CGPoint(x: 0, y: body.minY), options: [])
    ctx.restoreGState()

    let compassSize = body.width * 0.62
    drawSymbol(
        "safari",
        pointSize: compassSize,
        color: .white,
        in: NSRect(x: body.midX - compassSize / 2, y: body.midY - compassSize / 2, width: compassSize, height: compassSize)
    )

    // 警告の三角。白い縁取りの上に黄色を重ねて、背景のオレンジから浮かせる
    let badgeSize = body.width * 0.42
    let badgeRect = NSRect(x: body.maxX - badgeSize * 0.95, y: body.minY + badgeSize * 0.02, width: badgeSize, height: badgeSize)
    drawSymbol("exclamationmark.triangle.fill", pointSize: badgeSize, color: .white, in: badgeRect.insetBy(dx: -s * 0.012, dy: -s * 0.012))
    drawSymbol("exclamationmark.triangle.fill", pointSize: badgeSize, color: NSColor(red: 1, green: 0.84, blue: 0.0, alpha: 1), in: badgeRect)

    NSGraphicsContext.restoreGraphicsState()

    guard let png = rep.representation(using: .png, properties: [:]) else {
        fputs("failed to render \(entry.name)\n", stderr)
        exit(1)
    }
    try png.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(entry.name).png"))
}
