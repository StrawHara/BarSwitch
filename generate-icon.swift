#!/usr/bin/env swift
import AppKit

func generateIcon(size: Int) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext
    let s = CGFloat(size)

    // Rounded macOS icon background
    let cornerRadius = s * 0.22
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(path)
    ctx.clip()

    // Gradient background
    let colors = [
        CGColor(red: 0.20, green: 0.20, blue: 0.25, alpha: 1.0),
        CGColor(red: 0.10, green: 0.10, blue: 0.13, alpha: 1.0)
    ] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: 0, y: 0), options: [])

    // Draw SF Symbol "menubar.rectangle" centered
    if let symbol = NSImage(systemSymbolName: "menubar.rectangle", accessibilityDescription: nil) {
        let symbolSize = s * 0.52
        let config = NSImage.SymbolConfiguration(pointSize: symbolSize, weight: .thin)
        let configured = symbol.withSymbolConfiguration(config)!
        let rep = configured.representations.first!
        let symbolRect = CGRect(
            x: (s - rep.size.width) / 2,
            y: (s - rep.size.height) / 2,
            width: rep.size.width,
            height: rep.size.height
        )
        NSColor.white.withAlphaComponent(0.9).setFill()
        configured.draw(in: symbolRect)
    }

    img.unlockFocus()
    return img
}

let iconsetPath = "BarSwitch/AppIcon.iconset"

let sizes: [(String, Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]

for (name, size) in sizes {
    let img = generateIcon(size: size)
    guard let tiff = img.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { continue }
    try! png.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(name).png"))
}
print("Done")
