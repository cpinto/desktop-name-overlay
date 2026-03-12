import AppKit
import Foundation

@MainActor
protocol OverlayPresenter: AnyObject {
    func show(text: String)
    func cancelPresentation()
}

@MainActor
final class SpaceChangeController {
    private let resolver: SpaceResolverProtocol
    private weak var overlayPresenter: OverlayPresenter?
    private let nameProvider: (String) -> String?
    private let notificationCenter: NotificationCenter
    private let debounceDuration: Duration

    private var observer: NSObjectProtocol?
    private var debounceTask: Task<Void, Never>?

    var refreshHandler: (() -> Void)?

    init(
        resolver: SpaceResolverProtocol,
        overlayPresenter: OverlayPresenter,
        nameProvider: @escaping (String) -> String?,
        refreshHandler: (() -> Void)?,
        notificationCenter: NotificationCenter = NSWorkspace.shared.notificationCenter,
        debounceDuration: Duration = .milliseconds(100)
    ) {
        self.resolver = resolver
        self.overlayPresenter = overlayPresenter
        self.nameProvider = nameProvider
        self.refreshHandler = refreshHandler
        self.notificationCenter = notificationCenter
        self.debounceDuration = debounceDuration
    }

    func startObserving() {
        guard observer == nil else {
            return
        }

        observer = notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleSpaceDidChange()
            }
        }
    }

    func stopObserving() {
        if let observer {
            notificationCenter.removeObserver(observer)
            self.observer = nil
        }

        debounceTask?.cancel()
        debounceTask = nil
    }

    func handleSpaceDidChange() {
        refreshHandler?()
        overlayPresenter?.cancelPresentation()
        debounceTask?.cancel()

        debounceTask = Task { [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(for: debounceDuration)
            guard !Task.isCancelled else {
                return
            }

            presentCurrentSpace()
        }
    }

    private func presentCurrentSpace() {
        let snapshot = resolver.currentPrimaryDesktop()
        refreshHandler?()

        let configuredName = snapshot.flatMap { nameProvider($0.spaceID) }
        guard let text = OverlayTextResolver.text(for: snapshot, configuredName: configuredName) else {
            return
        }

        overlayPresenter?.show(text: text)
    }
}
