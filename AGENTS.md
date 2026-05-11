# TodoMenu — AI Agent Guidelines

macOS menu bar to-do app. Core goal: let users capture tasks with minimal steps.

## Implementation Conventions

- SwiftUI + `MenuBarExtra` as the menu bar entry point
- `UserDefaults` for local storage
- Global shortcut and quick input window are independent flows, must not depend on foreground app state
- MVP scope: no accounts, cloud sync, multi-device sync, project management, recurring tasks, or calendar integration

## Important Files

- `TodoMenu/TodoMenuApp.swift` — App entry point
- `TodoMenu/MenuBarRootView.swift` — Menu bar view
- `TodoMenu/QuickAddWindowController.swift` — Quick input window
- `TodoMenu/HotKeyManager.swift` — Global hotkey management
- `TodoMenu/TodoModels.swift` — Data models
- `TodoMenuTests/TodoMenuTests.swift` — Unit tests

## Verification Criteria

After making changes, confirm at least:

1. `xcodebuild build -scheme TodoMenu -destination 'platform=macOS'`
2. `xcodebuild test -scheme TodoMenu -destination 'platform=macOS' -only-testing:TodoMenuTests`

## Coding Preferences

- Keep code short and easy to understand
- Before adding a new feature, first confirm whether it truly belongs in the MVP
- For shortcuts, windows, and app launch behavior, prefer the most stable implementation
- Avoid introducing heavier structures just for local convenience, especially if they make the menu bar tool feel bloated

## Notes

- The focus of this project is not the number of features, but the low cost of opening the app and the speed of entering tasks
- If a change affects the goal of "capture it in one second", adjust the design first instead of continuing to pile on features
