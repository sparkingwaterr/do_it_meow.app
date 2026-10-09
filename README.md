# Do It Meow

**A pixel cat that lives on your Mac desktop and keeps your to-dos.** Finish a task and it gets fed.

<p align="center">
  <img src="docs/screenshots/cat-loaf.png" width="150" alt="The cat sitting like a loaf">
  &nbsp;&nbsp;
  <img src="docs/screenshots/cat-peek.png" width="150" alt="The cat peeking over a window">
  &nbsp;&nbsp;
  <img src="docs/screenshots/cat-sleep.png" width="150" alt="The cat asleep in a nightcap">
</p>

## The cat

It sits above every window and has a life of its own.

- **Wanders** along the bottom of the screen, and sometimes breaks into a run.
- **Climbs onto your windows** and hangs there, peeking over the top edge. It follows the window when you move it and stays clear of the MacBook notch.
- **Naps** in a nightcap with a little nose bubble. Double-click to wake it.
- **Eats** when you put out food, and **chases a yarn ball** all over the screen. You can grab the ball and fling it.
- **Likes being petted.** Stroke it with the mouse for a heart.
- **Comes to get you.** When a reminder or timer goes off, it runs to your cursor and rings until you click it.

<p align="center">
  <img src="docs/screenshots/run-sheet.png" width="640" alt="Running frames">
</p>

Pick from three looks (Loaf, Tuxedo, Cow) and three sizes.

## To-dos and memos, one click away

Click the cat for a speech bubble. Switch between **To-Do** and **Memo** with the tabs at the top.

<p align="center">
  <img src="docs/screenshots/bubble.png" width="260" alt="To-do bubble">
  &nbsp;&nbsp;
  <img src="docs/screenshots/bubble-memo.png" width="260" alt="Memo bubble">
</p>

Checking something off makes the cat happy and, if you like, puts out a bowl of food.

## The app window

Open it from the paw in the menu bar. Every screen follows the system appearance, shown here with light on the left and dark on the right.

### Overview

How much is done, your streak, the last 7 days, the cat's mood, and what is coming up.

| Light | Dark |
|---|---|
| ![Overview, light](docs/screenshots/app-overview-light.png) | ![Overview, dark](docs/screenshots/app-overview-dark.png) |

### More screens

<details>
<summary><b>To-Dos</b> · Type in the last row and press Return to add. Edit in place, drag to reorder, star for today, set a reminder with the clock.</summary>
<br>

| Light | Dark |
|---|---|
| ![To-Dos, light](docs/screenshots/app-todos-light.png) | ![To-Dos, dark](docs/screenshots/app-todos-dark.png) |

</details>

<details>
<summary><b>Notes</b> · Quick memos. The same notes show up in the cat's speech bubble.</summary>
<br>

| Light | Dark |
|---|---|
| ![Notes, light](docs/screenshots/app-notes-light.png) | ![Notes, dark](docs/screenshots/app-notes-dark.png) |

</details>

<details>
<summary><b>Timers</b> · One-click countdowns. When one ends, the cat runs to your cursor and rings until you click it.</summary>
<br>

| Light | Dark |
|---|---|
| ![Timers, light](docs/screenshots/app-timers-light.png) | ![Timers, dark](docs/screenshots/app-timers-dark.png) |

</details>

<details>
<summary><b>Calendar</b> · To-do reminders laid out by day.</summary>
<br>

| Light | Dark |
|---|---|
| ![Calendar, light](docs/screenshots/app-calendar-light.png) | ![Calendar, dark](docs/screenshots/app-calendar-dark.png) |

</details>

<details>
<summary><b>Focus</b> · A focus timer. The cat naps while you work and fetches you when time is up.</summary>
<br>

| Light | Dark |
|---|---|
| ![Focus, light](docs/screenshots/app-focus-light.png) | ![Focus, dark](docs/screenshots/app-focus-dark.png) |

</details>

<details>
<summary><b>Cat</b> · The cat's current pose live, its mood, look, size, and play buttons.</summary>
<br>

| Light | Dark |
|---|---|
| ![Cat, light](docs/screenshots/app-cat-light.png) | ![Cat, dark](docs/screenshots/app-cat-dark.png) |

</details>

<details>
<summary><b>Settings</b> · Launch at login and sliders for how busy, sleepy, and clingy the cat is.</summary>
<br>

| Light | Dark |
|---|---|
| ![Settings, light](docs/screenshots/app-settings-light.png) | ![Settings, dark](docs/screenshots/app-settings-dark.png) |

</details>

## Handy shortcuts

| Where | What |
|---|---|
| Paw icon in the menu bar | Open the app, add a to-do or note, tick things off, start a focus session |
| Control-Option-T, from any app | Quick-add a to-do |
| Right-click the cat | Change its look or size, feed it, throw the ball, put it to sleep |
| ⌘1 to ⌘8 in the app window | Jump between screens |

## Install

Requires macOS 13 or later and the Xcode command line tools (`xcode-select --install`).

```bash
git clone https://github.com/sparkingwaterr/do_it_meow.app.git
cd do_it_meow.app
make install
```

This builds the app, copies it to `/Applications`, and opens it. To install somewhere else, run `./Installer/install.sh ~/Applications`. `make uninstall` removes it.

## Privacy

Everything stays on your Mac. To-dos, notes, timers, and settings are saved in the app's own preferences. To sit on windows the cat reads where other windows are on screen, never their titles or contents. Nothing is sent anywhere.

## Develop

```bash
make run          # build into build/ and launch
make screenshots  # retake the README screenshots in light and dark with sample data
make clean        # delete build/
```

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
