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

# README 에 넣는 앱 화면을 밝은 테마와 어두운 테마로 다시 찍는다 (보기용 예시 데이터 사용)
screenshots: build
	PIXELCAT_SCREENSHOTS="$(CURDIR)/docs/screenshots" $(APP)/Contents/MacOS/PixelCat
	for f in docs/screenshots/app-*-light.png docs/screenshots/app-*-dark.png; do sips -Z 1100 "$$f" >/dev/null; done
