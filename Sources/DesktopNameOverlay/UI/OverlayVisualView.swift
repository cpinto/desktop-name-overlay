import SwiftUI

struct OverlayVisualView: View {
    let text: String
    let style: OverlayStyleConfig

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: OverlayPanelController.cornerRadius,
                style: .continuous
            )
            .fill(style.backgroundColor.swiftUIColor)
            .background(
                RoundedRectangle(
                    cornerRadius: OverlayPanelController.cornerRadius,
                    style: .continuous
                )
                .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: OverlayPanelController.cornerRadius,
                    style: .continuous
                )
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.22), radius: 24, y: 18)

            VStack(spacing: 10) {
                Text("Desktop")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(style.textColor.swiftUIColor.opacity(0.82))
                    .textCase(.uppercase)
                    .tracking(2)

                Text(text)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(style.textColor.swiftUIColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 28)
        }
        .frame(
            width: style.width,
            height: style.height
        )
        .background(Color.clear)
    }
}
