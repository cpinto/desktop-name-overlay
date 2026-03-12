import AppKit
import SwiftUI

extension OverlayColor {
    init(color: Color) {
        let nsColor = NSColor(color)
        let converted = nsColor.usingColorSpace(.sRGB) ?? .systemRed
        self.init(
            red: converted.redComponent,
            green: converted.greenComponent,
            blue: converted.blueComponent,
            alpha: converted.alphaComponent
        )
    }

    var swiftUIColor: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
