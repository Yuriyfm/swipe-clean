import Foundation
import Combine

final class SwipeSessionViewModel: ObservableObject {
    let selectedMonth: MonthGroup

    @Published private(set) var currentPhotoIndex = 0
    @Published private(set) var decisions: [SwipeDecision] = []
    @Published private(set) var viewedPhotoIDs: [String] = []
    @Published var isSessionCompleted = false

    init(month: MonthGroup) {
        self.selectedMonth = month
        rememberCurrentPhotoAsViewed()
    }

    var currentPhoto: PhotoAsset? {
        guard currentPhotoIndex < selectedMonth.photos.count else {
            return nil
        }

        return selectedMonth.photos[currentPhotoIndex]
    }

    var reviewedCount: Int {
        decisions.count
    }

    var activeReviewTotalCount: Int {
        selectedMonth.photos.count - pendingDeletionCount
    }

    var currentQueuePosition: Int {
        guard activeReviewTotalCount > 0 else {
            return 0
        }

        guard !isSessionCompleted, let currentPhoto else {
            return activeReviewTotalCount
        }

        let activePhotos = selectedMonth.photos.filter { !pendingDeletionIDs.contains($0.id) }
        guard let currentActiveIndex = activePhotos.firstIndex(where: { $0.id == currentPhoto.id }) else {
            return activeReviewTotalCount
        }

        return currentActiveIndex + 1
    }

    var totalCount: Int {
        selectedMonth.photos.count
    }

    var progressFraction: Double {
        guard activeReviewTotalCount > 0 else {
            return 0
        }

        return Double(currentQueuePosition) / Double(activeReviewTotalCount)
    }

    var canUndoLastDecision: Bool {
        !decisions.isEmpty && !isSessionCompleted
    }

    var keptCount: Int {
        decisions.filter { $0.action == .keep }.count
    }

    var pendingDeletionCount: Int {
        decisions.filter { $0.action == .pendingDeletion }.count
    }

    private var pendingDeletionIDs: Set<String> {
        Set(
            decisions.compactMap { decision in
                decision.action == .pendingDeletion ? decision.photoID : nil
            }
        )
    }

    var pendingDeletionPhotos: [PhotoAsset] {
        let photosByID = Dictionary(
            uniqueKeysWithValues: selectedMonth.photos.map { ($0.id, $0) }
        )

        return decisions.compactMap { decision in
            guard decision.action == .pendingDeletion else {
                return nil
            }

            return photosByID[decision.photoID]
        }
    }

    var progressText: String {
        guard totalCount > 0 else {
            return L10n.string("0 of 0")
        }

        return L10n.string(format: "Photo %d of %d", currentQueuePosition, activeReviewTotalCount)
    }

    var encouragementText: String {
        guard activeReviewTotalCount > 0 else {
            return L10n.string("Ready to review")
        }

        if activeReviewTotalCount - currentQueuePosition <= 3 && currentQueuePosition > 0 {
            return L10n.string("Last few items")
        }

        switch progressFraction {
        case 0:
            return L10n.string("Getting started")
        case 0..<0.5:
            return L10n.string("Nice progress")
        case 0..<0.85:
            return L10n.string("More than halfway")
        default:
            return L10n.string("Almost done")
        }
    }

    var summary: CleanupSummary {
        CleanupSummary(
            sessionTitle: selectedMonth.title,
            reviewedCount: reviewedCount,
            keptCount: keptCount,
            pendingDeletionCount: pendingDeletionCount,
            pendingDeletionPhotos: pendingDeletionPhotos
        )
    }

    func keepCurrentPhoto() {
        recordDecision(.keep)
    }

    func markCurrentPhotoForDeletion() {
        recordDecision(.pendingDeletion)
    }

    func undoLastDecision() {
        guard canUndoLastDecision, let lastDecision = decisions.last else {
            return
        }

        decisions.removeLast()
        isSessionCompleted = false

        guard let restoredPhotoIndex = selectedMonth.photos.firstIndex(where: { $0.id == lastDecision.photoID }) else {
            return
        }

        currentPhotoIndex = restoredPhotoIndex
        rememberCurrentPhotoAsViewed()
    }

    func finishReview() {
        guard !isSessionCompleted else {
            return
        }

        isSessionCompleted = true
    }

    func moveToNextPhoto() {
        moveToNextAvailablePhoto(after: currentPhotoIndex)
    }

    func reset() {
        currentPhotoIndex = 0
        decisions = []
        viewedPhotoIDs = []
        isSessionCompleted = false
        rememberCurrentPhotoAsViewed()
    }

    func moveToPreviousViewedKeptPhoto() -> Bool {
        guard !isSessionCompleted,
              let currentPhoto,
              let currentHistoryIndex = viewedPhotoIDs.lastIndex(of: currentPhoto.id) else {
            return false
        }

        let previousPhotoID = viewedPhotoIDs[..<currentHistoryIndex]
            .reversed()
            .first { !pendingDeletionIDs.contains($0) }

        guard let previousPhotoID,
              let previousPhotoIndex = selectedMonth.photos.firstIndex(where: { $0.id == previousPhotoID }) else {
            return false
        }

        currentPhotoIndex = previousPhotoIndex
        return true
    }

    private func recordDecision(_ action: SwipeAction) {
        guard !isSessionCompleted, let currentPhoto else {
            return
        }

        rememberCurrentPhotoAsViewed()
        decisions.removeAll { $0.photoID == currentPhoto.id }
        decisions.append(
            SwipeDecision(photoID: currentPhoto.id, action: action)
        )

        moveToNextAvailablePhoto(after: currentPhotoIndex)
    }

    private func moveToNextAvailablePhoto(after index: Int) {
        guard let nextPhotoIndex = selectedMonth.photos.indices.first(where: { photoIndex in
            photoIndex > index && !pendingDeletionIDs.contains(selectedMonth.photos[photoIndex].id)
        }) else {
            isSessionCompleted = true
            return
        }

        currentPhotoIndex = nextPhotoIndex
        rememberCurrentPhotoAsViewed()
    }

    private func rememberCurrentPhotoAsViewed() {
        guard let currentPhoto, !viewedPhotoIDs.contains(currentPhoto.id) else {
            return
        }

        viewedPhotoIDs.append(currentPhoto.id)
    }
}
