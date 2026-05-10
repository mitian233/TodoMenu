import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var store = TodoStore()
    var hotKeyManager = HotKeyManager()
    var quickAddWindowController: QuickAddWindowController?
    var notchWindowController: NotchWindowController?
    var statusBarController: StatusBarController?
    var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        quickAddWindowController = QuickAddWindowController(store: store)
        hotKeyManager.onTrigger = { [weak self] in
            self?.quickAddWindowController?.show()
        }
        hotKeyManager.start()

        statusBarController = StatusBarController(store: store)

        DisplayModeManager.shared.$mode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                if mode == .notch {
                    self?.showNotchWindow()
                    self?.statusBarController?.hide()
                } else {
                    self?.hideNotchWindow()
                    self?.statusBarController?.show()
                }
            }
            .store(in: &cancellables)

        if DisplayModeManager.shared.mode == .notch {
            showNotchWindow()
            statusBarController?.hide()
        }
    }

    func showNotchWindow() {
        guard let screen = NSScreen.builtin ?? NSScreen.main else { return }
        notchWindowController = NotchWindowController(screen: screen, store: store)
    }

    func hideNotchWindow() {
        notchWindowController?.destroy()
        notchWindowController = nil
    }

    @objc func showSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
