# BarSwitch

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![GitHub release](https://img.shields.io/github/v/release/StrawHara/BarSwitch)
![License](https://img.shields.io/github/license/StrawHara/BarSwitch)
![Downloads](https://img.shields.io/github/downloads/StrawHara/BarSwitch/total)

A tiny macOS menu bar utility to toggle **"Automatically hide and show the menu bar"** with a single click — no need to dig through System Settings.

## Features

- **One-click toggle** between Always (auto-hide) and Never (always visible)
- **Global keyboard shortcut** — ⌘⇧H to toggle from anywhere (can be disabled)
- **Launch at Login** — start automatically with your Mac
- **Syncs with System Settings** — reflects changes made outside the app
- **Lives in the menu bar** — no Dock icon, no window, completely unobtrusive

## Install

### Download

1. Go to [Releases](https://github.com/StrawHara/BarSwitch/releases/latest)
2. Download `BarSwitch-vX.X.X.dmg`
3. Open the DMG and drag **BarSwitch** to Applications

### First launch

Since the app is not notarized yet, macOS will block it on first launch. To open it:

1. Right-click (or Control-click) on **BarSwitch.app**
2. Select **Open**
3. Click **Open** in the dialog

You only need to do this once.

### Build from source

```bash
git clone https://github.com/StrawHara/BarSwitch.git
cd BarSwitch
./build.sh
open build/BarSwitch.app
```

Requires Xcode Command Line Tools and macOS 13+.

## Usage

Click the menu bar icon to see the options:

```
 ┌──────────────────────────────────┐
 │  ✓ Always                        │
 │    Never                          │
 │ ──────────────────────────────── │
 │    Launch at Login                │
 │    Keyboard Shortcut  ⌘⇧H        │
 │ ──────────────────────────────── │
 │    About BarSwitch...             │
 │    Quit BarSwitch           ⌘Q   │
 └──────────────────────────────────┘
```

- **Always** — menu bar auto-hides, hover at the top to reveal it
- **Never** — menu bar is always visible
- **⌘⇧H** — toggle between the two modes from any app (requires Accessibility permission)

## System Requirements

- macOS 13 (Ventura) or later
- Apple Silicon or Intel

## License

MIT

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/StrawHara/BarSwitch).
