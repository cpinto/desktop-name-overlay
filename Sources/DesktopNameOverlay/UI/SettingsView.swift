import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Desktop Name Overlay")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))

                    Text("Name primary-display desktops by internal Space ID. Reordering desktops updates the displayed order without changing saved names.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let warning = model.privateAPIWarning {
                    warningCard(title: "Private API unavailable", message: warning, tint: .red)
                }

                if let error = model.configError {
                    warningCard(title: "Config issue", message: error, tint: .orange)
                }

                if let error = model.loginItemError {
                    warningCard(title: "Launch at login issue", message: error, tint: .orange)
                }

                HStack {
                    Toggle(
                        "Launch at Login",
                        isOn: Binding(
                            get: { model.launchAtLoginEnabled },
                            set: { model.setLaunchAtLogin($0) }
                        )
                    )
                    .toggleStyle(.switch)

                    Spacer()

                    Button("Refresh Desktops") {
                        model.refreshDesktops()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Overlay appearance")
                        .font(.headline)

                    HStack(spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Width")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Slider(
                                    value: model.overlayStyleBinding(
                                        get: { $0.width },
                                        set: { $0.width = $1 }
                                    ),
                                    in: 280...900,
                                    step: 10
                                )
                                Text("\(Int(model.config.overlayStyle.width)) px")
                                    .font(.caption.monospaced())
                                    .frame(width: 68, alignment: .trailing)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Height")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Slider(
                                    value: model.overlayStyleBinding(
                                        get: { $0.height },
                                        set: { $0.height = $1 }
                                    ),
                                    in: 110...320,
                                    step: 10
                                )
                                Text("\(Int(model.config.overlayStyle.height)) px")
                                    .font(.caption.monospaced())
                                    .frame(width: 68, alignment: .trailing)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Background color")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ColorPicker(
                                "",
                                selection: model.overlayStyleBinding(
                                    get: { $0.backgroundColor.swiftUIColor },
                                    set: { style, color in
                                        style.backgroundColor = OverlayColor(color: color)
                                    }
                                ),
                                supportsOpacity: true
                            )
                            .labelsHidden()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Text color")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ColorPicker(
                                "",
                                selection: model.overlayStyleBinding(
                                    get: { $0.textColor.swiftUIColor },
                                    set: { style, color in
                                        style.textColor = OverlayColor(color: color)
                                    }
                                ),
                                supportsOpacity: true
                            )
                            .labelsHidden()
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Preview")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        overlayPreview
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Regular desktops on the primary display")
                            .font(.headline)
                        Spacer()
                        Text(model.configStore.fileURL.path)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    if model.desktops.isEmpty {
                        Text("No regular desktops were discovered. If you are currently in a full-screen or split-view Space, switch back to a regular desktop and refresh.")
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(model.desktops) { desktop in
                                desktopRow(for: desktop)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(minWidth: 760, minHeight: 680)
    }

    private var overlayPreview: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 48
            let availableHeight: CGFloat = 160
            let widthScale = availableWidth / model.config.overlayStyle.width
            let heightScale = availableHeight / model.config.overlayStyle.height
            let scale = min(widthScale, heightScale, 1)

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.18, green: 0.19, blue: 0.22),
                                Color(red: 0.09, green: 0.10, blue: 0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    )

                OverlayVisualView(
                    text: model.previewOverlayText,
                    style: model.config.overlayStyle
                )
                .scaleEffect(scale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func desktopRow(for desktop: SpaceSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 16) {
                Text("Desktop \(desktop.ordinal ?? 0)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(width: 120, alignment: .leading)

                TextField(
                    "Name",
                    text: Binding(
                        get: { model.desktopName(for: desktop.spaceID) },
                        set: { model.setDesktopName($0, for: desktop.spaceID) }
                    )
                )
                .textFieldStyle(.roundedBorder)

                Text(desktop.spaceID)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .frame(width: 120, alignment: .trailing)
            }

            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 1)
        }
    }

    private func warningCard(title: String, message: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(message)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
    }
}
