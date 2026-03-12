import Foundation

struct ConfigStore {
    let fileURL: URL

    init(bundleIdentifier: String, fileManager: FileManager = .default) {
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupportURL.appendingPathComponent(bundleIdentifier, isDirectory: true)
        self.fileURL = appDirectory.appendingPathComponent("desktops.json")
    }

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func load() throws -> DesktopNameConfig {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return DesktopNameConfig()
        }

        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(DesktopNameConfig.self, from: data)
    }

    func save(_ config: DesktopNameConfig) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: fileURL, options: .atomic)
    }
}
