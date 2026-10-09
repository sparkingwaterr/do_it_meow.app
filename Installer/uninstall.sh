#!/bin/bash
# 설치한 앱을 지운다. 할 일, 메모, 설정까지 지우려면: ./Installer/uninstall.sh --all
set -e

pkill -x PixelCat 2>/dev/null || true
for dir in /Applications "$HOME/Applications"; do
    if [ -d "$dir/PixelCat.app" ]; then
        rm -rf "$dir/PixelCat.app"
        echo "removed $dir/PixelCat.app"
    fi
done
if [ "$1" = "--all" ]; then
    defaults delete local.pixelcat 2>/dev/null || true
    echo "removed saved to-dos, notes and settings"
fi
