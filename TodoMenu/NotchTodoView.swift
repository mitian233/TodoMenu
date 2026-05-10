import SwiftUI

struct NotchTodoView: View {
    @ObservedObject var store: TodoStore
    let onClose: () -> Void
    @Environment(\.openSettings) private var openSettings

    @State private var draft = ""
    @FocusState private var isInputFocused

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TodoMenu")
                    .font(.headline)
                Spacer()
                HStack(spacing: 8) {
                    HStack(spacing: 0) {
                        AnimatedRollingNumberView(number: store.incompleteCount, digitHeight: 12)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(" left")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Menu {
                        Button("Settings") { openSettings() }
                        Divider()
                        Button("Quit TodoMenu") { NSApp.terminate(nil) }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.secondary)
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                    .frame(width: 20)
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
                        ForEach(store.visibleItems) { item in
                            NotchTodoRowView(item: item, store: store)
                        }
                    }
                }
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
