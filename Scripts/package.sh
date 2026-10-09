#!/bin/bash
# Packages build/PixelCat.app for a GitHub release: a zip (which the in-app updater downloads) and a dmg (for people).
# The app gets an ad-hoc signature so macOS sees the downloaded bundle as intact. It is not signed with an Apple
# Developer ID or notarized, so macOS asks each user to allow the first launch.
set -e
cd "$(dirname "$0")/.."

APP="build/PixelCat.app"
VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Resources/Info.plist)"
ZIP="build/PixelCat-$VERSION.zip"
DMG="build/PixelCat-$VERSION.dmg"

# Work on a copy outside the project folder: Finder attributes picked up there break code signing
STAGE="$(mktemp -d)"
ditto --norsrc --noextattr --noqtn "$APP" "$STAGE/PixelCat.app"
codesign --force --deep --sign - "$STAGE/PixelCat.app"
codesign --verify --deep --strict "$STAGE/PixelCat.app"

rm -f "$ZIP" "$DMG"
ditto -c -k --keepParent "$STAGE/PixelCat.app" "$ZIP"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "Pixel Cat" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null

shasum -a 256 "$ZIP" "$DMG"
