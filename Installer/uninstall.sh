#!/bin/bash
# Removes the installed app. To also erase to-dos, notes and settings: ./Installer/uninstall.sh --all
set -e

pkill -x PixelCat 2>/dev/null || true
for dir in /Applications "$HOME/Applications"; do
    if [ -d "$dir/PixelCat.app" ]; then
        rm -rf "$dir/PixelCat.app"
        echo "removed $dir/PixelCat.app"
    fi
done
if [ "$1" = "--all" ]; then
    defaults delete io.github.sparkingwaterr.pixelcat 2>/dev/null || true
    defaults delete local.pixelcat 2>/dev/null || true
    echo "removed saved to-dos, notes and settings"
fi
