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
}
