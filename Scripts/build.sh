#!/bin/bash
# Builds build/PixelCat.app
set -e
cd "$(dirname "$0")/.."

APP="build/PixelCat.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O Sources/PixelCat/*.swift -o "$APP/Contents/MacOS/PixelCat"
cp Resources/Info.plist "$APP/Contents/Info.plist"

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
