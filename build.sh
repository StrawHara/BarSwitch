#!/bin/bash
set -e

APP_NAME="BarSwitch"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

SOURCES=(
    BarSwitch/BarSwitchApp.swift
    BarSwitch/MenuBarManager.swift
    BarSwitch/LaunchAtLoginManager.swift
    BarSwitch/KeyboardShortcutManager.swift
    BarSwitch/AboutView.swift
)

# Clean
rm -rf "$BUILD_DIR"

# Create app bundle structure
mkdir -p "$MACOS" "$RESOURCES"

# Compile
swiftc \
    -parse-as-library \
    -target arm64-apple-macosx13.0 \
    -framework SwiftUI \
    -framework AppKit \
    -framework ServiceManagement \
    -o "$MACOS/$APP_NAME" \
    "${SOURCES[@]}"

# Copy resources
cp BarSwitch/Info.plist "$CONTENTS/Info.plist"
cp BarSwitch/AppIcon.icns "$RESOURCES/AppIcon.icns"

echo "Built $APP_BUNDLE"
echo "Run with: open $APP_BUNDLE"
