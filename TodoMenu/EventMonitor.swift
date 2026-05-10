import Cocoa

class EventMonitor {
    private var globalMonitor: AnyObject?
    private var localMonitor: AnyObject?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    private let useLocalMonitor: Bool

    init(mask: NSEvent.EventTypeMask, useLocalMonitor: Bool = true, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.useLocalMonitor = useLocalMonitor
        self.handler = handler
    }

    deinit { stop() }

    func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
        if useLocalMonitor {
            localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
                self?.handler(event)
                return event
            } as AnyObject?
        }
    }

    func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        globalMonitor = nil
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        localMonitor = nil
    }
}
