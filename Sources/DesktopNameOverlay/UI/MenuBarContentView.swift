import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Desktop Overlay")
                .font(.headline)

            if let warning = model.privateAPIWarning {
                Text(warning)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("\(model.desktops.count) primary desktops discovered")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Open Settings") {
                model.showSettingsWindow()
            }

            Toggle(
                "Launch at Login",
                isOn: Binding(
                    get: { model.launchAtLoginEnabled },
                    set: { model.setLaunchAtLogin($0) }
                )
            )

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(14)
        .frame(width: 260)
    }
}
