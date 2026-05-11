# TodoMenu

A macOS menu bar to-do app — designed to capture tasks the moment they come to mind.

Press `⌥ Space` to bring up a quick input window, type your task, and it's saved locally instantly. Lives in the menu bar with no Dock icon, zero friction task capture.

## Features

- Sits in the macOS menu bar
- Global shortcut `⌥ Space` for quick input
- Tasks saved locally on input
- Mark tasks as completed or deleted
- Notch display mode (MacBook notch adaptation)
- Launch at login
- Dark / Light mode support

## Quick Start

### Requirements

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

### Build & Run

```bash
# Clone the repo
git clone https://github.com/mitian233/TodoMenu.git
cd TodoMenu

# Build from command line
xcodebuild build -scheme TodoMenu -destination 'platform=macOS'

# Or open in Xcode
open TodoMenu.xcodeproj
# Then press ⌘R to run
```

### Run Tests

```bash
xcodebuild test -scheme TodoMenu -destination 'platform=macOS' -only-testing:TodoMenuTests
```

## Project Structure

```
TodoMenu/
├── TodoMenu/                  # Main app source
│   ├── TodoMenuApp.swift      # App entry point
│   ├── MenuBarRootView.swift  # Menu bar view
│   ├── QuickAddWindowController.swift  # Quick input window
│   ├── HotKeyManager.swift    # Global hotkey management
│   ├── TodoModels.swift       # Data models
│   ├── StatusBarController.swift  # Status bar controller
│   ├── SettingsView.swift     # Settings UI
│   ├── NotchView.swift        # Notch display
│   ├── NotchWindow.swift
│   ├── NotchWindowController.swift
│   ├── NotchViewModel.swift
│   ├── NotchTodoView.swift
│   ├── LaunchAtLoginManager.swift  # Launch at login
│   ├── DisplayMode.swift      # Display mode
│   ├── EventMonitor.swift     # Event monitoring
│   ├── ScrollingNumberView.swift  # Animated counter
│   └── Ext+NSScreen.swift     # NSScreen extension
├── TodoMenuTests/             # Unit tests
├── TodoMenuUITests/           # UI tests
└── TodoMenu.xcodeproj         # Xcode project
```

## Tech Stack

- **UI**: SwiftUI + MenuBarExtra
- **Storage**: UserDefaults (local persistence)
- **Hotkeys**: Carbon HotKey API
- **Architecture**: Zero third-party dependencies, Apple frameworks only

## Development Guidelines

1. Speed matters more than features. If a change affects "capture in one second", redesign first
2. Before adding a feature, confirm it belongs in the MVP
3. Keep code simple, avoid heavy architecture
4. For hotkeys, windows, and launch behavior, prefer the most stable implementation

## Credits

The notch display mode references and adapts code from [NotchDrop](https://github.com/Lakr233/NotchDrop) by [Lakr233](https://github.com/Lakr233). NotchDrop transforms the MacBook notch into a file drop zone, and its notch window architecture — including mask-based shape drawing, event monitoring, and animation system — served as the foundation for our notch implementation.

## License

[MIT](LICENSE)
