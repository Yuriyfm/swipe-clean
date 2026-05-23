import SwiftUI
import UIKit

struct CleanupSummary {
    let sessionTitle: String
    let reviewedCount: Int
    let keptCount: Int
    let pendingDeletionCount: Int
    let pendingDeletionPhotos: [PhotoAsset]
}

struct CleanupSummaryScreen: View {
    let summary: CleanupSummary
    var onBackToMonths: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var deletionState: DeletionState = .idle
    @State private var isShowingDeleteConfirmation = false

    private let photoDeletionService = PhotoDeletionService()

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "checklist")
                            .font(.system(size: 56))
                            .foregroundStyle(.blue)

                        Text("Session complete")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(summary.sessionTitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Text(completionMessage)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Text(achievementMessage)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    VStack(spacing: 16) {
                        SummaryRow(title: "Reviewed", value: summary.reviewedCount)
                        SummaryRow(title: "Kept", value: summary.keptCount)
                        SummaryRow(title: "Pending deletion", value: summary.pendingDeletionCount)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    pendingDeletionSection

                    if let statusMessage {
                        Text(statusMessage)
                            .font(.callout)
                            .foregroundStyle(statusMessageColor)
                            .multilineTextAlignment(.center)
                    }
                }
            }

            VStack(spacing: 12) {
                if deletionState.isSuccess {
                    Button {
                        onBackToMonths()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        deletionState = .confirming
                        isShowingDeleteConfirmation = true
                    } label: {
                        if deletionState == .deleting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Confirm Delete")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(!canConfirmDeletion)
                }

                if !deletionState.isSuccess {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(deletionState == .deleting)
                }
            }
        }
        .padding(24)
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(deletionState == .deleting)
        .alert("Delete selected items?", isPresented: $isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                deletionState = .idle
            }
            Button("Delete Items", role: .destructive) {
                deleteSelectedPhotos()
            }
        } message: {
            Text("This will move \(summary.pendingDeletionCount) items to Recently Deleted in your Photos library. You can recover them from Photos for a limited time.")
        }
    }

    private var pendingDeletionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Marked for deletion")
                .font(.headline)

            Text(summary.pendingDeletionPhotos.isEmpty ? "You kept everything in this session." : "Nothing has been deleted yet.")
                .font(.callout)
                .foregroundStyle(.secondary)

            if summary.pendingDeletionPhotos.isEmpty {
                Text("No items marked for deletion.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 96), spacing: 8)
                    ],
                    spacing: 8
                ) {
                    ForEach(summary.pendingDeletionPhotos) { photo in
                        PendingDeletionThumbnail(photo: photo)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var canConfirmDeletion: Bool {
        !summary.pendingDeletionPhotos.isEmpty && deletionState.allowsDeletion
    }

    private var completionMessage: String {
        if summary.pendingDeletionCount == 0 {
            return "You kept everything in this session."
        }

        return "Review selected items before deleting. Nothing has been deleted yet."
    }

    private var achievementMessage: String {
        if summary.reviewedCount >= 50 {
            return "Big review session"
        }

        if summary.pendingDeletionCount == 0 {
            return "Clean sweep"
        }

        return "Ready for review"
    }

    private var statusMessage: String? {
        switch deletionState {
        case .idle, .confirming:
            return nil
        case .deleting:
            return "Deleting items..."
        case .success(let result):
            if result.missingCount > 0 {
                return "Moved \(result.deletedCount) items to Recently Deleted. \(result.missingCount) items were no longer available."
            }

            return "Moved \(result.deletedCount) items to Recently Deleted."
        case .failure(let message):
            return message
        }
    }

    private var statusMessageColor: Color {
        switch deletionState {
        case .failure:
            return .red
        default:
            return .secondary
        }
    }

    private func deleteSelectedPhotos() {
        guard !summary.pendingDeletionPhotos.isEmpty,
              deletionState == .confirming else {
            return
        }

        deletionState = .deleting

        Task {
            do {
                let result = try await photoDeletionService.deletePhotos(summary.pendingDeletionPhotos)
                await MainActor.run {
                    deletionState = .success(result)
                }
            } catch {
                await MainActor.run {
                    deletionState = .failure(error.localizedDescription)
                }
            }
        }
    }
}

private enum DeletionState: Equatable {
    case idle
    case confirming
    case deleting
    case success(PhotoDeletionResult)
    case failure(String)

    var allowsDeletion: Bool {
        switch self {
        case .idle, .failure:
            return true
        case .confirming, .deleting, .success:
            return false
        }
    }

    var isSuccess: Bool {
        if case .success = self {
            return true
        }

        return false
    }
}

private struct SummaryRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text("\(value)")
                .fontWeight(.semibold)
        }
    }
}

private final class PendingDeletionThumbnailViewModel: ObservableObject {
    @Published private(set) var state: PendingDeletionThumbnailState = .idle

    private let thumbnailService = PhotoThumbnailService()
    private var requestedPhotoID: String?

    func loadThumbnail(for photo: PhotoAsset) {
        guard requestedPhotoID != photo.id else {
            return
        }

        requestedPhotoID = photo.id
        state = .loading

        let screenScale = UIScreen.main.scale
        let targetSize = CGSize(width: 180 * screenScale, height: 180 * screenScale)

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

private enum PendingDeletionThumbnailState {
    case idle
    case loading
    case loaded(UIImage)
    case failed
}

private struct PendingDeletionThumbnail: View {
    let photo: PhotoAsset

    @StateObject private var viewModel = PendingDeletionThumbnailViewModel()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(photo.placeholderColor)

            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .tint(.white)
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            case .failed:
                Image(systemName: photo.systemImageName)
                    .font(.title)
                    .foregroundStyle(.white)
            }

            if photo.mediaType == .video {
                Label("Video", systemImage: "play.fill")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(.white)
                    .background(.black.opacity(0.65))
                    .clipShape(Capsule())
                    .padding(6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .clipped()
        .onAppear {
            viewModel.loadThumbnail(for: photo)
        }
        .onDisappear {
            viewModel.cancel()
        }
    }
}

#Preview {
    CleanupSummaryScreen(
        summary: CleanupSummary(
            sessionTitle: "March 2024",
            reviewedCount: 12,
            keptCount: 8,
            pendingDeletionCount: 4,
            pendingDeletionPhotos: Array(MockPhotoLibrary.months[0].photos.prefix(4))
        )
    )
}
