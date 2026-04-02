import SwiftUI

@MainActor
final class AppState: ObservableObject {
    let menuBarManager = MenuBarManager()
    let loginManager = LaunchAtLoginManager()
    let shortcutManager = KeyboardShortcutManager()

    init() {
        shortcutManager.start { [weak self] in
            self?.menuBarManager.toggleMode()
        }
    }
}

@main
struct BarSwitchApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra("BarSwitch", systemImage: "menubar.rectangle") {
            // Mode toggle
            Button {
                state.menuBarManager.setMode(.always)
            } label: {
                HStack {
                    Image(systemName: state.menuBarManager.currentMode == .always ? "checkmark" : "")
                        .frame(width: 16)
                    Text("Always")
                }
            }
            Button {
                state.menuBarManager.setMode(.never)
            } label: {
                HStack {
                    Image(systemName: state.menuBarManager.currentMode == .never ? "checkmark" : "")
                        .frame(width: 16)
                    Text("Never")
                }
            }

            Divider()

            // Settings
            Button {
                state.loginManager.toggle()
            } label: {
                HStack {
                    Image(systemName: state.loginManager.isEnabled ? "checkmark" : "")
                        .frame(width: 16)
                    Text("Launch at Login")
                }
            }
            Button {
                state.shortcutManager.toggle()
            } label: {
                HStack {
                    Image(systemName: state.shortcutManager.isEnabled ? "checkmark" : "")
                        .frame(width: 16)
                    Text(state.shortcutManager.isEnabled ? "Keyboard Shortcut  ⌘⇧H" : "Keyboard Shortcut (off)")
                }
            }

            Divider()

            Button("About BarSwitch...") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.orderFrontStandardAboutPanel(options: [
                    .applicationName: "BarSwitch",
                    .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
                    .version: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
                    .credits: NSAttributedString(
                        string: "Report an Issue on GitHub",
                        attributes: [
                            .link: URL(string: "https://github.com/strawMusic/BarSwitch/issues")!,
                            .font: NSFont.systemFont(ofSize: 11)
                        ]
                    )
                ])
            }
            Button("Quit BarSwitch") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
    }
}
