import AppKit
import SwiftUI
import Combine

@MainActor
class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var store: TodoStore
    private var cancellables = Set<AnyCancellable>()
    private var eventMonitor: EventMonitor?

    init(store: TodoStore) {
        self.store = store
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        popover.contentSize = NSSize(width: 340, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarRootView().environmentObject(store))

        updateStatusItem()

        store.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func updateStatusItem() {
        let count = store.incompleteCount
        if count == 0 {
            statusItem.button?.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "No tasks")
            statusItem.button?.title = ""
        } else {
            statusItem.button?.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "\(count) tasks")
            statusItem.button?.title = " \(count)"
        }
    }

    @objc private func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        eventMonitor = EventMonitor(mask: .leftMouseDown, useLocalMonitor: false) { [weak self] _ in
            Task { @MainActor in
                self?.closePopover()
            }
        }
        eventMonitor?.start()
    }

    private func closePopover() {
        popover.performClose(nil)
        eventMonitor?.stop()
        eventMonitor = nil
    }

    func show() {
        statusItem.isVisible = true
    }

    func hide() {
        statusItem.isVisible = false
        closePopover()
    }
}
