import Foundation

struct OverlayColor: Codable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    static let `default` = OverlayColor(
        red: 0.95,
        green: 0.23,
        blue: 0.20,
        alpha: 0.88
    )
}

struct OverlayStyleConfig: Codable, Hashable {
    var width: Double
    var height: Double
    var backgroundColor: OverlayColor
    var textColor: OverlayColor

    static let `default` = OverlayStyleConfig(
        width: 460,
        height: 170,
        backgroundColor: .default,
        textColor: OverlayColor(red: 1, green: 1, blue: 1, alpha: 1)
    )

    private enum CodingKeys: String, CodingKey {
        case width
        case height
        case backgroundColor
        case textColor
    }

    init(
        width: Double,
        height: Double,
        backgroundColor: OverlayColor,
        textColor: OverlayColor
    ) {
        self.width = width
        self.height = height
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try container.decodeIfPresent(Double.self, forKey: .width) ?? Self.default.width
        self.height = try container.decodeIfPresent(Double.self, forKey: .height) ?? Self.default.height
        self.backgroundColor = try container.decodeIfPresent(OverlayColor.self, forKey: .backgroundColor) ?? Self.default.backgroundColor
        self.textColor = try container.decodeIfPresent(OverlayColor.self, forKey: .textColor) ?? Self.default.textColor
    }
}

struct DesktopNameEntry: Codable, Hashable, Identifiable {
    let spaceID: String
    var name: String

    var id: String {
        spaceID
    }
}

struct DesktopNameConfig: Codable, Hashable {
    var desktopNames: [DesktopNameEntry] = []
    var overlayStyle: OverlayStyleConfig = .default

    private enum CodingKeys: String, CodingKey {
        case desktopNames
        case overlayStyle
    }

    init(
        desktopNames: [DesktopNameEntry] = [],
        overlayStyle: OverlayStyleConfig = .default
    ) {
        self.desktopNames = desktopNames
        self.overlayStyle = overlayStyle
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.desktopNames = try container.decodeIfPresent([DesktopNameEntry].self, forKey: .desktopNames) ?? []
        self.overlayStyle = try container.decodeIfPresent(OverlayStyleConfig.self, forKey: .overlayStyle) ?? .default
    }

    func name(for spaceID: String) -> String? {
        desktopNames.first(where: { $0.spaceID == spaceID })?.name
    }

    mutating func setName(_ value: String, for spaceID: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if let index = desktopNames.firstIndex(where: { $0.spaceID == spaceID }) {
            if trimmed.isEmpty {
                desktopNames.remove(at: index)
            } else {
                desktopNames[index].name = trimmed
            }
        } else if !trimmed.isEmpty {
            desktopNames.append(DesktopNameEntry(spaceID: spaceID, name: trimmed))
        }

        desktopNames.sort { $0.spaceID < $1.spaceID }
    }
}
