import Foundation
import Combine

final class SwipeSessionViewModel: ObservableObject {
    let selectedMonth: MonthGroup

    @Published private(set) var currentPhotoIndex = 0
    @Published private(set) var decisions: [SwipeDecision] = []
    @Published var isSessionCompleted = false

    init(month: MonthGroup) {
        self.selectedMonth = month
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

    var totalCount: Int {
        selectedMonth.photos.count
    }

    var progressFraction: Double {
        guard totalCount > 0 else {
            return 0
        }

        return Double(reviewedCount) / Double(totalCount)
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

        return L10n.string(format: "%d of %d reviewed", reviewedCount, totalCount)
    }

    var encouragementText: String {
        guard totalCount > 0 else {
            return L10n.string("Ready to review")
        }

        if totalCount - reviewedCount <= 3 && reviewedCount > 0 {
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
        guard canUndoLastDecision else {
            return
        }

        decisions.removeLast()
        currentPhotoIndex = max(currentPhotoIndex - 1, 0)
    }

    func finishReview() {
        guard !isSessionCompleted else {
            return
        }

        isSessionCompleted = true
    }

    func moveToNextPhoto() {
        if currentPhotoIndex + 1 >= selectedMonth.photos.count {
            isSessionCompleted = true
        } else {
            currentPhotoIndex += 1
        }
    }

    func reset() {
        currentPhotoIndex = 0
        decisions = []
        isSessionCompleted = false
    }

    private func recordDecision(_ action: SwipeAction) {
        guard !isSessionCompleted, let currentPhoto else {
            return
        }

        decisions.append(
            SwipeDecision(photoID: currentPhoto.id, action: action)
        )

        moveToNextPhoto()
    }
}
