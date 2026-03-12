import Foundation

enum OverlayPreviewTextResolver {
    static func text(desktops: [SpaceSnapshot], config: DesktopNameConfig) -> String {
        let longestConfiguredName = config.desktopNames
            .map(\.name)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .max { $0.count < $1.count }

        if let longestConfiguredName {
            return longestConfiguredName
        }

        if let ordinal = desktops.first?.ordinal {
            return "Desktop \(ordinal)"
        }

        return "Desktop 1"
    }
}
