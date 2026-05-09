# TodoMenu Project Overview

TodoMenu is a macOS menu bar to-do app. Its goal is to make “capture a task the moment it comes to mind” take as few steps as possible.

## Goals

- Stay resident in the menu bar
- Use the global shortcut `⌥ Space` to open quick input
- Save tasks locally immediately after input
- Allow tasks to be marked as completed or deleted
- Do not show a Dock icon

## Current Implementation Conventions

- Use SwiftUI for the main interface
- Use `MenuBarExtra` as the menu bar entry point
- Use `UserDefaults` for local storage
- The shortcut and quick input window are an independent flow, and must not depend on the foreground app state
- Keep the MVP simple for now: no accounts, cloud sync, multi-device sync, project management, recurring tasks, or calendar integration

## Important Files

- [TodoMenu/TodoMenuApp.swift](TodoMenu/TodoMenuApp.swift)
- [TodoMenu/MenuBarRootView.swift](TodoMenu/MenuBarRootView.swift)
- [TodoMenu/QuickAddWindowController.swift](TodoMenu/QuickAddWindowController.swift)
- [TodoMenu/HotKeyManager.swift](TodoMenu/HotKeyManager.swift)
- [TodoMenu/TodoModels.swift](TodoMenu/TodoModels.swift)
- [TodoMenuTests/TodoMenuTests.swift](TodoMenuTests/TodoMenuTests.swift)

## Verification Criteria

After making changes, confirm at least the following two items:

1. `xcodebuild build -scheme TodoMenu -destination 'platform=macOS'`
2. `xcodebuild test -scheme TodoMenu -destination 'platform=macOS' -only-testing:TodoMenuTests`

## Coding Preferences

- Prefer keeping code short and easy to understand
- Before adding a new feature, first confirm whether it truly belongs in the MVP
- For shortcuts, windows, and app launch behavior, prefer the most stable implementation
- Avoid introducing heavier structures just for local convenience, especially if they make the menu bar tool feel bloated

## Notes

- The focus of this project is not the number of features, but the low cost of opening the app and the speed of entering tasks.
- If a change affects the goal of “capture it in one second,” adjust the design first instead of continuing to pile on features.
