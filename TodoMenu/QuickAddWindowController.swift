import AppKit
import SwiftUI

@MainActor
final class QuickAddWindowController {
    private let store: TodoStore
    private var panel: NSPanel?

    init(store: TodoStore) {
        self.store = store
        self.panel = makePanel()
    }

    func show() {
        guard let panel else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        panel.center()
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel?.orderOut(nil)
    }

    private func makePanel() -> NSPanel {
        let rootView = AnyView(
            QuickAddWindowView(onClose: { [weak self] in
                self?.close()
            })
            .environmentObject(store)
        )

        let hostingController = NSHostingController(rootView: rootView)
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 180),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.contentViewController = hostingController
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true

        return panel
    }
}

struct QuickAddWindowView: View {
    @EnvironmentObject private var store: TodoStore

    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TaskComposerView(
                title: "What needs to be done?",
                placeholder: "Add a task",
                onSubmit: { title in
                    store.add(title: title)
                },
                onSubmitAndClose: { title in
                    store.add(title: title)
                    onClose()
                },
                onClose: onClose
            )
        }
        .padding(16)
        .frame(width: 320)
    }
}
