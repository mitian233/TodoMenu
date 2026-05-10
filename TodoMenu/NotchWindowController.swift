import Cocoa
import SwiftUI

@MainActor
class NotchWindowController: NSWindowController {
    var viewModel: NotchViewModel?
    weak var screen: NSScreen?
    weak var store: TodoStore?

    init(screen: NSScreen, store: TodoStore) {
        self.screen = screen
        self.store = store

        let window = NotchWindow(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        super.init(window: window)

        let vm = NotchViewModel()
        self.viewModel = vm

        var notchSize = screen.notchSize
        if notchSize == .zero {
            notchSize = CGSize(width: 150, height: 28)
        }

        vm.deviceNotchRect = CGRect(
            x: screen.frame.origin.x + (screen.frame.width - notchSize.width) / 2,
            y: screen.frame.origin.y + screen.frame.height - notchSize.height,
            width: notchSize.width,
            height: notchSize.height
        )
        vm.screenRect = screen.frame
        vm.setupEventMonitors()

        let hostingView = NSHostingView(rootView: NotchView(viewModel: vm, store: store))
        hostingView.frame = screen.frame
        window.contentView = hostingView

        window.makeKeyAndOrderFront(nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func destroy() {
        viewModel?.destroy()
        viewModel = nil
        window?.close()
        window = nil
    }
}
