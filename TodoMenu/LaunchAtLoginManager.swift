//
//  LaunchAtLoginManager.swift
//  TodoMenu
//
//  Manages launch-at-login functionality using ServiceManagement framework.
//

import Combine
import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginManager: ObservableObject {
    @Published private(set) var isEnabled: Bool = false
    
    private let key = "launchAtLogin"
    
    init() {
        refreshStatus()
    }
    
    func toggle() {
        do {
            if isEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            refreshStatus()
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }
    
    private func refreshStatus() {
        let status = SMAppService.mainApp.status
        isEnabled = status == .enabled
    }
}
