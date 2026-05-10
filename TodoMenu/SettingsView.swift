import SwiftUI

struct SettingsView: View {
    @StateObject private var launchManager = LaunchAtLoginManager()
    
    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: Binding(
                    get: { launchManager.isEnabled },
                    set: { _ in launchManager.toggle() }
                ))
            } header: {
                Text("General")
            } footer: {
                Text("Automatically launch TodoMenu when you log in.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 320)
        .padding()
    }
}
