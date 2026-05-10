import Cocoa
import SwiftUI

private let notchHeight: CGFloat = 200

class NotchWindowController: NSWindowController {
    var viewModel: NotchViewModel?
    weak var screen: NSScreen?
    weak var store: TodoStore?

    init(window: NSWindow, screen: NSScreen, store: TodoStore) {
        self.screen = screen
        self.store = store

        super.init(window: window)

        var notchSize = screen.notchSize

        let vm = NotchViewModel()
        self.viewModel = vm

        contentViewController = NotchViewController(viewModel: vm, store: self.store!)

        if notchSize == .zero {
            notchSize = CGSize(width: 150, height: 28)
        }
        vm.deviceNotchRect = CGRect(
            x: screen.frame.origin.x + (screen.frame.width - notchSize.width) / 2,
            y: screen.frame.origin.y + screen.frame.height - notchSize.height,
            width: notchSize.width,
            height: notchSize.height
        )
        window.makeKeyAndOrderFront(nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak vm] in
            vm?.screenRect = screen.frame
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    convenience init(screen: NSScreen, store: TodoStore) {
        let window = NotchWindow(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        self.init(window: window, screen: screen, store: store)

        let topRect = CGRect(
            x: screen.frame.origin.x,
            y: screen.frame.origin.y + screen.frame.height - notchHeight,
            width: screen.frame.width,
            height: notchHeight
        )
        window.setFrameOrigin(topRect.origin)
        window.setContentSize(topRect.size)
    }

    deinit {
        destroy()
    }

    func destroy() {
        viewModel?.destroy()
        viewModel = nil
        window?.close()
        contentViewController = nil
        window = nil
    }
}

class NotchViewController: NSHostingController<NotchView> {
    init(viewModel: NotchViewModel, store: TodoStore) {
        super.init(rootView: NotchView(viewModel: viewModel, store: store))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}
