import Foundation
import Testing
@testable import DesktopNameOverlay

struct ConfigStoreTests {
    @Test
    func loadAndSaveRoundTrip() throws {
        let fileURL = temporaryConfigURL()
        let store = ConfigStore(fileURL: fileURL)
        let config = DesktopNameConfig(
            desktopNames: [
                DesktopNameEntry(spaceID: "5", name: "Mail"),
                DesktopNameEntry(spaceID: "6", name: "Design")
            ],
            overlayStyle: OverlayStyleConfig(
                width: 520,
                height: 180,
                backgroundColor: OverlayColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.8),
                textColor: OverlayColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            )
        )

        try store.save(config)
        let loaded = try store.load()

        #expect(loaded == config)
    }

    @Test
    func configRemainsKeyedBySpaceIDWhenOrdinalsChange() throws {
        let fileURL = temporaryConfigURL()
        let store = ConfigStore(fileURL: fileURL)
        var config = DesktopNameConfig()
        config.setName("Mail", for: "5")
        config.setName("Analytics", for: "8")

        try store.save(config)
        let loaded = try store.load()

        let reorderedDesktops = [
            SpaceSnapshot(spaceID: "8", ordinal: 1, kind: .regular, displayRole: .primary),
            SpaceSnapshot(spaceID: "5", ordinal: 2, kind: .regular, displayRole: .primary)
        ]

        #expect(loaded.name(for: reorderedDesktops[0].spaceID) == "Analytics")
        #expect(loaded.name(for: reorderedDesktops[1].spaceID) == "Mail")
    }

    @Test
    func loadsLegacyConfigWithoutOverlayStyle() throws {
        let fileURL = temporaryConfigURL()
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let legacyJSON = """
        {
          "desktopNames" : [
            {
              "name" : "Email",
              "spaceID" : "3"
            },
            {
              "name" : "Design",
              "spaceID" : "4"
            }
          ]
        }
        """

        try legacyJSON.data(using: .utf8)?.write(to: fileURL)
        let store = ConfigStore(fileURL: fileURL)
        let loaded = try store.load()

        #expect(loaded.name(for: "3") == "Email")
        #expect(loaded.name(for: "4") == "Design")
        #expect(loaded.overlayStyle == .default)
    }

    private func temporaryConfigURL() -> URL {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        return directory.appendingPathComponent("desktops.json")
    }
}
