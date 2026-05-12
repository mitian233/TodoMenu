import Foundation
import Carbon.HIToolbox
import AppKit
import Combine

struct KeyboardShortcut: Codable, Equatable {
    var keyCode: Int
    var modifiers: Int

    static let defaultShortcut = KeyboardShortcut(keyCode: kVK_Space, modifiers: optionKey)

    var displayName: String {
        var parts: [String] = []
        let flags = nseventModifiers

        if flags.contains(.control) { parts.append("⌃") }
        if flags.contains(.option) { parts.append("⌥") }
        if flags.contains(.shift) { parts.append("⇧") }
        if flags.contains(.command) { parts.append("⌘") }

        parts.append(keyCodeToString(keyCode))
        return parts.joined()
    }

    var nseventModifiers: NSEvent.ModifierFlags {
        var flags = NSEvent.ModifierFlags()
        if modifiers & Int(controlKey) != 0 { flags.insert(.control) }
        if modifiers & Int(optionKey) != 0 { flags.insert(.option) }
        if modifiers & Int(shiftKey) != 0 { flags.insert(.shift) }
        if modifiers & Int(cmdKey) != 0 { flags.insert(.command) }
        return flags
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> Int {
        var carbonFlags = 0
        if flags.contains(.control) { carbonFlags |= Int(controlKey) }
        if flags.contains(.option) { carbonFlags |= Int(optionKey) }
        if flags.contains(.shift) { carbonFlags |= Int(shiftKey) }
        if flags.contains(.command) { carbonFlags |= Int(cmdKey) }
        return carbonFlags
    }

    func normalizedForRegistration() -> KeyboardShortcut {
        let knownCarbonMask = Int(controlKey | optionKey | shiftKey | cmdKey)
        let usesOnlyCarbonBits = modifiers & ~knownCarbonMask == 0

        guard !usesOnlyCarbonBits else {
            return self
        }

        let flags = NSEvent.ModifierFlags(rawValue: UInt(modifiers))
            .intersection(.deviceIndependentFlagsMask)

        return KeyboardShortcut(
            keyCode: keyCode,
            modifiers: KeyboardShortcut.carbonModifiers(from: flags)
        )
    }

    private func keyCodeToString(_ keyCode: Int) -> String {
        switch keyCode {
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Delete: return "⌫"
        case kVK_Escape: return "⎋"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        default:
            let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
            let layoutDataRef = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
            guard let layoutDataRef else { return "?" }
            let layoutData = unsafeBitCast(layoutDataRef, to: CFData.self)
            let layout = unsafeBitCast(CFDataGetBytePtr(layoutData), to: UnsafePointer<UCKeyboardLayout>.self)

            var deadKeyState: UInt32 = 0
            var length: Int = 0
            var chars = [UniChar](repeating: 0, count: 4)

            let status = UCKeyTranslate(
                layout,
                UInt16(keyCode),
                UInt16(kUCKeyActionDisplay),
                0,
                UInt32(LMGetKbdType()),
                UInt32(kUCKeyTranslateNoDeadKeysBit),
                &deadKeyState,
                chars.count,
                &length,
                &chars
            )

            if status == noErr, length > 0 {
                return String(utf16CodeUnits: chars, count: length).uppercased()
            }
            return "?"
        }
    }
}

@MainActor
final class HotKeySettingsManager: ObservableObject {
    static let shared = HotKeySettingsManager()

    private let key = "todoMenu.keyboardShortcut"
    @Published private(set) var isCapturingShortcut = false

    @Published var shortcut: KeyboardShortcut {
        didSet { save() }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data) {
            self.shortcut = shortcut.normalizedForRegistration()
        } else {
            self.shortcut = .defaultShortcut
        }
    }

    func setShortcut(_ newShortcut: KeyboardShortcut) {
        shortcut = newShortcut.normalizedForRegistration()
    }

    func resetToDefault() {
        shortcut = .defaultShortcut
    }

    func beginShortcutCapture() {
        isCapturingShortcut = true
    }

    func endShortcutCapture() {
        isCapturingShortcut = false
    }

    private func save() {
        if let data = try? JSONEncoder().encode(shortcut) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
