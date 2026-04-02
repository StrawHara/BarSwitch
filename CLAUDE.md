# BarSwitch

macOS menu bar utility to toggle "auto-hide menu bar" setting.

## Project

- **Language**: Swift / SwiftUI
- **Target**: macOS 13+ (Ventura and later)
- **Type**: Menu bar only app (LSUIElement, no Dock icon)
- **Distribution**: Direct (unsigned DMG via GitHub Releases, not App Store)
- **License**: MIT

## Architecture

```
BarSwitch/
  BarSwitchApp.swift              — @main, AppState, MenuBarExtra menu
  MenuBarManager.swift            — Toggle via osascript, polling sync
  LaunchAtLoginManager.swift      — SMAppService wrapper
  KeyboardShortcutManager.swift   — Global ⌘⇧H, Accessibility permission
  Info.plist                      — LSUIElement, permissions descriptions
  AppIcon.icns                    — App icon (SF Symbol menubar.rectangle)
build.sh                          — Build + ad-hoc code sign
generate-icon.swift               — Generates AppIcon.icns from code
.github/workflows/release.yml    — CI: tag → universal binary → DMG → GitHub Release
```

## Build

```bash
./build.sh          # Build locally (arm64, ad-hoc signed)
open build/BarSwitch.app
```

## Release

```bash
git tag v0.X.0
git push origin main --tags
# GitHub Actions creates DMG automatically
```

## Key technical decisions

- **osascript via Process**: Only reliable way to toggle menu bar on macOS 26. NSAppleScript doesn't work from unsigned apps. `defaults write` alone doesn't apply changes.
- **Polling (2s)**: Detects changes made in System Settings. No notification API available for this preference.
- **NSEvent.addGlobalMonitorForEvents**: For ⌘⇧H shortcut. Requires Accessibility permission. App checks AXIsProcessTrusted() and prompts user.
- **Combine forwarding**: Nested ObservableObjects don't auto-propagate objectWillChange in SwiftUI. AppState forwards from all managers.
- **No sandbox**: Required for AppleScript access to System Events / Dock preferences. Blocks App Store distribution.

## Conventions

- No Xcode project — builds with `swiftc` directly
- Version in `Info.plist` CFBundleShortVersionString
- Commits co-authored with Claude
