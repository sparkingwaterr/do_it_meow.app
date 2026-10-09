#!/bin/bash
# 앱을 빌드해서 응용 프로그램 폴더에 설치하고 실행한다
# 기본은 /Applications, 다른 곳에 깔려면: ./Installer/install.sh ~/Applications
set -e
cd "$(dirname "$0")/.."

DEST="${1:-/Applications}"
./Scripts/build.sh
pkill -x PixelCat 2>/dev/null || true
mkdir -p "$DEST"
rm -rf "$DEST/PixelCat.app"
cp -R build/PixelCat.app "$DEST/PixelCat.app"
open "$DEST/PixelCat.app"
echo "installed $DEST/PixelCat.app"
