import Foundation
import AppKit

@MainActor
class KeyboardShortcutManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "keyboardShortcutEnabled") }
    }

    private var eventMonitor: Any?
    private var onToggle: (() -> Void)?
    private var accessibilityPollTimer: Timer?

    init() {
        if UserDefaults.standard.object(forKey: "keyboardShortcutEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "keyboardShortcutEnabled")
        }
        isEnabled = UserDefaults.standard.bool(forKey: "keyboardShortcutEnabled")
    }

    func start(onToggle: @escaping () -> Void) {
        self.onToggle = onToggle
        if isEnabled && AXIsProcessTrusted() {
            registerMonitor()
        }
    }

    func stop() {
        unregisterMonitor()
        stopAccessibilityPolling()
    }

    func toggle() {
        if isEnabled {
            isEnabled = false
            unregisterMonitor()
        } else {
            if AXIsProcessTrusted() {
                isEnabled = true
                registerMonitor()
            } else {
                promptAccessibility()
            }
        }
    }

    private func registerMonitor() {
        guard eventMonitor == nil else { return }
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let requiredFlags: NSEvent.ModifierFlags = [.command, .shift]
            let currentFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if event.keyCode == 4 && currentFlags == requiredFlags {
                Task { @MainActor in
                    self?.onToggle?()
                }
            }
        }
    }

    private func unregisterMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func promptAccessibility() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "BarSwitch needs Accessibility permission for the ⌘⇧H shortcut.\n\nGrant access in System Settings > Privacy & Security > Accessibility, then it will activate automatically."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .informational

        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            startAccessibilityPolling()
        }
    }

    /// Poll every second to detect when the user grants Accessibility permission
    private func startAccessibilityPolling() {
        stopAccessibilityPolling()
        accessibilityPollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if AXIsProcessTrusted() {
                    self.stopAccessibilityPolling()
                    self.isEnabled = true
                    self.registerMonitor()
                }
            }
        }
        // Stop polling after 60 seconds if user never grants
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            self?.stopAccessibilityPolling()
        }
    }

    private func stopAccessibilityPolling() {
        accessibilityPollTimer?.invalidate()
        accessibilityPollTimer = nil
    }
}
