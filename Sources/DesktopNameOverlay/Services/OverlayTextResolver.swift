import Foundation

enum OverlayTextResolver {
    static func text(for snapshot: SpaceSnapshot?, configuredName: String?) -> String? {
        guard let snapshot else {
            return nil
        }

        guard snapshot.displayRole == .primary, snapshot.kind == .regular else {
            return nil
        }

        let trimmedName = configuredName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmedName.isEmpty {
            return trimmedName
        }

        guard let ordinal = snapshot.ordinal else {
            return nil
        }

        return "Desktop \(ordinal)"
    }
}
