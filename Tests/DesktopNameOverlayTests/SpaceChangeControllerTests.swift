import AppKit
import Foundation
import Testing
@testable import DesktopNameOverlay

@MainActor
struct SpaceChangeControllerTests {
    @Test
    func trailingDebounceOnlyShowsTheLastSpace() async throws {
        let resolver = MockSpaceResolver()
        let presenter = MockOverlayPresenter()
        let controller = SpaceChangeController(
            resolver: resolver,
            overlayPresenter: presenter,
            nameProvider: { spaceID in
                [
                    "5": "Mail",
                    "8": "Analytics"
                ][spaceID]
            },
            refreshHandler: nil,
            notificationCenter: NotificationCenter(),
            debounceDuration: .milliseconds(50)
        )

        resolver.snapshot = SpaceSnapshot(spaceID: "5", ordinal: 1, kind: .regular, displayRole: .primary)
        controller.handleSpaceDidChange()

        resolver.snapshot = SpaceSnapshot(spaceID: "8", ordinal: 3, kind: .regular, displayRole: .primary)
        controller.handleSpaceDidChange()

        try await Task.sleep(for: .milliseconds(140))

        #expect(presenter.presentedTexts == ["Analytics"])
        #expect(presenter.cancelCount == 2)
    }

    @Test
    func doesNotShowAnythingWhenCurrentSpaceShouldBeIgnored() async throws {
        let resolver = MockSpaceResolver()
        let presenter = MockOverlayPresenter()
        let controller = SpaceChangeController(
            resolver: resolver,
            overlayPresenter: presenter,
            nameProvider: { _ in nil },
            refreshHandler: nil,
            notificationCenter: NotificationCenter(),
            debounceDuration: .milliseconds(50)
        )

        resolver.snapshot = SpaceSnapshot(spaceID: "11", ordinal: nil, kind: .fullscreen, displayRole: .primary)
        controller.handleSpaceDidChange()

        try await Task.sleep(for: .milliseconds(120))

        #expect(presenter.presentedTexts.isEmpty)
    }
}

private final class MockSpaceResolver: SpaceResolverProtocol {
    var isAvailable: Bool = true
    var availabilityMessage: String? = nil
    var snapshot: SpaceSnapshot?

    func currentPrimaryDesktop() -> SpaceSnapshot? {
        snapshot
    }

    func listPrimaryRegularDesktops() -> [SpaceSnapshot] {
        snapshot.map { [$0] } ?? []
    }
}

@MainActor
private final class MockOverlayPresenter: OverlayPresenter {
    private(set) var presentedTexts: [String] = []
    private(set) var cancelCount = 0

    func show(text: String) {
        presentedTexts.append(text)
    }

    func cancelPresentation() {
        cancelCount += 1
    }
}
