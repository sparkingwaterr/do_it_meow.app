APP = build/PixelCat.app

VERSION = $(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Resources/Info.plist)

.PHONY: build run install uninstall clean screenshots release

build:
	./Scripts/build.sh

run: build
	-pkill -x PixelCat
	open $(APP)

install:
	./Installer/install.sh

uninstall:
	./Installer/uninstall.sh

clean:
	rm -rf build

# Retake the app screenshots for the README in light and dark, using sample data
screenshots: build
	PIXELCAT_SCREENSHOTS="$(CURDIR)/docs/screenshots" $(APP)/Contents/MacOS/PixelCat
	for f in docs/screenshots/app-*-light.png docs/screenshots/app-*-dark.png; do sips -Z 1100 "$$f" >/dev/null; done

# Zip the app for a GitHub release. The copy is staged outside the project folder (Finder attributes there
# break signing) and gets an ad-hoc signature so macOS sees the bundle as intact
release: build
	rm -rf /tmp/pixelcat-release && mkdir -p /tmp/pixelcat-release
	ditto --norsrc --noextattr --noqtn $(APP) /tmp/pixelcat-release/PixelCat.app
	codesign --force --deep --sign - /tmp/pixelcat-release/PixelCat.app
	codesign --verify --deep --strict /tmp/pixelcat-release/PixelCat.app
	rm -f build/PixelCat-$(VERSION).zip
	ditto -c -k --keepParent /tmp/pixelcat-release/PixelCat.app build/PixelCat-$(VERSION).zip
	@echo "build/PixelCat-$(VERSION).zip"
