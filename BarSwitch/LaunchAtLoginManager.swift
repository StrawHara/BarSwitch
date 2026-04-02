import Foundation
import ServiceManagement

@MainActor
class LaunchAtLoginManager: ObservableObject {
    @Published var isEnabled: Bool = false

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func toggle() {
        do {
            if isEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            isEnabled = SMAppService.mainApp.status == .enabled
        } catch {
            print("Launch at Login toggle failed: \(error)")
        }
    }
}
