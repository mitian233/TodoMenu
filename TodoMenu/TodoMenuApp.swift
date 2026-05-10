//
//  TodoMenuApp.swift
//  TodoMenu
//
//  Created by 原田蜜柑 on 2026/05/07.
//

import SwiftUI

@main
struct TodoMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
