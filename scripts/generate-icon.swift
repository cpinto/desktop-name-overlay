import AppKit
import Foundation

let outputPath = CommandLine.arguments.dropFirst().first ?? "Support/AppIcon.icns"
let outputURL = URL(fileURLWithPath: outputPath)
let fileManager = FileManager.default
let iconsetURL = outputURL.deletingLastPathComponent().appendingPathComponent("AppIcon.iconset", isDirectory: true)

try? fileManager.removeItem(at: iconsetURL)
try fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let iconSpecs: [(name: String, size: CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for spec in iconSpecs {
    let image = NSImage(size: NSSize(width: spec.size, height: spec.size))
    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        fatalError("Could not create graphics context")
    }

    let rect = CGRect(origin: .zero, size: CGSize(width: spec.size, height: spec.size))
    context.clear(rect)

    let inset = spec.size * 0.08
    let cardRect = rect.insetBy(dx: inset, dy: inset)
    let radius = spec.size * 0.23

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -(spec.size * 0.03)), blur: spec.size * 0.08, color: NSColor.black.withAlphaComponent(0.24).cgColor)
    let shellPath = NSBezierPath(roundedRect: cardRect, xRadius: radius, yRadius: radius)
    shellPath.addClip()
    let shellGradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.98, green: 0.47, blue: 0.22, alpha: 1),
        NSColor(calibratedRed: 0.86, green: 0.13, blue: 0.24, alpha: 1)
    ])!
    shellGradient.draw(in: shellPath, angle: -35)
    context.restoreGState()

    NSColor.white.withAlphaComponent(0.18).setStroke()
    shellPath.lineWidth = max(2, spec.size * 0.012)
    shellPath.stroke()

    let monitorWidth = cardRect.width * 0.64
    let monitorHeight = cardRect.height * 0.18
    let monitorRadius = spec.size * 0.055

    let backMonitor = CGRect(
        x: cardRect.minX + cardRect.width * 0.2,
        y: cardRect.maxY - cardRect.height * 0.34,
        width: monitorWidth,
        height: monitorHeight
    )
    let middleMonitor = backMonitor.offsetBy(dx: spec.size * 0.08, dy: -(spec.size * 0.11))
    let frontMonitor = backMonitor.offsetBy(dx: spec.size * 0.16, dy: -(spec.size * 0.22))

    for (index, monitorRect) in [backMonitor, middleMonitor, frontMonitor].enumerated() {
        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: -(spec.size * 0.012)), blur: spec.size * 0.025, color: NSColor.black.withAlphaComponent(0.14).cgColor)
        let bezelPath = NSBezierPath(roundedRect: monitorRect, xRadius: monitorRadius, yRadius: monitorRadius)
        let whiteAlpha = 0.22 + (Double(index) * 0.14)
        NSColor.white.withAlphaComponent(whiteAlpha).setFill()
        bezelPath.fill()

        let screenRect = monitorRect.insetBy(dx: spec.size * 0.012, dy: spec.size * 0.012)
        let screenPath = NSBezierPath(roundedRect: screenRect, xRadius: monitorRadius * 0.72, yRadius: monitorRadius * 0.72)
        let screenGradient = NSGradient(colors: [
            NSColor(calibratedWhite: 1, alpha: 0.95),
            NSColor(calibratedWhite: 0.96, alpha: 0.84)
        ])!
        screenGradient.draw(in: screenPath, angle: 90)

        if spec.size >= 64 {
            let stripeRect = CGRect(
                x: screenRect.minX + screenRect.width * 0.12,
                y: screenRect.midY - screenRect.height * 0.08,
                width: screenRect.width * 0.42,
                height: max(2, screenRect.height * 0.14)
            )
            let stripePath = NSBezierPath(roundedRect: stripeRect, xRadius: stripeRect.height / 2, yRadius: stripeRect.height / 2)
            NSColor(calibratedRed: 0.95, green: 0.35, blue: 0.24, alpha: 0.7).setFill()
            stripePath.fill()
        }
        context.restoreGState()
    }

    let overlayWidth = cardRect.width * 0.5
    let overlayHeight = cardRect.height * 0.18
    let overlayRect = CGRect(
        x: cardRect.midX - (overlayWidth / 2),
        y: cardRect.minY + cardRect.height * 0.18,
        width: overlayWidth,
        height: overlayHeight
    )
    let overlayPath = NSBezierPath(roundedRect: overlayRect, xRadius: spec.size * 0.08, yRadius: spec.size * 0.08)
    NSColor(calibratedWhite: 0.08, alpha: 0.18).setFill()
    overlayPath.fill()
    NSColor.white.withAlphaComponent(0.28).setStroke()
    overlayPath.lineWidth = max(1.5, spec.size * 0.008)
    overlayPath.stroke()

    if spec.size >= 64 {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let text = spec.size >= 256 ? "D4" : "D"
        let fontSize = spec.size >= 256 ? spec.size * 0.11 : spec.size * 0.125
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: NSColor.white.withAlphaComponent(0.95),
            .paragraphStyle: paragraph
        ]

        let textRect = overlayRect.insetBy(dx: spec.size * 0.02, dy: spec.size * 0.03)
        NSString(string: text).draw(in: textRect, withAttributes: attributes)
    }

    image.unlockFocus()

    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        fatalError("Could not encode PNG for \(spec.name)")
    }

    try pngData.write(to: iconsetURL.appendingPathComponent(spec.name))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", outputURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    throw NSError(domain: "GenerateIcon", code: Int(process.terminationStatus))
}

