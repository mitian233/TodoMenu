//
//  TodoMenuApp.swift
//  TodoMenu
//
//  Created by 原田蜜柑 on 2026/05/07.
//

import SwiftUI

@main
struct TodoMenuApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarRootView()
                .environmentObject(appModel.store)
        } label: {
            MenuBarCounterLabel(store: appModel.store)
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
private struct MenuBarCounterLabel: View {
    @ObservedObject var store: TodoStore

    var body: some View {
        let count = store.incompleteCount
        HStack(spacing: 4) {
            Image(systemName: count == 0 ? "checkmark.circle.fill" : "circle")
                .imageScale(.medium)

            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(count == 0 ? "Todo. No remaining tasks." : "Todo. \(count) tasks remaining.")
    }
}
