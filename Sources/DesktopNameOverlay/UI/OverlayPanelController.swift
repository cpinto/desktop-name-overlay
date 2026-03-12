import AppKit
import SwiftUI

@MainActor
final class OverlayPanelController: NSObject, OverlayPresenter {
    static let cornerRadius: CGFloat = 20

    private let panel: NSPanel
    private let hostingController: NSHostingController<OverlayVisualView>
    private var hideTask: Task<Void, Never>?
    private var style = OverlayStyleConfig.default

    override init() {
        self.hostingController = NSHostingController(
            rootView: OverlayVisualView(text: "Desktop 1", style: .default)
        )
        self.panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: .init(width: 460, height: 170)),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        super.init()

        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.level = .statusBar
        panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary, .ignoresCycle, .transient]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovable = false
        panel.contentViewController = hostingController
        panel.alphaValue = 0

        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        hostingController.view.layer?.masksToBounds = false
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    }

    func updateStyle(_ style: OverlayStyleConfig) {
        self.style = style
        panel.setContentSize(NSSize(width: style.width, height: style.height))
        hostingController.rootView = OverlayVisualView(text: currentText, style: style)
        centerPanelOnPrimaryDisplay()
    }

    func show(text: String) {
        hideTask?.cancel()
        currentText = text
        hostingController.rootView = OverlayVisualView(text: text, style: style)
        centerPanelOnPrimaryDisplay()
        panel.orderFrontRegardless()
        panel.alphaValue = 0

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.12
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        hideTask = Task { [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(for: .milliseconds(550))
            guard !Task.isCancelled else {
                return
            }

            fadeOut()
        }
    }

    func cancelPresentation() {
        hideTask?.cancel()
        panel.alphaValue = 0
        panel.orderOut(nil)
    }

    private func fadeOut() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        } completionHandler: { [panel] in
            Task { @MainActor in
                panel.orderOut(nil)
            }
        }
    }

    private func centerPanelOnPrimaryDisplay() {
        guard let screen = NSScreen.screens.first else {
            return
        }

        let frame = screen.visibleFrame
        let panelSize = panel.frame.size
        let origin = NSPoint(
            x: frame.midX - (panelSize.width / 2),
            y: frame.midY - (panelSize.height / 2)
        )
        panel.setFrameOrigin(origin)
    }

    private var currentText: String = "Desktop 1"
}
