import Foundation
import Testing
@testable import TodoMenu

struct TodoMenuTests {
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
        // Test that visibleItems properly updates when items change
        let suiteName = "TodoMenuTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        let store = TodoStore(defaults: defaults)
        
        // Initially empty
        #expect(store.visibleItems.isEmpty)
        #expect(store.items.isEmpty)
        
        // Add first item
        let task1 = try #require(store.add(title: "Task 1"))
        #expect(store.visibleItems.count == 1)
        #expect(store.visibleItems.first?.id == task1.id)
        
        // Add second item
        let task2 = try #require(store.add(title: "Task 2"))
        #expect(store.visibleItems.count == 2)
        
        // Toggle first item - should appear at end
        store.toggle(task1)
        #expect(store.visibleItems.count == 2)
        #expect(store.visibleItems.first?.id == task2.id) // Incomplete first
        #expect(store.visibleItems.last?.id == task1.id) // Completed last
        
        // Delete first item
        store.delete(task1)
        #expect(store.visibleItems.count == 1)
        #expect(store.visibleItems.first?.id == task2.id)
        
        // Delete remaining item
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
        
        // Initially 0
        #expect(store.incompleteCount == 0)
        
        // Add items
        let task1 = try #require(store.add(title: "Task 1"))
        #expect(store.incompleteCount == 1)
        
        let task2 = try #require(store.add(title: "Task 2"))
        #expect(store.incompleteCount == 2)
        
        // Toggle one
        store.toggle(task1)
        #expect(store.incompleteCount == 1)
        
        // Toggle back
        store.toggle(task1)
        #expect(store.incompleteCount == 2)
        
        // Delete one
        store.delete(task1)
        #expect(store.incompleteCount == 1)
        
        // Toggle remaining
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
        
        // Empty string
        #expect(store.add(title: "") == nil)
        #expect(store.items.isEmpty)
        
        // Whitespace only
        #expect(store.add(title: "   ") == nil)
        #expect(store.items.isEmpty)
        
        // Newlines only
        #expect(store.add(title: "\n\n") == nil)
        #expect(store.items.isEmpty)
    }
}
