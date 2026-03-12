import Testing
@testable import DesktopNameOverlay

struct OverlayTextResolverTests {
    @Test
    func usesConfiguredNameWhenPresent() {
        let snapshot = SpaceSnapshot(spaceID: "9", ordinal: 3, kind: .regular, displayRole: .primary)
        #expect(OverlayTextResolver.text(for: snapshot, configuredName: "Analytics") == "Analytics")
    }

    @Test
    func fallsBackToDesktopOrdinalForUnnamedRegularDesktop() {
        let snapshot = SpaceSnapshot(spaceID: "9", ordinal: 3, kind: .regular, displayRole: .primary)
        #expect(OverlayTextResolver.text(for: snapshot, configuredName: nil) == "Desktop 3")
    }

    @Test
    func hidesForFullScreenAndSplitSpaces() {
        let fullscreen = SpaceSnapshot(spaceID: "9", ordinal: nil, kind: .fullscreen, displayRole: .primary)
        let split = SpaceSnapshot(spaceID: "10", ordinal: nil, kind: .split, displayRole: .primary)

        #expect(OverlayTextResolver.text(for: fullscreen, configuredName: "Safari") == nil)
        #expect(OverlayTextResolver.text(for: split, configuredName: "Split") == nil)
    }

    @Test
    func hidesForMissingSnapshot() {
        #expect(OverlayTextResolver.text(for: nil, configuredName: "Mail") == nil)
    }
}
