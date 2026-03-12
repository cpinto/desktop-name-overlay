import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var sharedModel: AppModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        DispatchQueue.main.async { [weak self] in
            self?.showSettingsWindow(nil)
        }
    }

    @objc func showSettingsWindow(_ sender: Any?) {
        Self.sharedModel?.showSettingsWindow()
    }
}
