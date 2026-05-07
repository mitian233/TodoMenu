//
//  TodoMenuApp.swift
//  TodoMenu
//
//  Created by 原田蜜柑 on 2026/05/07.
//

import SwiftUI

@main
struct TodoMenuApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        MenuBarExtra("Todo", systemImage: "checkmark.circle.fill") {
            MenuBarRootView()
                .environmentObject(appModel.store)
        }
        .menuBarExtraStyle(.window)
    }
}
