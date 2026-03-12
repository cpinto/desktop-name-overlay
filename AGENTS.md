# AGENTS.md

## Overview

This repo contains a macOS SwiftUI/AppKit menu bar utility built as a Swift package. The app listens for Space changes, resolves the active desktop with private macOS APIs, and shows a styled overlay for the final desktop after debounce.

## Working Rules

- Keep the app installable via `./scripts/build-app.sh debug`.
- Preserve the current split between:
  - `App` for lifecycle and settings-window orchestration
  - `Services` for Space resolution, persistence, and state logic
  - `UI` for renderable SwiftUI/AppKit views
- Reuse `OverlayVisualView` for both the live overlay and any settings preview. Do not fork the overlay appearance into separate implementations.
- Treat private API usage as an explicit product choice. Avoid broadening it beyond the current Space-resolution boundary unless necessary.
- Keep the bundle identifier generic and non-personal.

## Validation

- Run `swift test` after code changes.
- If UI or bundle behavior changes, also run `./scripts/build-app.sh debug`.
- Prefer verifying the installed app at `~/Applications/DesktopNameOverlay.app` because that is the intended local launch path.

## Config Compatibility

- `DesktopNameConfig` and `OverlayStyleConfig` must remain backward-compatible with older saved JSON.
- New persisted fields should have explicit decode fallbacks so users do not lose existing desktop names.

## Packaging

- `scripts/generate-icon.swift` generates the app icon used by the build script.
- `Support/AppIcon.icns` is expected in the bundle.
- `Support/AppIcon.iconset/` is generated and should stay untracked.

