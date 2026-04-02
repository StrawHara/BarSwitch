import SwiftUI

struct AboutView: View {
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    private let githubURL = URL(string: "https://github.com/strawMusic/BarSwitch/issues")!

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "menubar.rectangle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("BarSwitch")
                .font(.title.bold())

            Text("Version \(version)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Report an Issue") {
                NSWorkspace.shared.open(githubURL)
            }
            .buttonStyle(.link)

            Text("Copyright \u{00A9} 2026 BarSwitch")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(32)
        .frame(width: 280)
    }
}
