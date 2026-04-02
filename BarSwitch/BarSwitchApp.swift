import SwiftUI
import Combine

let githubIssuesURL = URL(string: "https://github.com/StrawHara/BarSwitch/issues")

@MainActor
final class AppState: ObservableObject {
    let menuBarManager = MenuBarManager()
    let loginManager = LaunchAtLoginManager()
    let shortcutManager = KeyboardShortcutManager()

    private var cancellables = Set<AnyCancellable>()

    init() {
        menuBarManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)

        loginManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)

        shortcutManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)

        shortcutManager.start { [weak self] in
            self?.menuBarManager.toggleMode()
        }
    }

    func cleanup() {
        shortcutManager.stop()
        menuBarManager.cleanup()
    }
}

@main
struct BarSwitchApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra("BarSwitch", systemImage: "menubar.rectangle") {
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
                var options: [NSApplication.AboutPanelOptionKey: Any] = [
                    .applicationName: "BarSwitch",
                    .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
                    .version: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
                ]
                if let url = githubIssuesURL {
                    options[.credits] = NSAttributedString(
                        string: "Report an Issue on GitHub",
                        attributes: [.link: url, .font: NSFont.systemFont(ofSize: 11)]
                    )
                }
                NSApp.orderFrontStandardAboutPanel(options: options)
            }
            Button("Quit BarSwitch") {
                state.cleanup()
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
    }
}
