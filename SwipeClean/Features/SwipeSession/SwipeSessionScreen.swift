import SwiftUI
import UIKit

struct SwipeSessionScreen: View {
    private let swipeThreshold: CGFloat = 120
    private let onDeletionCompleted: () -> Void
    private let onSessionCancelled: () -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SwipeSessionViewModel
    @StateObject private var thumbnailViewModel = PhotoThumbnailViewModel()
    @State private var isShowingSummary = false
    @State private var cardOffset: CGSize = .zero
    @State private var isAnimatingCardOut = false
    @State private var isPhotoFullscreen = false
    @State private var isCompletingDeletedSession = false

    init(
        month: MonthGroup,
        onDeletionCompleted: @escaping () -> Void = {},
        onSessionCancelled: @escaping () -> Void = {}
    ) {
        self.onDeletionCompleted = onDeletionCompleted
        self.onSessionCancelled = onSessionCancelled
        _viewModel = StateObject(wrappedValue: SwipeSessionViewModel(month: month))
    }

    var body: some View {
        ZStack {
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
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(viewModel.encouragementText)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }

                        ProgressView(value: viewModel.progressFraction)
                            .progressViewStyle(.linear)
                            .accessibilityLabel("Session progress")
                            .accessibilityValue(viewModel.progressText)

                        ZStack {
                            HStack {
                                Text(pendingDeletionCounterText)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(deleteColor.opacity(0.12))
                                    .clipShape(Capsule())

                                Spacer()
                            }

                            Image(systemName: "trash.fill")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(deleteColor)
                                .padding(10)
                                .background(deleteColor.opacity(0.12))
                                .clipShape(Circle())
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(L10n.string("Swipe up marks photo for deletion"))
                        }
                    }
                }
                .zIndex(1)

                Spacer()

                if let currentPhoto = viewModel.currentPhoto {
                    ZStack {
                        SwipeHintLabel(
                            title: "Keep",
                            systemImageName: "checkmark",
                            color: keepColor,
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
                        .onTapGesture {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                isPhotoFullscreen = true
                            }
                        }
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: cardOffset)
                    }
                    .frame(height: 420)
                    .transition(.opacity)
                    .zIndex(0)
                } else if viewModel.totalCount == 0 {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.accentColor)

                        Text("No Items to Review")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("This session does not contain any accessible media.")
                            .font(.callout)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                    }
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
                    .tint(keepColor)
                    .disabled(viewModel.currentPhoto == nil || isAnimatingCardOut)

                    Button {
                        completeCurrentPhoto(.pendingDeletion, exitOffset: -swipeThreshold * 3)
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(deleteColor)
                    .disabled(viewModel.currentPhoto == nil || isAnimatingCardOut)
                }
            }
            .padding(24)

            if isPhotoFullscreen, let currentPhoto = viewModel.currentPhoto {
                FullscreenPhotoOverlay(
                    photo: currentPhoto,
                    thumbnailState: thumbnailViewModel.state
                ) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        isPhotoFullscreen = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(1)
            }
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    finishReview()
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .tint(.primary)
                .disabled(isAnimatingCardOut)
            }
        }
        .toolbar(isPhotoFullscreen ? .hidden : .visible, for: .navigationBar)
        .onChange(of: viewModel.isSessionCompleted) { _, isCompleted in
            if isCompleted {
                isShowingSummary = true
            }
        }
        .navigationDestination(isPresented: $isShowingSummary) {
            CleanupSummaryScreen(
                summary: viewModel.summary,
                onCancel: cancelReviewSession,
                onBackToMonths: completeDeletedSession
            )
        }
        .onChange(of: isShowingSummary) { wasShowing, isShowing in
            guard wasShowing,
                  !isShowing,
                  viewModel.isSessionCompleted,
                  !isCompletingDeletedSession else {
                return
            }

            cancelReviewSession()
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
                guard !isAnimatingCardOut, !isPhotoFullscreen else {
                    return
                }

                if value.translation.width > 0,
                   value.translation.width > abs(value.translation.height) {
                    cardOffset = CGSize(width: value.translation.width, height: 0)
                } else {
                    cardOffset = CGSize(width: 0, height: value.translation.height)
                }
            }
            .onEnded { value in
                guard !isAnimatingCardOut, !isPhotoFullscreen else {
                    return
                }

                handleDragEnd(value)
            }
    }

    private var cardScale: CGFloat {
        let dragProgress = min(abs(cardOffset.height) / 600, 0.04)
        return 1 - dragProgress
    }

    private var keepHintOpacity: Double {
        min(max(Double(cardOffset.height / swipeThreshold), 0), 1)
    }

    private var keepColor: Color {
        Color(red: 0.30, green: 0.52, blue: 0.36)
    }

    private var deleteColor: Color {
        Color(red: 0.70, green: 0.28, blue: 0.28)
    }

    private var pendingDeletionCounterText: String {
        L10n.string(format: "Pending deletion counter: %d", viewModel.pendingDeletionCount)
    }

    private func handleDragEnd(_ value: DragGesture.Value) {
        guard !isPhotoFullscreen else {
            return
        }

        let verticalDistance = value.translation.height
        let horizontalDistance = value.translation.width

        if horizontalDistance >= swipeThreshold,
           horizontalDistance > abs(verticalDistance) {
            moveToPreviousViewedKeptPhoto()
            return
        }

        if abs(verticalDistance) >= swipeThreshold,
           abs(verticalDistance) > abs(horizontalDistance) {
            if verticalDistance < 0 {
                completeCurrentPhoto(.pendingDeletion, exitOffset: -swipeThreshold * 3)
            } else {
                completeCurrentPhoto(.keep, exitOffset: swipeThreshold * 3)
            }
            return
        }

        cardOffset = .zero
    }

    private func completeCurrentPhoto(_ action: SwipeAction, exitOffset: CGFloat) {
        guard !isAnimatingCardOut, !isPhotoFullscreen, viewModel.currentPhoto != nil else {
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
        guard !isAnimatingCardOut, !isPhotoFullscreen else {
            return
        }

        viewModel.undoLastDecision()
        cardOffset = .zero
        loadCurrentThumbnail()
    }

    private func moveToPreviousViewedKeptPhoto() {
        guard !isAnimatingCardOut, !isPhotoFullscreen else {
            return
        }

        isAnimatingCardOut = true

        withAnimation(.easeIn(duration: 0.18)) {
            cardOffset = CGSize(width: swipeThreshold * 3, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            guard viewModel.moveToPreviousViewedKeptPhoto() else {
                cardOffset = .zero
                isAnimatingCardOut = false
                return
            }

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                cardOffset = CGSize(width: -swipeThreshold * 3, height: 0)
            }
            loadCurrentThumbnail()

            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.18)) {
                    cardOffset = .zero
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    isAnimatingCardOut = false
                }
            }
        }
    }

    private func finishReview() {
        guard !isAnimatingCardOut, !isPhotoFullscreen else {
            return
        }

        viewModel.finishReview()
    }

    private func cancelReviewSession() {
        viewModel.reset()
        cardOffset = .zero
        isAnimatingCardOut = false
        isPhotoFullscreen = false
        thumbnailViewModel.cancel()
        isShowingSummary = false

        DispatchQueue.main.async {
            dismiss()

            DispatchQueue.main.async {
                onSessionCancelled()
            }
        }
    }

    private func completeDeletedSession() {
        isCompletingDeletedSession = true
        onDeletionCompleted()
        isShowingSummary = false

        DispatchQueue.main.async {
            dismiss()
        }
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
        GeometryReader { geometry in
            let cardSize = size(
                for: photo.aspectRatio,
                in: geometry.size
            )

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.tertiarySystemBackground))

                switch thumbnailState {
                case .idle, .loading:
                    VStack(spacing: 16) {
                        ProgressView()

                        Text("Loading Preview")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                case .loaded(let image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: cardSize.width, height: cardSize.height)
                case .failed:
                    VStack(spacing: 16) {
                        Image(systemName: photo.systemImageName)
                            .font(.system(size: 72))

                        Text(photo.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.primary)
                }

                if photo.mediaType == .video {
                    MediaTypeBadge()
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(width: cardSize.width, height: cardSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.primary.opacity(0.10), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.16), radius: 10, y: 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
    }

    private func size(for rawAspectRatio: Double, in availableSize: CGSize) -> CGSize {
        let aspectRatio = min(max(rawAspectRatio, 0.45), 2.4)
        let maxWidth = min(availableSize.width, 340)
        let maxHeight = min(availableSize.height, 420)
        let minHeight: CGFloat = 160

        var width = maxWidth
        var height = width / aspectRatio

        if height > maxHeight {
            height = maxHeight
            width = height * aspectRatio
        }

        if height < minHeight {
            height = minHeight
            width = min(maxWidth, height * aspectRatio)
        }

        return CGSize(width: width, height: height)
    }
}

private struct FullscreenPhotoOverlay: View {
    let photo: PhotoAsset
    let thumbnailState: ThumbnailState
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            fullscreenContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(12)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onDismiss()
        }
    }

    @ViewBuilder
    private var fullscreenContent: some View {
        switch thumbnailState {
        case .idle, .loading:
            ProgressView()
                .tint(.white)
        case .loaded(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        case .failed:
            Image(systemName: photo.systemImageName)
                .font(.system(size: 80))
                .foregroundStyle(.white)
        }
    }
}

private struct MediaTypeBadge: View {
    var body: some View {
        Label("Video", systemImage: "play.fill")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(.primary)
            .background(Color(.systemBackground).opacity(0.82))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
            }
    }
}

private struct SwipeHintLabel: View {
    let title: String
    let systemImageName: String
    let color: Color
    let opacity: Double

    var body: some View {
        Label(LocalizedStringKey(title), systemImage: systemImageName)
            .font(.headline)
            .foregroundStyle(.primary)
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
