import Foundation
import SwiftUI
import os

private let logger = Logger(subsystem: "com.barswitch.app", category: "MenuBar")

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
    private var skipNextPoll = false

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
            logger.error("Failed to read menu bar mode: \(error.localizedDescription)")
            return .never
        }
    }

    func setMode(_ mode: MenuBarMode) {
        skipNextPoll = true

        let value = mode.hidesMenuBar ? "true" : "false"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", "tell application \"System Events\" to tell dock preferences to set autohide menu bar to \(value)"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                currentMode = mode
            } else {
                logger.error("osascript exited with code \(process.terminationStatus)")
            }
        } catch {
            logger.error("Failed to set menu bar mode: \(error.localizedDescription)")
        }
    }

    func toggleMode() {
        setMode(currentMode == .always ? .never : .always)
    }

    func cleanup() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    private func startPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.skipNextPoll {
                    self.skipNextPoll = false
                    return
                }
                let actual = self.readCurrentMode()
                if actual != self.currentMode {
                    self.currentMode = actual
                }
            }
        }
    }
}
