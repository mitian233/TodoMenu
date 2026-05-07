import AppKit
import SwiftUI

struct MenuBarRootView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TaskComposerView(
                title: "Add a task",
                placeholder: "What should not be forgotten?",
                onSubmit: { title in
                    store.add(title: title)
                },
                onSubmitAndClose: { title in
                    store.add(title: title)
                    dismiss()
                },
                onClose: {
                    dismiss()
                }
            )

            Divider()

            TodoListView()

            Divider()

            HStack {
                HStack(spacing: 0) {
                    Text("Today: ")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    ScrollingNumberView(number: store.incompleteCount)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Text(" left")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("taskCounter")

                Spacer()

                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(12)
        .frame(width: 340)
    }
}

struct TodoListView: View {
    @EnvironmentObject private var store: TodoStore

    private var listHeight: CGFloat {
        let rowHeight: CGFloat = 28
        let rowSpacing: CGFloat = 8
        let count = store.visibleItems.count
        let contentHeight = (CGFloat(count) * rowHeight) + (CGFloat(max(count - 1, 0)) * rowSpacing)
        return min(max(contentHeight, 44), 220)
    }

    var body: some View {
        Group {
            if store.items.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No tasks yet")
                        .font(.subheadline)
                    Text("Type one above and press Return.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 72)
                .padding(.vertical, 12)
                .accessibilityIdentifier("emptyState")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(store.visibleItems) { item in
                            TodoRowView(item: item)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: listHeight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct TodoRowView: View {
    @EnvironmentObject private var store: TodoStore

    let item: TodoItem

    var body: some View {
        HStack(spacing: 8) {
            Button {
                store.toggle(item)
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .imageScale(.medium)
                    .foregroundStyle(item.isDone ? .secondary : .primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isDone ? "Mark as not done" : "Mark as done")
            .accessibilityIdentifier("toggleButton")

            Text(item.title)
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(role: .destructive) {
                store.delete(item)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete task")
            .accessibilityIdentifier("deleteButton")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .accessibilityIdentifier("taskRow_\(item.id)")
    }
}

struct TaskComposerView: View {
    @State private var draft = ""

    let title: String
    let placeholder: String
    let onSubmit: (String) -> Void
    let onSubmitAndClose: (String) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            ShortcutTextField(
                text: $draft,
                placeholder: placeholder,
                onSubmit: {
                    commit(closeAfterSubmit: false)
                },
                onSubmitAndClose: {
                    commit(closeAfterSubmit: true)
                },
                onCancel: onClose
            )
            .frame(height: 28)
            .accessibilityIdentifier("taskInputField")

            Text("Enter 保存 · ⌘+Enter 保存并关闭 · Esc 关闭")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func commit(closeAfterSubmit: Bool) {
        let cleaned = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            if closeAfterSubmit {
                onClose()
            }
            return
        }

        if closeAfterSubmit {
            onSubmitAndClose(cleaned)
        } else {
            onSubmit(cleaned)
            draft = ""
        }
    }
}

struct ShortcutTextField: NSViewRepresentable {
    @Binding var text: String

    let placeholder: String
    let onSubmit: () -> Void
    let onSubmitAndClose: () -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            onSubmit: onSubmit,
            onSubmitAndClose: onSubmitAndClose,
            onCancel: onCancel
        )
    }

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField(string: text)
        field.placeholderString = placeholder
        field.delegate = context.coordinator
        field.isEditable = true
        field.isSelectable = true
        field.isBezeled = true
        field.bezelStyle = .roundedBezel
        field.drawsBackground = true
        field.focusRingType = .none
        field.font = .systemFont(ofSize: NSFont.systemFontSize)

        DispatchQueue.main.async {
            field.window?.makeFirstResponder(field)
        }

        return field
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }

        context.coordinator.text = $text
        context.coordinator.onSubmit = onSubmit
        context.coordinator.onSubmitAndClose = onSubmitAndClose
        context.coordinator.onCancel = onCancel
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var text: Binding<String>
        var onSubmit: () -> Void
        var onSubmitAndClose: () -> Void
        var onCancel: () -> Void

        init(
            text: Binding<String>,
            onSubmit: @escaping () -> Void,
            onSubmitAndClose: @escaping () -> Void,
            onCancel: @escaping () -> Void
        ) {
            self.text = text
            self.onSubmit = onSubmit
            self.onSubmitAndClose = onSubmitAndClose
            self.onCancel = onCancel
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else {
                return
            }

            text.wrappedValue = field.stringValue
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            switch commandSelector {
            case #selector(NSResponder.insertNewline(_:)):
                onSubmit()
                return true
            case #selector(NSResponder.insertLineBreak(_:)),
                #selector(NSResponder.insertParagraphSeparator(_:)):
                onSubmitAndClose()
                return true
            case #selector(NSResponder.cancelOperation(_:)):
                onCancel()
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Scrolling Number View

struct ScrollingNumberView: View {
    let number: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(String(number).enumerated()), id: \.offset) { _, char in
                if let digit = char.wholeNumberValue {
                    ScrollingDigitView(digit: digit)
                } else {
                    Text(String(char))
                }
            }
        }
    }
}

struct ScrollingDigitView: View {
    let digit: Int
    
    @State private var animatedDigit: Int
    
    init(digit: Int) {
        self.digit = digit
        self._animatedDigit = State(initialValue: digit)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0...9, id: \.self) { num in
                Text("\(num)")
                    .frame(height: 14, alignment: .center)
            }
        }
        .frame(height: 14, alignment: .top)
        .offset(y: CGFloat(-animatedDigit) * 14)
        .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: animatedDigit)
        .clipped()
        .onChange(of: digit) { _, newValue in
            animatedDigit = newValue
        }
    }
}
