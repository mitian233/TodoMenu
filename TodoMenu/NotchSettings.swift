import Foundation
import Combine

@MainActor
final class NotchSettingsManager: ObservableObject {
    static let shared = NotchSettingsManager()

    private let hapticFeedbackKey = "todoMenu.notch.hapticFeedback"

    @Published var hapticFeedback: Bool {
        didSet { save() }
    }

    private init() {
        if UserDefaults.standard.object(forKey: hapticFeedbackKey) != nil {
            self.hapticFeedback = UserDefaults.standard.bool(forKey: hapticFeedbackKey)
        } else {
            self.hapticFeedback = true
        }
    }

    private func save() {
        UserDefaults.standard.set(hapticFeedback, forKey: hapticFeedbackKey)
    }
}
