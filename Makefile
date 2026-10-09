APP = build/PixelCat.app

.PHONY: build run install uninstall clean

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
