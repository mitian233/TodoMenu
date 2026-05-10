import Foundation
import Combine

enum DisplayMode: String, CaseIterable {
    case menuBar = "menuBar"
    case notch = "notch"

    var displayName: String {
        switch self {
        case .menuBar: return "Menu Bar"
        case .notch: return "Notch"
        }
    }
}

@MainActor
final class DisplayModeManager: ObservableObject {
    static let shared = DisplayModeManager()

    private let key = "todoMenu.displayMode"

    @Published private(set) var mode: DisplayMode {
        didSet { save() }
    }

    private init() {
        if let stored = UserDefaults.standard.string(forKey: key),
           let mode = DisplayMode(rawValue: stored) {
            self.mode = mode
        } else {
            self.mode = .menuBar
        }
    }

    func setMode(_ newMode: DisplayMode) {
        mode = newMode
    }

    private func save() {
        UserDefaults.standard.set(mode.rawValue, forKey: key)
    }
}
