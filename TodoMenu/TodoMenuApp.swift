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
        MenuBarExtra {
            MenuBarRootView()
                .environmentObject(appModel.store)
        } label: {
            MenuBarExtraLabelView(store: appModel.store)
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
private struct MenuBarExtraLabelView: View {
    @ObservedObject var store: TodoStore

    private var remainingCount: Int {
        store.incompleteCount
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: remainingCount == 0 ? "checkmark.circle.fill" : "circle")
                .imageScale(.medium)

            AnimatedRollingNumberView(
                number: remainingCount,
                digitHeight: 14,
                hidesWhenZero: true
            )
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        if remainingCount == 0 {
            return "Todo. No remaining tasks."
        }
        return "Todo. \(remainingCount) tasks remaining."
    }
}
