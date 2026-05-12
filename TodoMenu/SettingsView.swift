import SwiftUI
import Carbon.HIToolbox

struct SettingsView: View {
    @StateObject private var launchManager = LaunchAtLoginManager()
    @ObservedObject private var displayModeManager = DisplayModeManager.shared
    @ObservedObject private var hotKeySettings = HotKeySettingsManager.shared
    @ObservedObject private var notchSettings = NotchSettingsManager.shared
    @State private var isRecordingShortcut = false
    @State private var eventMonitor: Any?

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

            Section {
                HStack {
                    Text("Quick Add Shortcut")
                    Spacer()
                    Button(action: {
                        if isRecordingShortcut {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        Text(isRecordingShortcut ? "Press keys..." : hotKeySettings.shortcut.displayName)
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.bordered)

                    Button(action: {
                        hotKeySettings.resetToDefault()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderless)
                    .help("Reset to default (⌥Space)")
                }
            } header: {
                Text("Keyboard")
            } footer: {
                Text("Click to record a new keyboard shortcut. Press at least one modifier key (⌘, ⌥, ⌃, ⇧) with another key.")
                    .foregroundStyle(.secondary)
            }

            if displayModeManager.mode == .notch {
                Section {
                    Toggle("Haptic Feedback", isOn: $notchSettings.hapticFeedback)
                } header: {
                    Text("Notch")
                } footer: {
                    Text("Enable haptic feedback when hovering over the notch area.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 360)
        .padding()
        .onDisappear {
            stopRecording()
        }
    }

    private func startRecording() {
        guard !isRecordingShortcut else { return }
        isRecordingShortcut = true
        hotKeySettings.beginShortcutCapture()

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            let validModifiers: NSEvent.ModifierFlags = [.command, .option, .control, .shift]
            let modifierOnly = modifiers.subtracting(validModifiers).isEmpty

            guard modifierOnly, !modifiers.isEmpty else {
                return nil
            }

            let shortcut = KeyboardShortcut(
                keyCode: Int(event.keyCode),
                modifiers: KeyboardShortcut.carbonModifiers(from: modifiers)
            )
            hotKeySettings.setShortcut(shortcut)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecordingShortcut = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        hotKeySettings.endShortcutCapture()
    }
}
