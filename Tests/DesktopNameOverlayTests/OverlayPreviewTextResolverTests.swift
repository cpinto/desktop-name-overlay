import Testing
@testable import DesktopNameOverlay

struct OverlayPreviewTextResolverTests {
    @Test
    func usesLongestConfiguredDesktopName() {
        let desktops = [
            SpaceSnapshot(spaceID: "3", ordinal: 1, kind: .regular, displayRole: .primary),
            SpaceSnapshot(spaceID: "4", ordinal: 2, kind: .regular, displayRole: .primary)
        ]
        let config = DesktopNameConfig(
            desktopNames: [
                DesktopNameEntry(spaceID: "3", name: "Mail"),
                DesktopNameEntry(spaceID: "4", name: "Project Mercury")
            ]
        )

        #expect(OverlayPreviewTextResolver.text(desktops: desktops, config: config) == "Project Mercury")
    }

    @Test
    func fallsBackToFirstDesktopOrdinalWhenNamesAreEmpty() {
        let desktops = [
            SpaceSnapshot(spaceID: "3", ordinal: 4, kind: .regular, displayRole: .primary)
        ]
        let config = DesktopNameConfig(
            desktopNames: [
                DesktopNameEntry(spaceID: "3", name: "   ")
            ]
        )

        #expect(OverlayPreviewTextResolver.text(desktops: desktops, config: config) == "Desktop 4")
    }

    @Test
    func fallsBackToDesktopOneWhenNoDesktopsAreKnown() {
        #expect(OverlayPreviewTextResolver.text(desktops: [], config: DesktopNameConfig()) == "Desktop 1")
    }
}
