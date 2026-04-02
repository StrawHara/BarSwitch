#!/usr/bin/env swift
import AppKit

func generateIcon(size: Int) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext
    let s = CGFloat(size)

    // Background: rounded macOS icon shape, solid dark
    let cornerRadius = s * 0.22
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(path)
    ctx.clip()

    // Solid dark background
    ctx.setFillColor(CGColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0))
    ctx.fill(rect)

    // Single white horizontal bar near the top — representing the menu bar
    let barHeight = s * 0.045
    let barY = s * 0.72
    let barX = s * 0.18
    let barWidth = s * 0.64
    let barRect = CGRect(x: barX, y: barY, width: barWidth, height: barHeight)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.95))
    ctx.fill(barRect)

    // Small up arrow above the bar
    let arrowSize = s * 0.07
    let centerX = s / 2
    let arrowY = barY - s * 0.14

    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.5))
    ctx.setLineWidth(s * 0.02)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)

    // Down arrow (hide)
    ctx.move(to: CGPoint(x: centerX - arrowSize, y: arrowY + arrowSize * 0.6))
    ctx.addLine(to: CGPoint(x: centerX, y: arrowY))
    ctx.addLine(to: CGPoint(x: centerX + arrowSize, y: arrowY + arrowSize * 0.6))
    ctx.strokePath()

    // Up arrow (show)
    let arrowY2 = arrowY - s * 0.1
    ctx.move(to: CGPoint(x: centerX - arrowSize, y: arrowY2))
    ctx.addLine(to: CGPoint(x: centerX, y: arrowY2 + arrowSize * 0.6))
    ctx.addLine(to: CGPoint(x: centerX + arrowSize, y: arrowY2))
    ctx.strokePath()

    img.unlockFocus()
    return img
}

let iconsetPath = "BarSwitch/AppIcon.iconset"

let sizes: [(String, Int)] = [
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

for (name, size) in sizes {
    let img = generateIcon(size: size)
    guard let tiff = img.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to generate \(name)")
        continue
    }
    try! png.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(name).png"))
}
print("Done")
