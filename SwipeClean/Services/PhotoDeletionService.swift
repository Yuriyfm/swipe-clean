import Foundation
import Photos

enum PhotoDeletionServiceError: LocalizedError {
    case emptySelection
    case accessNotGranted
    case noMatchingAssets
    case deletionFailed

    var errorDescription: String? {
        switch self {
        case .emptySelection:
            return L10n.string("No items were selected for deletion.")
        case .accessNotGranted:
            return L10n.string("SwipeClean needs full photo library access to delete photos and videos. Enable full access in iOS Settings and try again.")
        case .noMatchingAssets:
            return L10n.string("The selected items could not be found in the photo library.")
        case .deletionFailed:
            return L10n.string("Items could not be deleted.")
        }
    }
}

struct PhotoDeletionResult: Equatable {
    let requestedCount: Int
    let deletedCount: Int
    let missingCount: Int
}

struct PhotoDeletionService {
    func deletePhotos(_ photos: [PhotoAsset]) async throws -> PhotoDeletionResult {
        try await deletePhotos(localIdentifiers: photos.map(\.localIdentifier))
    }

    func deletePhotos(localIdentifiers: [String]) async throws -> PhotoDeletionResult {
        let uniqueLocalIdentifiers = Array(Set(localIdentifiers))

        guard !uniqueLocalIdentifiers.isEmpty else {
            throw PhotoDeletionServiceError.emptySelection
        }

        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized else {
            throw PhotoDeletionServiceError.accessNotGranted
        }

        let assets = PHAsset.fetchAssets(
            withLocalIdentifiers: uniqueLocalIdentifiers,
            options: nil
        )
        let assetsToDelete = NSMutableArray(capacity: assets.count)
        assets.enumerateObjects { asset, _, _ in
            assetsToDelete.add(asset)
        }

        guard assetsToDelete.count > 0 else {
            throw PhotoDeletionServiceError.noMatchingAssets
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assetsToDelete)
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard success else {
                    continuation.resume(throwing: PhotoDeletionServiceError.deletionFailed)
                    return
                }

                continuation.resume()
            }
        }

        return PhotoDeletionResult(
            requestedCount: uniqueLocalIdentifiers.count,
            deletedCount: assetsToDelete.count,
            missingCount: uniqueLocalIdentifiers.count - assetsToDelete.count
        )
    }
}
