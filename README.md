# Desktop Name Overlay

Desktop Name Overlay is a macOS menu bar utility that shows a centered overlay when you switch Spaces. It maps macOS desktop Spaces to custom names and displays the final destination after a short debounce, so rapid trackpad swipes only show the last desktop.

## What It Does

- Detects desktop Space changes on macOS
- Resolves the active desktop on the primary display
- Shows a centered translucent overlay with the configured desktop name
- Supports configurable overlay size, background color, and text color
- Includes a live preview in the settings window
- Installs as a menu bar app and can launch at login

## Important Caveat

This app uses private macOS Space APIs to resolve desktop identity. It is intended as a local utility and is not App Store safe.

## Requirements

- macOS 14 or newer
- Xcode / Swift toolchain
- A local user account with permission to run unsigned local apps

## Development

Run tests:

```bash
swift test
```

Build, bundle, and install to `~/Applications`:

```bash
./scripts/build-app.sh debug
```

The build script will:

- generate the app icon
- build the Swift package executable
- create the `.app` bundle
- install the bundle to `~/Applications/DesktopNameOverlay.app`

## Project Layout

- `Sources/DesktopNameOverlay/App`: app lifecycle and settings window wiring
- `Sources/DesktopNameOverlay/Services`: Space detection, config persistence, debounce logic
- `Sources/DesktopNameOverlay/UI`: menu bar UI, settings UI, overlay rendering
- `Tests/DesktopNameOverlayTests`: unit tests for config loading, preview text, overlay logic, and debounce behavior

## Notes

- Desktop names are keyed by internal Space ID, not by visible Mission Control order.
- Full-screen and split-view Spaces are ignored for overlay display.
- The settings preview uses the longest configured desktop name, or a `Desktop N` fallback when no names are set.

