#!/usr/bin/env bash
# Builds BrowserSwitch.app from source and installs it (for local development).
#
# Usage: scripts/build-app.sh [--open]
#
# Environment:
#   BROWSERSWITCH_SIGN_IDENTITY  codesign identity (default: "-", ad-hoc signature)
#   BROWSERSWITCH_INSTALL_DIR    install location   (default: ~/Applications)
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="BrowserSwitch"
INSTALL_DIR="${BROWSERSWITCH_INSTALL_DIR:-$HOME/Applications}"

scripts/package-app.sh

echo "==> Installing to $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
if pkill -x "$APP_NAME" 2>/dev/null; then
    sleep 0.5
fi
rm -rf "${INSTALL_DIR:?}/$APP_NAME.app"
ditto "build/$APP_NAME.app" "$INSTALL_DIR/$APP_NAME.app"

# Make sure Launch Services knows the (new) bundle, so it shows up as a default browser.
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [[ -x "$LSREGISTER" ]]; then
    "$LSREGISTER" -f "$INSTALL_DIR/$APP_NAME.app"
fi

echo "==> Installed: $INSTALL_DIR/$APP_NAME.app"

if [[ "${1:-}" == "--open" ]]; then
    open "$INSTALL_DIR/$APP_NAME.app"
fi
