import SwiftUI

@main
struct DesktopNameOverlayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model: AppModel

    init() {
        let model = AppModel()
        _model = StateObject(wrappedValue: model)
        AppDelegate.sharedModel = model
    }

    var body: some Scene {
        MenuBarExtra("Desktop Overlay", systemImage: "rectangle.3.group.bubble.left.fill") {
            MenuBarContentView(model: model)
        }
        .menuBarExtraStyle(.menu)
    }
}
