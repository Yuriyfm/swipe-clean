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
                            .foregroundStyle(Color.accentColor)

                        Text("Session complete")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(summary.sessionTitle)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)

                        Text(completionMessage)
                            .font(.callout)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)

                        Text(achievementMessage)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    VStack(spacing: 16) {
                        SummaryRow(title: "Reviewed", value: summary.reviewedCount)
                        SummaryRow(title: "Kept", value: summary.keptCount)
                        SummaryRow(title: "Pending deletion", value: summary.pendingDeletionCount)
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
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
                    .tint(Color(red: 0.70, green: 0.28, blue: 0.28))
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

                if deletionState.canOpenSettings {
                    Button {
                        PhotoLibraryAccessHelper.openAppSettings()
                    } label: {
                        Text("Open Settings")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(deletionState == .deleting)
                }
            }
        }
        .padding(24)
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
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
            Text(L10n.string(format: "This will move %d items to Recently Deleted in your Photos library. You can recover them from Photos for a limited time.", summary.pendingDeletionCount))
        }
    }

    private var pendingDeletionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Marked for deletion")
                .font(.headline)

            Text(LocalizedStringKey(summary.pendingDeletionPhotos.isEmpty ? "You kept everything in this session." : "Nothing has been deleted yet."))
                .font(.callout)
                .foregroundStyle(.primary)

            if summary.pendingDeletionPhotos.isEmpty {
                Text("No items marked for deletion.")
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
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
            return L10n.string("You kept everything in this session.")
        }

        return L10n.string("Review selected items before deleting. Nothing has been deleted yet.")
    }

    private var achievementMessage: String {
        if summary.reviewedCount >= 50 {
            return L10n.string("Big review session")
        }

        if summary.pendingDeletionCount == 0 {
            return L10n.string("Clean sweep")
        }

        return L10n.string("Ready for review")
    }

    private var statusMessage: String? {
        switch deletionState {
        case .idle, .confirming:
            return nil
        case .deleting:
            return L10n.string("Deleting items...")
        case .success(let result):
            if result.missingCount > 0 {
                return L10n.string(format: "Moved %d items to Recently Deleted. %d items were no longer available.", result.deletedCount, result.missingCount)
            }

            return L10n.string(format: "Moved %d items to Recently Deleted.", result.deletedCount)
        case .failure(let message, _):
            return message
        }
    }

    private var statusMessageColor: Color {
        switch deletionState {
        case .failure(_, _):
            return .primary
        default:
            return .primary
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
                    deletionState = .failure(
                        error.localizedDescription,
                        canOpenSettings: isPhotoAccessFailure(error)
                    )
                }
            }
        }
    }

    private func isPhotoAccessFailure(_ error: Error) -> Bool {
        guard let deletionError = error as? PhotoDeletionServiceError else {
            return false
        }

        if case .accessNotGranted = deletionError {
            return true
        }

        return false
    }
}

private enum DeletionState: Equatable {
    case idle
    case confirming
    case deleting
    case success(PhotoDeletionResult)
    case failure(String, canOpenSettings: Bool)

    var allowsDeletion: Bool {
        switch self {
        case .idle, .failure(_, _):
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

    var canOpenSettings: Bool {
        if case .failure(_, let canOpenSettings) = self {
            return canOpenSettings
        }

        return false
    }
}

private struct SummaryRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
                .foregroundStyle(.primary)

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
                    .foregroundStyle(.primary)
                    .background(Color(.systemBackground).opacity(0.82))
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
                    }
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
