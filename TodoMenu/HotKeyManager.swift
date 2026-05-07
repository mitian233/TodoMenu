import Carbon.HIToolbox
import Foundation

final class HotKeyManager {
    var onTrigger: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    func start() {
        guard eventHandlerRef == nil, hotKeyRef == nil else {
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

        let hotKeyID = EventHotKeyID(signature: OSType(stringToFourCharCode("TMNU")), id: 1)
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_Space),
            UInt32(optionKey),
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        guard registerStatus == noErr else {
            return
        }
    }

    deinit {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
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
