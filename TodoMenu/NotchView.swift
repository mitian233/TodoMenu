import SwiftUI

struct NotchView: View {
    @StateObject var viewModel: NotchViewModel
    @ObservedObject var store: TodoStore

    var notchSize: CGSize {
        switch viewModel.status {
        case .closed:
            var size = CGSize(
                width: viewModel.deviceNotchRect.width - 4,
                height: viewModel.deviceNotchRect.height - 4
            )
            if size.width < 0 { size.width = 0 }
            if size.height < 0 { size.height = 0 }
            return size
        case .opened:
            return viewModel.notchOpenedSize
        case .popping:
            return CGSize(
                width: viewModel.deviceNotchRect.width,
                height: viewModel.deviceNotchRect.height + 4
            )
        }
    }

    var cornerRadius: CGFloat {
        switch viewModel.status {
        case .closed: return 8
        case .opened: return 24
        case .popping: return 10
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            notchBackground
                .zIndex(0)

            if viewModel.status == .opened {
                NotchTodoView(store: store, onClose: { viewModel.notchClose() })
                    .padding(16)
                    .frame(maxWidth: viewModel.notchOpenedSize.width, maxHeight: viewModel.notchOpenedSize.height)
                    .zIndex(1)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(viewModel.animation, value: viewModel.status)
        .preferredColorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var notchBackground: some View {
        Rectangle()
            .foregroundStyle(.black)
            .frame(
                width: notchSize.width + cornerRadius * 2,
                height: notchSize.height
            )
            .clipShape(.rect(
                bottomLeadingRadius: cornerRadius,
                bottomTrailingRadius: cornerRadius
            ))
            .shadow(
                color: viewModel.status == .opened ? .black.opacity(0.5) : .clear,
                radius: 16
            )
    }
}
