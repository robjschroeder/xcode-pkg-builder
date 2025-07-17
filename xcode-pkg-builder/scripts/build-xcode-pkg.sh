#!/bin/zsh

XIP_PATH="$1"
DEST_PARENT="/Applications"
TMP_DIR="/tmp/xcode-pkg"
PKG_OUTPUT_DIR="$HOME/Desktop"
SIGNING_ID=""

function fail_if_missing() {
  if [[ ! -f "$1" ]]; then
    echo "❌ File not found: $1"
    exit 1
  fi
}

function get_version_from_plist() {
  local plist_path="$1"
  /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$plist_path"
}

function cleanup() {
  rm -rf "$TMP_DIR"
}

fail_if_missing "$XIP_PATH"
cleanup
mkdir -p "$TMP_DIR"

echo "🔓 Expanding $XIP_PATH..."
xip --expand "$XIP_PATH" --out "$TMP_DIR"

APP_NAME="Xcode.app"
APP_SOURCE="$TMP_DIR/$APP_NAME"
PLIST_PATH="$APP_SOURCE/Contents/Info.plist"

fail_if_missing "$PLIST_PATH"
VERSION=$(get_version_from_plist "$PLIST_PATH")
APP_DEST="$DEST_PARENT/Xcode$VERSION"

echo "📦 Renaming and preparing for packaging: $APP_DEST"
mv "$APP_SOURCE" "$APP_DEST"

PKG_ID="com.company.xcode.$VERSION"
PKG_NAME="Xcode$VERSION.pkg"
PKG_PATH="$PKG_OUTPUT_DIR/$PKG_NAME"

echo "📦 Building .pkg for Xcode $VERSION..."

pkgbuild \
  --install-location "/Applications/Xcode$VERSION" \
  --component "$APP_DEST" \
  --identifier "$PKG_ID" \
  "$PKG_PATH"

echo "✅ Package created: $PKG_PATH"
