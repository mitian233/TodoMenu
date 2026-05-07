# TodoMenu 项目说明

这是一个 macOS 菜单栏待办工具，目标是把“想到任务，立刻记下”这件事做到最省步骤。

## 目标

- 菜单栏常驻
- 全局快捷键 `⌥ Space` 呼出快速输入
- 输入后可直接保存到本机
- 任务可勾选完成、删除
- 不显示 Dock 图标

## 现在的实现约定

- 使用 SwiftUI 作为主界面
- 使用 `MenuBarExtra` 作为菜单栏入口
- 使用 `UserDefaults` 做本地存储
- 快捷键和快速输入窗是独立链路，不能互相依赖前台 App 状态
- 先保持 MVP 简单，不加账号、云同步、多端同步、项目管理、重复任务、日历集成

## 重要文件

- [TodoMenu/TodoMenuApp.swift](/Users/mikan/XcodeProjects/TodoMenu/TodoMenu/TodoMenuApp.swift)
- [TodoMenu/MenuBarRootView.swift](/Users/mikan/XcodeProjects/TodoMenu/TodoMenu/MenuBarRootView.swift)
- [TodoMenu/QuickAddWindowController.swift](/Users/mikan/XcodeProjects/TodoMenu/TodoMenu/QuickAddWindowController.swift)
- [TodoMenu/HotKeyManager.swift](/Users/mikan/XcodeProjects/TodoMenu/TodoMenu/HotKeyManager.swift)
- [TodoMenu/TodoModels.swift](/Users/mikan/XcodeProjects/TodoMenu/TodoMenu/TodoModels.swift)
- [TodoMenuTests/TodoMenuTests.swift](/Users/mikan/XcodeProjects/TodoMenu/TodoMenuTests/TodoMenuTests.swift)

## 验证标准

修改后至少确认以下两项：

1. `xcodebuild build -scheme TodoMenu -destination 'platform=macOS'`
2. `xcodebuild test -scheme TodoMenu -destination 'platform=macOS' -only-testing:TodoMenuTests`

## 编码习惯

- 优先保持代码短而直观
- 新增功能先确认是否真的属于 MVP
- 涉及快捷键、窗口、App 启动行为时，优先做最稳的实现
- 不要因为局部方便引入会让菜单栏工具变重的结构

## 备注

- 这个项目的重点不是功能数量，而是打开成本和输入速度。
- 如果改动会影响“1 秒记下来”这个目标，应该优先调整设计，而不是继续堆功能。
