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
        guard !selectedMonth.photos.isEmpty else {
            return "0 of 0"
        }

        let visiblePhotoNumber = min(currentPhotoIndex + 1, selectedMonth.photos.count)
        return "\(visiblePhotoNumber) of \(selectedMonth.photos.count)"
    }

    var summary: CleanupSummary {
        CleanupSummary(
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
