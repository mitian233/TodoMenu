import SwiftUI

struct SettingsView: View {
    @StateObject private var launchManager = LaunchAtLoginManager()
    @ObservedObject private var displayModeManager = DisplayModeManager.shared
    
    var body: some View {
        Form {
            Section {
                Picker("Display Mode", selection: Binding(
                    get: { displayModeManager.mode },
                    set: { displayModeManager.setMode($0) }
                )) {
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
            } header: {
                Text("General")
            } footer: {
                Text("Choose how to display your todo list. Notch mode works on MacBooks with a notch.")
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle("Launch at Login", isOn: Binding(
                    get: { launchManager.isEnabled },
                    set: { _ in launchManager.toggle() }
                ))
            } header: {
                Text("Startup")
            } footer: {
                Text("Automatically launch TodoMenu when you log in.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 360)
        .padding()
    }
}
