import AppKit
import Darwin
import Foundation

protocol SpaceResolverProtocol {
    var isAvailable: Bool { get }
    var availabilityMessage: String? { get }

    func currentPrimaryDesktop() -> SpaceSnapshot?
    func listPrimaryRegularDesktops() -> [SpaceSnapshot]
}

final class PrivateSpaceResolver: SpaceResolverProtocol {
    private typealias CGSConnectionID = UInt32
    private typealias CGSMainConnectionIDFn = @convention(c) () -> CGSConnectionID
    private typealias CGSCopyManagedDisplaySpacesFn = @convention(c) (CGSConnectionID) -> Unmanaged<CFArray>

    private struct Bindings {
        let mainConnectionID: CGSMainConnectionIDFn
        let copyManagedDisplaySpaces: CGSCopyManagedDisplaySpacesFn
    }

    let isAvailable: Bool
    let availabilityMessage: String?

    private let handle: UnsafeMutableRawPointer?
    private let bindings: Bindings?

    init() {
        guard let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_NOW) else {
            self.handle = nil
            self.bindings = nil
            self.isAvailable = false
            self.availabilityMessage = "Private Space APIs could not be loaded. Overlays are disabled."
            return
        }

        self.handle = handle

        guard
            let connectionPointer = dlsym(handle, "CGSMainConnectionID"),
            let managedSpacesPointer = dlsym(handle, "CGSCopyManagedDisplaySpaces")
        else {
            self.bindings = nil
            self.isAvailable = false
            self.availabilityMessage = "Private Space APIs are missing on this macOS build. Overlays are disabled."
            return
        }

        self.bindings = Bindings(
            mainConnectionID: unsafeBitCast(connectionPointer, to: CGSMainConnectionIDFn.self),
            copyManagedDisplaySpaces: unsafeBitCast(managedSpacesPointer, to: CGSCopyManagedDisplaySpacesFn.self)
        )
        self.isAvailable = true
        self.availabilityMessage = nil
    }

    deinit {
        if let handle {
            dlclose(handle)
        }
    }

    func currentPrimaryDesktop() -> SpaceSnapshot? {
        guard let primaryDisplay = primaryDisplayEntry() else {
            return nil
        }

        let regularSpaces = regularSpaces(from: primaryDisplay)
        guard
            let current = dictionary(forKey: "Current Space", in: primaryDisplay),
            classify(space: current) == .regular
        else {
            return nil
        }

        let spaceID = normalizedSpaceID(from: current)
        let ordinal = regularSpaces.firstIndex(where: { normalizedSpaceID(from: $0) == spaceID }).map { $0 + 1 }

        return SpaceSnapshot(
            spaceID: spaceID,
            ordinal: ordinal,
            kind: .regular,
            displayRole: .primary
        )
    }

    func listPrimaryRegularDesktops() -> [SpaceSnapshot] {
        guard let primaryDisplay = primaryDisplayEntry() else {
            return []
        }

        return regularSpaces(from: primaryDisplay).enumerated().map { index, space in
            SpaceSnapshot(
                spaceID: normalizedSpaceID(from: space),
                ordinal: index + 1,
                kind: .regular,
                displayRole: .primary
            )
        }
    }

    private func primaryDisplayEntry() -> [String: Any]? {
        guard let managedDisplays = managedDisplayEntries() else {
            return nil
        }

        return managedDisplays.first(where: { ($0["Display Identifier"] as? String) == "Main" }) ?? managedDisplays.first
    }

    private func managedDisplayEntries() -> [[String: Any]]? {
        guard let bindings else {
            return nil
        }

        let connection = bindings.mainConnectionID()
        let displaySpaces = bindings.copyManagedDisplaySpaces(connection).takeRetainedValue() as NSArray
        return displaySpaces.compactMap { $0 as? [String: Any] }
    }

    private func regularSpaces(from displayEntry: [String: Any]) -> [[String: Any]] {
        spaceEntries(from: displayEntry).filter { classify(space: $0) == .regular }
    }

    private func spaceEntries(from displayEntry: [String: Any]) -> [[String: Any]] {
        (displayEntry["Spaces"] as? [[String: Any]]) ?? []
    }

    private func normalizedSpaceID(from space: [String: Any]) -> String {
        if let id = space["id64"] as? UInt64 {
            return String(id)
        }

        if let id = space["id64"] as? Int {
            return String(id)
        }

        if let managedID = space["ManagedSpaceID"] as? UInt64 {
            return String(managedID)
        }

        if let managedID = space["ManagedSpaceID"] as? Int {
            return String(managedID)
        }

        if let uuid = space["uuid"] as? String {
            return uuid
        }

        return UUID().uuidString
    }

    private func classify(space: [String: Any]) -> SpaceKind {
        if space["TileLayoutManager"] != nil {
            return .split
        }

        let typeValue = (space["type"] as? NSNumber)?.intValue ?? 0
        switch typeValue {
        case 0:
            return .regular
        case 4:
            return .fullscreen
        default:
            return .unknown
        }
    }

    private func dictionary(forKey key: String, in dictionary: [String: Any]) -> [String: Any]? {
        dictionary[key] as? [String: Any]
    }
}
