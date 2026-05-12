import Carbon.HIToolbox
import Foundation
import Combine

final class HotKeyManager {
    var onTrigger: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var cancellables = Set<AnyCancellable>()

    func start() {
        guard eventHandlerRef == nil else {
            return
        }

        let eventTypes = [
            EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            )
        ]

        let installStatus = InstallEventHandler(
            GetEventDispatcherTarget(),
            hotKeyHandler,
            eventTypes.count,
            eventTypes,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        guard installStatus == noErr else {
            return
        }

        HotKeySettingsManager.shared.$shortcut
            .combineLatest(HotKeySettingsManager.shared.$isCapturingShortcut)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, isCapturing in
                self?.syncHotKeyRegistration(isCapturing: isCapturing)
            }
            .store(in: &cancellables)
    }

    private func syncHotKeyRegistration(isCapturing: Bool) {
        if isCapturing {
            unregisterHotKey()
            return
        }

        unregisterHotKey()
        registerHotKey()
    }

    private func registerHotKey() {
        let shortcut = HotKeySettingsManager.shared.shortcut
        let hotKeyID = EventHotKeyID(signature: OSType(stringToFourCharCode("TMNU")), id: 1)
        let registerStatus = RegisterEventHotKey(
            UInt32(shortcut.keyCode),
            UInt32(shortcut.modifiers),
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        guard registerStatus == noErr else {
            return
        }
    }

    private func unregisterHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }

    deinit {
        unregisterHotKey()
    }
}

private let hotKeyHandler: EventHandlerUPP = { _, _, userData in
    guard let userData else {
        return noErr
    }

    let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
    manager.onTrigger?()
    return noErr
}

private func stringToFourCharCode(_ string: String) -> FourCharCode {
    var result: FourCharCode = 0
    for scalar in string.unicodeScalars.prefix(4) {
        result = (result << 8) + FourCharCode(scalar.value)
    }
    return result
}
