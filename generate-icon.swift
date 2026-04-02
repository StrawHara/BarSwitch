#!/usr/bin/env swift
import AppKit

func generateIcon(size: Int) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext
    let s = CGFloat(size)

    // Background: rounded rectangle with gradient
    let cornerRadius = s * 0.22
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(path)
    ctx.clip()

    // Gradient: dark blue-gray
    let colors = [
        CGColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0),
        CGColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
    ] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: 0, y: 0), options: [])

    // Menu bar rectangle at top
    let barHeight = s * 0.06
    let barY = s - barHeight - s * 0.18
    let barRect = CGRect(x: s * 0.12, y: barY, width: s * 0.76, height: barHeight)
    let barPath = CGPath(roundedRect: barRect, cornerWidth: barHeight * 0.4, cornerHeight: barHeight * 0.4, transform: nil)
    ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))
    ctx.addPath(barPath)
    ctx.fillPath()

    // Toggle switch visual below the bar
    let switchWidth = s * 0.24
    let switchHeight = s * 0.12
    let switchX = (s - switchWidth) / 2
    let switchY = barY - switchHeight - s * 0.12
    let switchRect = CGRect(x: switchX, y: switchY, width: switchWidth, height: switchHeight)
    let switchPath = CGPath(roundedRect: switchRect, cornerWidth: switchHeight / 2, cornerHeight: switchHeight / 2, transform: nil)

    // Switch background (blue = on)
    ctx.setFillColor(CGColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0))
    ctx.addPath(switchPath)
    ctx.fillPath()

    // Switch knob (right side = on)
    let knobSize = switchHeight * 0.8
    let knobX = switchX + switchWidth - knobSize - (switchHeight - knobSize) / 2
    let knobY = switchY + (switchHeight - knobSize) / 2
    let knobRect = CGRect(x: knobX, y: knobY, width: knobSize, height: knobSize)
    ctx.setFillColor(.white)
    ctx.fillEllipse(in: knobRect)

    // Up/down arrows
    let arrowSize = s * 0.08
    let arrowX = (s - arrowSize) / 2

    // Up arrow
    let upY = switchY + switchHeight + s * 0.06
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.7))
    ctx.setLineWidth(s * 0.025)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: arrowX, y: upY))
    ctx.addLine(to: CGPoint(x: arrowX + arrowSize / 2, y: upY + arrowSize * 0.6))
    ctx.addLine(to: CGPoint(x: arrowX + arrowSize, y: upY))
    ctx.strokePath()

    // Down arrow
    let downY = switchY - s * 0.06
    ctx.move(to: CGPoint(x: arrowX, y: downY))
    ctx.addLine(to: CGPoint(x: arrowX + arrowSize / 2, y: downY - arrowSize * 0.6))
    ctx.addLine(to: CGPoint(x: arrowX + arrowSize, y: downY))
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
    let path = "\(iconsetPath)/\(name).png"
    try! png.write(to: URL(fileURLWithPath: path))
    print("Generated \(path)")
}
print("Done. Run: iconutil -c icns \(iconsetPath)")
