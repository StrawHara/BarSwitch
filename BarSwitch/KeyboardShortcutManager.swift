import Foundation
import AppKit

@MainActor
class KeyboardShortcutManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "keyboardShortcutEnabled") }
    }

    private var eventMonitor: Any?
    private var onToggle: (() -> Void)?

    init() {
        if UserDefaults.standard.object(forKey: "keyboardShortcutEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "keyboardShortcutEnabled")
        }
        isEnabled = UserDefaults.standard.bool(forKey: "keyboardShortcutEnabled")
    }

    func start(onToggle: @escaping () -> Void) {
        self.onToggle = onToggle
        // Only register silently if already trusted — no alert during startup
        if isEnabled && AXIsProcessTrusted() {
            registerMonitor()
        }
    }

    func stop() {
        unregisterMonitor()
    }

    func toggle() {
        if isEnabled {
            // Disabling
            isEnabled = false
            unregisterMonitor()
        } else {
            // Enabling — check accessibility, show alert if needed
            if !AXIsProcessTrusted() {
                promptAccessibility()
                return
            }
            isEnabled = true
            registerMonitor()
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
        alert.informativeText = "BarSwitch needs Accessibility permission to use the global keyboard shortcut (⌘⇧H).\n\nClick \"Open Settings\" to grant access in System Settings > Privacy & Security > Accessibility."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .informational
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
}
