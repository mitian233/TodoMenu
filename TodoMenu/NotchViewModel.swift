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

    enum OpenReason: String, Codable, Hashable, Equatable {
        case click
        case drag
        case boot
        case unknown
    }

    var notchOpenedRect: CGRect {
        CGRect(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }

    var headlineOpenedRect: CGRect {
        CGRect(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - deviceNotchRect.height,
            width: notchOpenedSize.width,
            height: deviceNotchRect.height
        )
    }

    @Published var status: Status = .closed
    @Published var openReason: OpenReason = .unknown
    @Published var deviceNotchRect: CGRect = .zero
    @Published var screenRect: CGRect = .zero
    @Published var spacing: CGFloat = 16
    @Published var notchVisible: Bool = true
    @Published var hapticFeedback: Bool = true
    @Published var optionKeyPressed: Bool = false

    let hapticSender = PassthroughSubject<Void, Never>()

    init() {
        setupCancellables()
    }

    func notchOpen(_ reason: OpenReason = .click) {
        openReason = reason
        status = .opened
        NSApp.activate(ignoringOtherApps: true)
    }

    func notchClose() {
        openReason = .unknown
        status = .closed
    }

    func notchPop() {
        openReason = .unknown
        status = .popping
    }

    func setupCancellables() {
        let events = EventMonitors.shared

        events.mouseDown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let mouseLocation = NSEvent.mouseLocation
                switch status {
                case .opened:
                    if !notchOpenedRect.contains(mouseLocation) {
                        notchClose()
                    } else if deviceNotchRect.insetBy(dx: -4, dy: -4).contains(mouseLocation) {
                        notchClose()
                    } else if headlineOpenedRect.contains(mouseLocation) {
                        // TODO: toggle content type when header views are implemented
                    }
                case .closed, .popping:
                    if deviceNotchRect.insetBy(dx: -4, dy: -4).contains(mouseLocation) {
                        notchOpen(.click)
                    }
                }
            }
            .store(in: &cancellables)

        // TODO: subscribe to events.optionKeyPress when option key handling is needed

        events.mouseLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let mouseLocation = NSEvent.mouseLocation
                let aboutToOpen = deviceNotchRect.insetBy(dx: -4, dy: -4).contains(mouseLocation)
                if status == .closed, aboutToOpen { notchPop() }
                if status == .popping, !aboutToOpen { notchClose() }
            }
            .store(in: &cancellables)

        $status
            .filter { $0 != .closed }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                withAnimation { self?.notchVisible = true }
            }
            .store(in: &cancellables)

        $status
            .filter { $0 == .popping }
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard NSEvent.pressedMouseButtons == 0 else { return }
                self?.hapticSender.send()
            }
            .store(in: &cancellables)

        hapticSender
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard self?.hapticFeedback ?? false else { return }
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .levelChange,
                    performanceTime: .now
                )
            }
            .store(in: &cancellables)

        $status
            .debounce(for: 0.5, scheduler: DispatchQueue.global())
            .filter { $0 == .closed }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.notchVisible = false
                }
            }
            .store(in: &cancellables)
    }

    func destroy() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
