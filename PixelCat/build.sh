#!/bin/bash
# PixelCat.app 을 이 폴더에 만든다
set -e
cd "$(dirname "$0")"

APP="PixelCat.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O main.swift Hub.swift Notes.swift -o "$APP/Contents/MacOS/PixelCat"

# 앱 아이콘: 앱이 직접 그린 그림을 여러 크기로 줄여서 묶는다
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

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Pixel Cat</string>
    <key>CFBundleDisplayName</key><string>Pixel Cat</string>
    <key>CFBundleIdentifier</key><string>local.pixelcat</string>
    <key>CFBundleExecutable</key><string>PixelCat</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>2.0</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "built $APP"
