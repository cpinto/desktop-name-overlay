import Combine
import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var desktops: [SpaceSnapshot] = []
    @Published private(set) var config = DesktopNameConfig()
    @Published private(set) var privateAPIWarning: String?
    @Published private(set) var configError: String?
    @Published private(set) var loginItemError: String?
    @Published var launchAtLoginEnabled = false

    let configStore: ConfigStore

    private let resolver: SpaceResolverProtocol
    private let overlayController: OverlayPanelController
    private let loginItemManager: LoginItemManager
    private let spaceChangeController: SpaceChangeController
    private lazy var settingsWindowController = SettingsWindowController(model: self)
    private var hasBootstrapped = false

    init(
        configStore: ConfigStore? = nil,
        resolver: SpaceResolverProtocol? = nil,
        overlayController: OverlayPanelController? = nil,
        loginItemManager: LoginItemManager? = nil
    ) {
        let resolvedStore = configStore ?? ConfigStore(bundleIdentifier: "com.desktopnameoverlay.app")
        let resolvedResolver = resolver ?? PrivateSpaceResolver()
        let resolvedOverlay = overlayController ?? OverlayPanelController()
        let resolvedLoginItemManager = loginItemManager ?? LoginItemManager()

        self.configStore = resolvedStore
        self.resolver = resolvedResolver
        self.overlayController = resolvedOverlay
        self.loginItemManager = resolvedLoginItemManager
        self.spaceChangeController = SpaceChangeController(
            resolver: resolvedResolver,
            overlayPresenter: resolvedOverlay,
            nameProvider: { spaceID in
                return (try? resolvedStore.load())?.name(for: spaceID)
            },
            refreshHandler: nil
        )

        loadConfig()
        refreshDesktops()
        refreshLaunchAtLoginState()
        spaceChangeController.refreshHandler = { [weak self] in
            Task { @MainActor [weak self] in
                self?.refreshDesktops()
            }
        }

        Task { @MainActor [weak self] in
            self?.bootstrap()
        }
    }

    func desktopName(for spaceID: String) -> String {
        config.name(for: spaceID) ?? ""
    }

    func setDesktopName(_ newValue: String, for spaceID: String) {
        config.setName(newValue, for: spaceID)
        persistConfig()
    }

    func overlayStyleBinding<Value>(
        get: @escaping (OverlayStyleConfig) -> Value,
        set: @escaping (inout OverlayStyleConfig, Value) -> Void
    ) -> Binding<Value> {
        Binding(
            get: { get(self.config.overlayStyle) },
            set: { newValue in
                set(&self.config.overlayStyle, newValue)
                self.persistConfig()
                self.applyOverlayStyle()
            }
        )
    }

    func refreshDesktops() {
        desktops = resolver.listPrimaryRegularDesktops()
        privateAPIWarning = resolver.availabilityMessage
    }

    func bootstrap() {
        guard !hasBootstrapped else {
            return
        }

        hasBootstrapped = true
        applyOverlayStyle()
        spaceChangeController.startObserving()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try loginItemManager.setEnabled(enabled)
            loginItemError = nil
        } catch {
            loginItemError = error.localizedDescription
        }

        refreshLaunchAtLoginState()
    }

    func showSettingsWindow() {
        settingsWindowController.show()
    }

    var previewOverlayText: String {
        OverlayPreviewTextResolver.text(desktops: desktops, config: config)
    }

    func refreshLaunchAtLoginState() {
        launchAtLoginEnabled = loginItemManager.isEnabled
    }

    private func loadConfig() {
        do {
            config = try configStore.load()
            configError = nil
        } catch {
            config = DesktopNameConfig()
            configError = "Could not load the desktop names file: \(error.localizedDescription)"
        }

    }

    private func persistConfig() {
        do {
            try configStore.save(config)
            configError = nil
        } catch {
            configError = "Could not save the desktop names file: \(error.localizedDescription)"
        }
    }

    private func applyOverlayStyle() {
        overlayController.updateStyle(config.overlayStyle)
    }
}
