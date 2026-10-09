APP = build/PixelCat.app

.PHONY: build run install uninstall clean screenshots

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
