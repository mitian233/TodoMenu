import Cocoa
import Combine
import SwiftUI

@MainActor
class NotchViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()

    let animation: Animation = .interactiveSpring(
        duration: 0.5,
        extraBounce: 0.25,
        blendDuration: 0.125
    )

    let notchOpenedSize: CGSize = CGSize(width: 400, height: 200)

    enum Status: Equatable {
        case closed
        case opened
        case popping
    }

    var notchOpenedRect: CGRect {
        CGRect(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }

    @Published private(set) var status: Status = .closed
    @Published var deviceNotchRect: CGRect = .zero
    @Published var screenRect: CGRect = .zero

    private var mouseMoveMonitor: EventMonitor?
    private var mouseDownMonitor: EventMonitor?

    func notchOpen() {
        status = .opened
        NSApp.activate(ignoringOtherApps: true)
    }

    func notchClose() {
        status = .closed
    }

    func notchPop() {
        status = .popping
    }

    func setupEventMonitors() {
        mouseMoveMonitor = EventMonitor(mask: .mouseMoved) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let mouseLocation = NSEvent.mouseLocation
                let inNotch = self.deviceNotchRect.insetBy(dx: -4, dy: -4).contains(mouseLocation)

                if self.status == .closed, inNotch {
                    self.notchPop()
                } else if self.status == .popping, !inNotch {
                    self.notchClose()
                }
            }
        }
        mouseMoveMonitor?.start()

        mouseDownMonitor = EventMonitor(mask: .leftMouseDown) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let mouseLocation = NSEvent.mouseLocation

                switch self.status {
                case .opened:
                    if !self.notchOpenedRect.contains(mouseLocation) {
                        self.notchClose()
                    } else if self.deviceNotchRect.insetBy(dx: -4, dy: -4).contains(mouseLocation) {
                        self.notchClose()
                    }
                case .closed, .popping:
                    if self.deviceNotchRect.insetBy(dx: -4, dy: -4).contains(mouseLocation) {
                        self.notchOpen()
                    }
                }
            }
        }
        mouseDownMonitor?.start()
    }

    func destroy() {
        mouseMoveMonitor?.stop()
        mouseDownMonitor?.stop()
        mouseMoveMonitor = nil
        mouseDownMonitor = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
