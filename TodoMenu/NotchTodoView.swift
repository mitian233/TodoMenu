import SwiftUI

struct NotchTodoView: View {
    @ObservedObject var store: TodoStore
    let onClose: () -> Void

    @State private var draft = ""
    @FocusState private var isInputFocused

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TodoMenu")
                    .font(.headline)
                Spacer()
                HStack(spacing: 12) {
                    Text("\(store.incompleteCount) left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            TextField("Add a task...", text: $draft)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .onSubmit {
                    submitTask()
                }

            if store.visibleItems.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No tasks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(store.visibleItems.prefix(5)) { item in
                            NotchTodoRowView(item: item, store: store)
                        }
                        if store.visibleItems.count > 5 {
                            Text("+\(store.visibleItems.count - 5) more")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }

            HStack {
                SettingsLink {
                    Text("Settings")
                }
                .buttonStyle(.borderless)
                .font(.caption)

                Spacer()

                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }

    private func submitTask() {
        let cleaned = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            _ = store.add(title: cleaned)
        }
        draft = ""
    }
}

struct NotchTodoRowView: View {
    let item: TodoItem
    @ObservedObject var store: TodoStore

    var body: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    store.toggle(item)
                }
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .imageScale(.small)
                    .foregroundStyle(item.isDone ? Color.secondary : .white)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.subheadline)
                .foregroundStyle(item.isDone ? Color.secondary : .white)
                .lineLimit(1)
                .strikethrough(item.isDone, color: .secondary)

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    store.delete(item)
                }
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}
