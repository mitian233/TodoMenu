import Foundation
import AppKit
import Carbon.HIToolbox
import Testing
@testable import TodoMenu

struct TodoMenuTests {
    @Test
    func keyboardShortcutConvertsModifierFlagsForRegistration() {
        let flags: NSEvent.ModifierFlags = [.command, .option, .shift]
        let carbon = KeyboardShortcut.carbonModifiers(from: flags)
        let shortcut = KeyboardShortcut(keyCode: kVK_Space, modifiers: carbon)

        #expect(carbon == Int(cmdKey | optionKey | shiftKey))
        #expect(shortcut.nseventModifiers == flags)
        #expect(shortcut.displayName == "⌥⇧⌘Space")
    }

    @Test
    func keyboardShortcutUsesManualDisplayMappingForLetterKeys() {
        let shortcut = KeyboardShortcut(
            keyCode: kVK_ANSI_K,
            modifiers: Int(cmdKey)
        )

        #expect(shortcut.displayName == "⌘K")
    }

    @Test
    func keyboardShortcutNormalizesOlderModifierEncoding() {
        let legacyFlags: NSEvent.ModifierFlags = [.command, .control]
        let legacyShortcut = KeyboardShortcut(
            keyCode: kVK_Space,
            modifiers: Int(legacyFlags.rawValue)
        )
        let normalized = legacyShortcut.normalizedForRegistration()

        #expect(normalized.modifiers == Int(cmdKey | controlKey))
        #expect(normalized.nseventModifiers == legacyFlags)
    }

    @MainActor
    @Test
    func addToggleDeleteAndPersist() throws {
        let suiteName = "TodoMenuTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        let store = TodoStore(defaults: defaults)
        #expect(store.items.isEmpty)

        let added = try #require(store.add(title: "  Write release notes  "))
        #expect(added.title == "Write release notes")
        #expect(store.items.count == 1)
        #expect(store.incompleteCount == 1)

        store.toggle(added)
        #expect(store.items.first?.isDone == true)
        #expect(store.incompleteCount == 0)

        store.delete(added)
        #expect(store.items.isEmpty)

        let reloaded = TodoStore(defaults: defaults)
        #expect(reloaded.items.isEmpty)
    }

    @MainActor
    @Test
    func visibleItemsPutOpenTasksFirst() throws {
        let suiteName = "TodoMenuTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        let store = TodoStore(defaults: defaults)
        let first = try #require(store.add(title: "First"))
        let second = try #require(store.add(title: "Second"))
        store.toggle(second)

        let visible = store.visibleItems
        #expect(visible.first?.id == first.id)
        #expect(visible.last?.id == second.id)
    }
    
    @MainActor
    @Test
    func visibleItemsReflectsChanges() throws {
        let suiteName = "TodoMenuTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        let store = TodoStore(defaults: defaults)
        
        #expect(store.visibleItems.isEmpty)
        #expect(store.items.isEmpty)
        
        let task1 = try #require(store.add(title: "Task 1"))
        #expect(store.visibleItems.count == 1)
        #expect(store.visibleItems.first?.id == task1.id)
        
        let task2 = try #require(store.add(title: "Task 2"))
        #expect(store.visibleItems.count == 2)
        
        store.toggle(task1)
        #expect(store.visibleItems.count == 2)
        #expect(store.visibleItems.first?.id == task2.id)
        #expect(store.visibleItems.last?.id == task1.id)
        
        store.delete(task1)
        #expect(store.visibleItems.count == 1)
        #expect(store.visibleItems.first?.id == task2.id)
        
        store.delete(task2)
        #expect(store.visibleItems.isEmpty)
    }
    
    @MainActor
    @Test
    func incompleteCountUpdatesCorrectly() throws {
        let suiteName = "TodoMenuTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        let store = TodoStore(defaults: defaults)
        
        #expect(store.incompleteCount == 0)
        
        let task1 = try #require(store.add(title: "Task 1"))
        #expect(store.incompleteCount == 1)
        
        let task2 = try #require(store.add(title: "Task 2"))
        #expect(store.incompleteCount == 2)
        
        store.toggle(task1)
        #expect(store.incompleteCount == 1)
        
        store.toggle(task1)
        #expect(store.incompleteCount == 2)
        
        store.delete(task1)
        #expect(store.incompleteCount == 1)
        
        store.toggle(task2)
        #expect(store.incompleteCount == 0)
    }
    
    @MainActor
    @Test
    func addEmptyTaskReturnsNil() throws {
        let suiteName = "TodoMenuTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        let store = TodoStore(defaults: defaults)
        
        #expect(store.add(title: "") == nil)
        #expect(store.items.isEmpty)
        
        #expect(store.add(title: "   ") == nil)
        #expect(store.items.isEmpty)
        
        #expect(store.add(title: "\n\n") == nil)
        #expect(store.items.isEmpty)
    }
    
    @MainActor
    @Test
    func incompleteCountReflectsMultipleTasks() throws {
        let suiteName = "TodoMenuTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        let store = TodoStore(defaults: defaults)
        
        #expect(store.incompleteCount == 0)
        
        let task1 = try #require(store.add(title: "Task 1"))
        #expect(store.incompleteCount == 1)
        
        let task2 = try #require(store.add(title: "Task 2"))
        #expect(store.incompleteCount == 2)
        
        let task3 = try #require(store.add(title: "Task 3"))
        #expect(store.incompleteCount == 3)
        
        store.toggle(task2)
        #expect(store.incompleteCount == 2)
        
        store.toggle(task1)
        #expect(store.incompleteCount == 1)
        
        store.toggle(task1)
        #expect(store.incompleteCount == 2)
    }
    
    @MainActor
    @Test
    func animatedRollingNumberViewVisibility() throws {
        let view1 = AnimatedRollingNumberView(number: 0, hidesWhenZero: false)
        #expect(view1.isVisible == true)
        
        let view2 = AnimatedRollingNumberView(number: 5, hidesWhenZero: false)
        #expect(view2.isVisible == true)
        
        let view3 = AnimatedRollingNumberView(number: 0, hidesWhenZero: true)
        #expect(view3.isVisible == false)
        
        let view4 = AnimatedRollingNumberView(number: 5, hidesWhenZero: true)
        #expect(view4.isVisible == true)
    }
    
    @MainActor
    @Test
    func animatedRollingNumberViewDigitHeight() throws {
        let view1 = AnimatedRollingNumberView(number: 5)
        #expect(view1.digitHeight == 14)
        
        let view2 = AnimatedRollingNumberView(number: 5, digitHeight: 20)
        #expect(view2.digitHeight == 20)
    }
}
