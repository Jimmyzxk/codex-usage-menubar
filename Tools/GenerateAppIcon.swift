import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 2 else {
    fputs("usage: GenerateAppIcon.swift <iconset directory>\n", stderr)
    exit(2)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

func makeIcon(size: Int) -> CGImage {
    let width = size
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil,
        width: width,
        height: width,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        fatalError("unable to create icon context")
    }

    let canvas = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(width))
    let background = canvas.insetBy(dx: CGFloat(size) * 0.06, dy: CGFloat(size) * 0.06)
    context.setFillColor(CGColor(red: 0.055, green: 0.16, blue: 0.40, alpha: 1))
    context.addPath(CGPath(
        roundedRect: background,
        cornerWidth: CGFloat(size) * 0.23,
        cornerHeight: CGFloat(size) * 0.23,
        transform: nil
    ))
    context.fillPath()

    let inner = background.insetBy(dx: CGFloat(size) * 0.10, dy: CGFloat(size) * 0.10)
    context.setFillColor(CGColor(red: 0.10, green: 0.31, blue: 0.78, alpha: 1))
    context.addPath(CGPath(
        roundedRect: inner,
        cornerWidth: CGFloat(size) * 0.17,
        cornerHeight: CGFloat(size) * 0.17,
        transform: nil
    ))
    context.fillPath()

    let left = CGFloat(size) * 0.29
    let right = CGFloat(size) * 0.71
    let top = CGFloat(size) * 0.27
    let bottom = CGFloat(size) * 0.73
    let middle = CGFloat(size) * 0.50

    let frame = CGMutablePath()
    frame.move(to: CGPoint(x: right, y: top))
    frame.addLine(to: CGPoint(x: left + CGFloat(size) * 0.08, y: top))
    frame.addCurve(
        to: CGPoint(x: left, y: middle),
        control1: CGPoint(x: left, y: top),
        control2: CGPoint(x: left, y: middle - CGFloat(size) * 0.09)
    )
    frame.addCurve(
        to: CGPoint(x: left + CGFloat(size) * 0.08, y: bottom),
        control1: CGPoint(x: left, y: middle + CGFloat(size) * 0.09),
        control2: CGPoint(x: left, y: bottom)
    )
    frame.addLine(to: CGPoint(x: right, y: bottom))

    context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.96))
    context.setLineWidth(CGFloat(size) * 0.075)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    context.addPath(frame)
    context.strokePath()

    let pulse = CGMutablePath()
    pulse.move(to: CGPoint(x: CGFloat(size) * 0.34, y: middle))
    pulse.addLine(to: CGPoint(x: CGFloat(size) * 0.43, y: middle))
    pulse.addLine(to: CGPoint(x: CGFloat(size) * 0.48, y: CGFloat(size) * 0.37))
    pulse.addLine(to: CGPoint(x: CGFloat(size) * 0.54, y: CGFloat(size) * 0.63))
    pulse.addLine(to: CGPoint(x: CGFloat(size) * 0.59, y: middle))
    pulse.addLine(to: CGPoint(x: CGFloat(size) * 0.66, y: middle))
    context.setStrokeColor(CGColor(red: 0.48, green: 0.94, blue: 0.78, alpha: 1))
    context.setLineWidth(CGFloat(size) * 0.045)
    context.addPath(pulse)
    context.strokePath()

    context.setFillColor(CGColor(red: 1.0, green: 0.55, blue: 0.43, alpha: 1))
    context.fillEllipse(in: CGRect(
        x: CGFloat(size) * 0.73,
        y: CGFloat(size) * 0.18,
        width: CGFloat(size) * 0.08,
        height: CGFloat(size) * 0.08
    ))

    guard let image = context.makeImage() else {
        fatalError("unable to render app icon")
    }
    return image
}

func writePNG(_ image: CGImage, to url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(
        url as CFURL,
        UTType.png.identifier as CFString,
        1,
        nil
    ) else {
        throw NSError(domain: "CodexUsageIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "unable to create PNG destination"])
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        throw NSError(domain: "CodexUsageIcon", code: 2, userInfo: [NSLocalizedDescriptionKey: "unable to write PNG"])
    }
}

let iconSizes: [(name: String, pixels: Int)] = [
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

for icon in iconSizes {
    try writePNG(makeIcon(size: icon.pixels), to: outputDirectory.appendingPathComponent(icon.name))
}
