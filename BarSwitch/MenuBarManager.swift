import Foundation
import SwiftUI

enum MenuBarMode: String, CaseIterable {
    case always = "Always"
    case never = "Never"

    var hidesMenuBar: Bool {
        self == .always
    }

    static func from(autohide: Bool) -> MenuBarMode {
        autohide ? .always : .never
    }
}

@MainActor
class MenuBarManager: ObservableObject {
    @Published var currentMode: MenuBarMode = .never

    private var pollTimer: Timer?

    init() {
        currentMode = readCurrentMode()
        startPolling()
    }

    deinit {
        pollTimer?.invalidate()
    }

    func readCurrentMode() -> MenuBarMode {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", "tell application \"System Events\" to tell dock preferences to get autohide menu bar"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return MenuBarMode.from(autohide: output == "true")
        } catch {
            return .never
        }
    }

    func setMode(_ mode: MenuBarMode) {
        let value = mode.hidesMenuBar ? "true" : "false"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", "tell application \"System Events\" to tell dock preferences to set autohide menu bar to \(value)"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
        } catch {}
        currentMode = mode
    }

    func toggleMode() {
        setMode(currentMode == .always ? .never : .always)
    }

    private func startPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let actual = self.readCurrentMode()
                if actual != self.currentMode {
                    self.currentMode = actual
                }
            }
        }
    }
}
