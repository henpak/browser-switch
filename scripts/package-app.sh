#!/usr/bin/env bash
# Builds BrowserSwitch.app (release) into build/ and signs it.
#
# Usage: scripts/package-app.sh [--universal] [--zip]
#   --universal  build for Apple Silicon and Intel (arm64 + x86_64)
#   --zip        also create build/BrowserSwitch.zip and build/BrowserSwitch.zip.sha256
#
# Environment:
#   BROWSERSWITCH_VERSION        version to stamp into Info.plist (default: value in Resources/Info.plist)
#   BROWSERSWITCH_BUILD_NUMBER   CFBundleVersion (default: value in Resources/Info.plist)
#   BROWSERSWITCH_SIGN_IDENTITY  codesign identity (default: "-", ad-hoc signature)
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="BrowserSwitch"
BUILD_DIR="build"
APP="$BUILD_DIR/$APP_NAME.app"
IDENTITY="${BROWSERSWITCH_SIGN_IDENTITY:--}"

universal=false
zip=false
for arg in "$@"; do
    case "$arg" in
        --universal) universal=true ;;
        --zip) zip=true ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done

build_args=(-c release --product "$APP_NAME")
if $universal; then
    build_args+=(--arch arm64 --arch x86_64)
fi

if $universal; then echo "==> Building universal release binary"; else echo "==> Building release binary"; fi
swift build "${build_args[@]}"
BIN_DIR="$(swift build "${build_args[@]}" --show-bin-path)"

echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"
cp Resources/Info.plist "$APP/Contents/Info.plist"

PLIST="$APP/Contents/Info.plist"
if [[ -n "${BROWSERSWITCH_VERSION:-}" ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $BROWSERSWITCH_VERSION" "$PLIST"
fi
if [[ -n "${BROWSERSWITCH_BUILD_NUMBER:-}" ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BROWSERSWITCH_BUILD_NUMBER" "$PLIST"
fi
plutil -lint "$PLIST"
VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PLIST")"

echo "==> Signing with identity: $IDENTITY"
codesign --force --sign "$IDENTITY" "$APP"
codesign --verify --strict "$APP"

if $zip; then
    echo "==> Creating $BUILD_DIR/$APP_NAME.zip"
    rm -f "$BUILD_DIR/$APP_NAME.zip" "$BUILD_DIR/$APP_NAME.zip.sha256"
    ditto -c -k --keepParent "$APP" "$BUILD_DIR/$APP_NAME.zip"
    (cd "$BUILD_DIR" && shasum -a 256 "$APP_NAME.zip" > "$APP_NAME.zip.sha256")
    cat "$BUILD_DIR/$APP_NAME.zip.sha256"
fi

echo "==> Done: $APP (version $VERSION, $(lipo -archs "$APP/Contents/MacOS/$APP_NAME"))"
