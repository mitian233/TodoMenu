import Foundation
import Combine
import Cocoa

struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool
    var createdAt: Date
}

@MainActor
final class TodoStore: ObservableObject {
    private let defaults: UserDefaults
    private let storageKey = "todo-menu.items"

    @Published private(set) var items: [TodoItem] = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    var incompleteCount: Int {
        items.filter { !$0.isDone }.count
    }

    var visibleItems: [TodoItem] {
        items.sorted { lhs, rhs in
            if lhs.isDone != rhs.isDone {
                return lhs.isDone == false && rhs.isDone == true
            }

            return lhs.createdAt > rhs.createdAt
        }
    }

    @discardableResult
    func add(title: String) -> TodoItem? {
        let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            return nil
        }

        let item = TodoItem(
            id: UUID(),
            title: cleaned,
            isDone: false,
            createdAt: .now
        )

        items.insert(item, at: 0)
        save()
        return item
    }

    func toggle(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items[index].isDone.toggle()
        save()
    }

    func delete(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items.remove(at: index)
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else {
            items = []
            return
        }

        do {
            items = try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            items = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            defaults.set(data, forKey: storageKey)
        } catch {
        }
    }
}
