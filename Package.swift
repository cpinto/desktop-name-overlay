// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DesktopNameOverlay",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "DesktopNameOverlay",
            targets: ["DesktopNameOverlay"]
        )
    ],
    targets: [
        .executableTarget(
            name: "DesktopNameOverlay"
        ),
        .testTarget(
            name: "DesktopNameOverlayTests",
            dependencies: ["DesktopNameOverlay"]
        )
    ]
)
