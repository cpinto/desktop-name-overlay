import Foundation

enum SpaceKind: String, Codable, Hashable {
    case regular
    case fullscreen
    case split
    case unknown
}

enum DisplayRole: String, Codable, Hashable {
    case primary
    case secondary
}

struct SpaceSnapshot: Identifiable, Codable, Hashable {
    let spaceID: String
    let ordinal: Int?
    let kind: SpaceKind
    let displayRole: DisplayRole

    var id: String {
        spaceID
    }
}
