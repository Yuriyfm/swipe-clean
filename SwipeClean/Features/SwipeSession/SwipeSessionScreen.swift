import SwiftUI

struct SwipeSessionScreen: View {
    private let swipeThreshold: CGFloat = 120

    @StateObject private var viewModel: SwipeSessionViewModel
    @State private var isShowingSummary = false
    @State private var cardOffset: CGSize = .zero
    @State private var isAnimatingCardOut = false

    init(month: MonthGroup) {
        _viewModel = StateObject(wrappedValue: SwipeSessionViewModel(month: month))
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("\(viewModel.selectedMonth.name) \(viewModel.selectedMonth.year)")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(viewModel.progressText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let currentPhoto = viewModel.currentPhoto {
                ZStack {
                    SwipeHintLabel(
                        title: "Delete",
                        systemImageName: "trash",
                        color: .red,
                        opacity: deleteHintOpacity
                    )
                    .frame(maxHeight: .infinity, alignment: .top)

                    SwipeHintLabel(
                        title: "Keep",
                        systemImageName: "checkmark",
                        color: .green,
                        opacity: keepHintOpacity
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)

                    MockPhotoCard(photo: currentPhoto)
                        .offset(cardOffset)
                        .rotationEffect(.degrees(Double(cardOffset.height / 40)))
                        .scaleEffect(cardScale)
                        .gesture(cardDragGesture)
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: cardOffset)
                }
                    .transition(.opacity)
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    completeCurrentPhoto(.keep, exitOffset: swipeThreshold * 3)
                } label: {
                    Label("Keep", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button {
                    completeCurrentPhoto(.pendingDeletion, exitOffset: -swipeThreshold * 3)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding(24)
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.isSessionCompleted) { _, isCompleted in
            if isCompleted {
                isShowingSummary = true
            }
        }
        .navigationDestination(isPresented: $isShowingSummary) {
            CleanupSummaryScreen(summary: viewModel.summary)
        }
    }

    private var cardDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isAnimatingCardOut else {
                    return
                }

                cardOffset = CGSize(width: 0, height: value.translation.height)
            }
            .onEnded { value in
                guard !isAnimatingCardOut else {
                    return
                }

                handleDragEnd(value)
            }
    }

    private var cardScale: CGFloat {
        let dragProgress = min(abs(cardOffset.height) / 600, 0.04)
        return 1 - dragProgress
    }

    private var deleteHintOpacity: Double {
        min(max(Double(-cardOffset.height / swipeThreshold), 0), 1)
    }

    private var keepHintOpacity: Double {
        min(max(Double(cardOffset.height / swipeThreshold), 0), 1)
    }

    private func handleDragEnd(_ value: DragGesture.Value) {
        let verticalDistance = value.translation.height
        let horizontalDistance = abs(value.translation.width)

        guard abs(verticalDistance) >= swipeThreshold,
              abs(verticalDistance) > horizontalDistance else {
            cardOffset = .zero
            return
        }

        if verticalDistance < 0 {
            completeCurrentPhoto(.pendingDeletion, exitOffset: -swipeThreshold * 3)
        } else {
            completeCurrentPhoto(.keep, exitOffset: swipeThreshold * 3)
        }
    }

    private func completeCurrentPhoto(_ action: SwipeAction, exitOffset: CGFloat) {
        guard !isAnimatingCardOut else {
            return
        }

        isAnimatingCardOut = true

        withAnimation(.easeIn(duration: 0.18)) {
            cardOffset = CGSize(width: 0, height: exitOffset)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            switch action {
            case .keep:
                viewModel.keepCurrentPhoto()
            case .pendingDeletion:
                viewModel.markCurrentPhotoForDeletion()
            }

            cardOffset = .zero
            isAnimatingCardOut = false
        }
    }
}

private struct MockPhotoCard: View {
    let photo: PhotoAsset

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(photo.placeholderColor)
            .overlay {
                VStack(spacing: 16) {
                    Image(systemName: photo.systemImageName)
                        .font(.system(size: 72))

                    Text(photo.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
            }
            .aspectRatio(0.75, contentMode: .fit)
            .shadow(radius: 12)
    }
}

private struct SwipeHintLabel: View {
    let title: String
    let systemImageName: String
    let color: Color
    let opacity: Double

    var body: some View {
        Label(title, systemImage: systemImageName)
            .font(.headline)
            .foregroundStyle(color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .opacity(opacity)
    }
}

#Preview {
    NavigationStack {
        SwipeSessionScreen(month: MockPhotoLibrary.months[0])
    }
}
