import SwiftUI
import UIKit

struct SwipeSessionScreen: View {
    private let swipeThreshold: CGFloat = 120
    private let onDeletionCompleted: () -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SwipeSessionViewModel
    @StateObject private var thumbnailViewModel = PhotoThumbnailViewModel()
    @State private var isShowingSummary = false
    @State private var cardOffset: CGSize = .zero
    @State private var isAnimatingCardOut = false

    init(month: MonthGroup, onDeletionCompleted: @escaping () -> Void = {}) {
        self.onDeletionCompleted = onDeletionCompleted
        _viewModel = StateObject(wrappedValue: SwipeSessionViewModel(month: month))
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text(viewModel.selectedMonth.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                VStack(spacing: 6) {
                    HStack {
                        Text(viewModel.progressText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(viewModel.encouragementText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                    }

                    ProgressView(value: viewModel.progressFraction)
                        .progressViewStyle(.linear)
                        .accessibilityLabel("Session progress")
                        .accessibilityValue(viewModel.progressText)
                }
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

                    PhotoCard(
                        photo: currentPhoto,
                        thumbnailState: thumbnailViewModel.state
                    )
                        .offset(cardOffset)
                        .rotationEffect(.degrees(Double(cardOffset.height / 40)))
                        .scaleEffect(cardScale)
                        .gesture(cardDragGesture)
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: cardOffset)
                }
                    .transition(.opacity)
            }

            Spacer()

            Button {
                undoLastDecision()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canUndoLastDecision || isAnimatingCardOut)

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
            CleanupSummaryScreen(
                summary: viewModel.summary,
                onBackToMonths: {
                    onDeletionCompleted()
                    isShowingSummary = false

                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            )
        }
        .onChange(of: viewModel.currentPhoto?.id) { _, _ in
            loadCurrentThumbnail()
        }
        .onAppear {
            loadCurrentThumbnail()
        }
        .onDisappear {
            thumbnailViewModel.cancel()
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

    private func undoLastDecision() {
        guard !isAnimatingCardOut else {
            return
        }

        viewModel.undoLastDecision()
        cardOffset = .zero
        loadCurrentThumbnail()
    }

    private func loadCurrentThumbnail() {
        guard let currentPhoto = viewModel.currentPhoto else {
            thumbnailViewModel.cancel()
            return
        }

        thumbnailViewModel.loadThumbnail(for: currentPhoto)
    }
}

private final class PhotoThumbnailViewModel: ObservableObject {
    @Published private(set) var state: ThumbnailState = .idle

    private let thumbnailService = PhotoThumbnailService()
    private var requestedPhotoID: String?

    func loadThumbnail(for photo: PhotoAsset) {
        guard requestedPhotoID != photo.id else {
            return
        }

        requestedPhotoID = photo.id
        state = .loading

        let screenScale = UIScreen.main.scale
        let targetSize = CGSize(width: 900 * screenScale, height: 1200 * screenScale)

        thumbnailService.requestThumbnail(
            localIdentifier: photo.localIdentifier,
            targetSize: targetSize
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard self?.requestedPhotoID == photo.id else {
                    return
                }

                switch result {
                case .success(let image):
                    self?.state = .loaded(image)
                case .failure:
                    self?.state = .failed
                }
            }
        }
    }

    func cancel() {
        thumbnailService.cancelCurrentRequest()
        requestedPhotoID = nil
    }
}

private enum ThumbnailState {
    case idle
    case loading
    case loaded(UIImage)
    case failed
}

private struct PhotoCard: View {
    let photo: PhotoAsset
    let thumbnailState: ThumbnailState

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(photo.placeholderColor)

            switch thumbnailState {
            case .idle, .loading:
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(.white)

                    Text("Loading Preview")
                        .font(.headline)
                }
                .foregroundStyle(.white)
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            case .failed:
                VStack(spacing: 16) {
                    Image(systemName: photo.systemImageName)
                        .font(.system(size: 72))

                    Text(photo.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
            }

            if photo.mediaType == .video {
                MediaTypeBadge()
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .aspectRatio(0.75, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 12)
    }
}

private struct MediaTypeBadge: View {
    var body: some View {
        Label("Video", systemImage: "play.fill")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(.white)
            .background(.black.opacity(0.65))
            .clipShape(Capsule())
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
