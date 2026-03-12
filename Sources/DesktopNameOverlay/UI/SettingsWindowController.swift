import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    init(model: AppModel) {
        let hostingController = NSHostingController(rootView: SettingsView(model: model))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 820, height: 760),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.contentViewController = hostingController
        window.title = "DesktopNameOverlay Settings"
        window.identifier = NSUserInterfaceItemIdentifier("DesktopNameOverlaySettingsWindow")
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 820, height: 760))
        window.minSize = NSSize(width: 820, height: 680)
        window.center()

        super.init(window: window)
        self.window?.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func show() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
