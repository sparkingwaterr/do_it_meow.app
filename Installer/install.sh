#!/bin/bash
# Builds the app, installs it into the Applications folder and opens it
# Defaults to /Applications. To install elsewhere: ./Installer/install.sh ~/Applications
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
