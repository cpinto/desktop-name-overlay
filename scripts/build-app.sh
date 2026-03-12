#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION="${1:-release}"
APP_NAME="DesktopNameOverlay"
APP_DIR="$ROOT_DIR/build/${CONFIGURATION}/${APP_NAME}.app"
INSTALL_DIR="${HOME}/Applications"
ICON_PATH="$ROOT_DIR/Support/AppIcon.icns"

pushd "$ROOT_DIR" >/dev/null
swift build -c "$CONFIGURATION"
BIN_PATH="$(swift build -c "$CONFIGURATION" --show-bin-path)"
popd >/dev/null

swift "$ROOT_DIR/scripts/generate-icon.swift" "$ICON_PATH"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources" "$APP_DIR/Contents/Frameworks"

cp "$BIN_PATH/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/Support/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ICON_PATH" "$APP_DIR/Contents/Resources/AppIcon.icns"

xcrun swift-stdlib-tool \
  --copy \
  --platform macosx \
  --scan-executable "$APP_DIR/Contents/MacOS/$APP_NAME" \
  --destination "$APP_DIR/Contents/Frameworks"

codesign --force --deep --sign - "$APP_DIR" >/dev/null

mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/$APP_NAME.app"
ditto "$APP_DIR" "$INSTALL_DIR/$APP_NAME.app"

echo "Built app bundle at: $APP_DIR"
echo "Installed app bundle at: $INSTALL_DIR/$APP_NAME.app"
