#!/bin/bash
# Builds build/PixelCat.app
set -e
cd "$(dirname "$0")/.."

APP="build/PixelCat.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
# Universal binary so it runs on both Apple silicon and Intel Macs
TMP="$(mktemp -d)"
for arch in arm64 x86_64; do
    swiftc -O -target "$arch-apple-macos13.0" Sources/PixelCat/*.swift -o "$TMP/PixelCat-$arch"
done
lipo -create "$TMP/PixelCat-arm64" "$TMP/PixelCat-x86_64" -output "$APP/Contents/MacOS/PixelCat"
cp Resources/Info.plist "$APP/Contents/Info.plist"
# Build number: the number of commits, so every build from a newer commit counts as newer
BUILD="$(git rev-list --count HEAD 2>/dev/null || echo 1)"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" "$APP/Contents/Info.plist"

# App icon: the app draws its own picture, which is scaled to each size and bundled
ICONS="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONS"
"$APP/Contents/MacOS/PixelCat" --icon "$ICONS/icon_512x512@2x.png"
for size in 16 32 128 256 512; do
    sips -z $size $size "$ICONS/icon_512x512@2x.png" --out "$ICONS/icon_${size}x${size}.png" >/dev/null
    if [ $size != 512 ]; then
        sips -z $((size * 2)) $((size * 2)) "$ICONS/icon_512x512@2x.png" --out "$ICONS/icon_${size}x${size}@2x.png" >/dev/null
    fi
done
iconutil -c icns "$ICONS" -o "$APP/Contents/Resources/AppIcon.icns"

echo "built $APP"
