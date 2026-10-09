# Do It Meow

A pixel cat that lives on your Mac desktop and keeps your to-dos.

![The cat](docs/screenshots/loaf.png)

- Click the cat for a speech bubble with your to-dos and memos.
- It wanders, climbs onto windows and peeks over them, naps in a nightcap, eats, and chases a yarn ball.
- The app window has an overview with a completion ring, to-dos with reminders, notes, timers, a calendar, a focus timer, and settings.


## The app window

Every screen follows the system appearance. Light is on the left, dark on the right.

### Overview

Completion ring, streak, the last 7 days, the cat's mood, and what is coming up.

| Light | Dark |
|---|---|
| ![Overview, light](docs/screenshots/app-overview-light.png) | ![Overview, dark](docs/screenshots/app-overview-dark.png) |

### To-Dos

Add, edit, reorder, mark for today, and set reminders.

| Light | Dark |
|---|---|
| ![To-Dos, light](docs/screenshots/app-todos-light.png) | ![To-Dos, dark](docs/screenshots/app-todos-dark.png) |

### Notes

Quick memos, also reachable from the cat's speech bubble.

| Light | Dark |
|---|---|
| ![Notes, light](docs/screenshots/app-notes-light.png) | ![Notes, dark](docs/screenshots/app-notes-dark.png) |

### Timers

Countdown timers that send the cat running to your cursor.

| Light | Dark |
|---|---|
| ![Timers, light](docs/screenshots/app-timers-light.png) | ![Timers, dark](docs/screenshots/app-timers-dark.png) |

### Calendar

To-do reminders laid out by day.

| Light | Dark |
|---|---|
| ![Calendar, light](docs/screenshots/app-calendar-light.png) | ![Calendar, dark](docs/screenshots/app-calendar-dark.png) |

### Focus

A focus timer. The cat naps while you work.

| Light | Dark |
|---|---|
| ![Focus, light](docs/screenshots/app-focus-light.png) | ![Focus, dark](docs/screenshots/app-focus-dark.png) |

### Cat

The cat's current pose, mood, look, and play buttons.

| Light | Dark |
|---|---|
| ![Cat, light](docs/screenshots/app-cat-light.png) | ![Cat, dark](docs/screenshots/app-cat-dark.png) |

### Settings

Launch at login and behavior sliders.

| Light | Dark |
|---|---|
| ![Settings, light](docs/screenshots/app-settings-light.png) | ![Settings, dark](docs/screenshots/app-settings-dark.png) |

## Install

Requires macOS 13 or later and the Xcode command line tools.

```bash
make install
```

This builds the app, copies it to `/Applications`, and opens it. To install somewhere else, run `./Installer/install.sh ~/Applications`. `make uninstall` removes it.

## Develop

```bash
make run          # build into build/ and launch
make screenshots  # retake the README screenshots in light and dark with sample data
make clean        # delete build/
```

## Layout

| Path | What it holds |
|---|---|
| `Sources/PixelCat/main.swift` | The cat, its sprites and behaviour, the speech bubble |
| `Sources/PixelCat/Hub.swift` | The app window, menu bar, status item, quick add |
| `Sources/PixelCat/Notes.swift` | Notes |
| `Sources/PixelCat/Timers.swift` | Countdown timers |
| `Sources/PixelCat/Calendar.swift` | Month calendar of to-do reminders |
| `Resources/Info.plist` | App bundle metadata |
| `Scripts/build.sh` | Builds `build/PixelCat.app` with its icon |
| `Installer/` | Install and uninstall scripts |
| `docs/screenshots/` | Pictures used in this README. `app-*-light.png` and `app-*-dark.png` come from `make screenshots` |
