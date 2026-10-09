# Do It Meow

A pixel cat that lives on your Mac desktop and keeps your to-dos.

![The cat](PixelCat/preview-loaf.png)

- Click the cat for a speech bubble with your to-dos and memos.
- It wanders, climbs onto windows and peeks over them, naps in a nightcap, eats, and chases a yarn ball.
- The app window has an overview with a completion ring, to-dos with reminders, notes, a focus timer, and settings.

![Overview](PixelCat/preview-app-overview.png)

## Build and run

Requires macOS 13 or later and the Xcode command line tools.

```bash
./PixelCat/build.sh
open PixelCat/PixelCat.app
```

## Source

- `PixelCat/main.swift`: the cat, its sprites and behaviour, the speech bubble
- `PixelCat/Hub.swift`: the app window, menu bar, status item, quick add
- `PixelCat/Notes.swift`: notes
- `PixelCat/build.sh`: builds `PixelCat.app` with its icon
