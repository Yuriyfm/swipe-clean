import Photos
import UIKit

enum PhotoThumbnailServiceError: LocalizedError {
    case assetNotFound
    case imageUnavailable

    var errorDescription: String? {
        switch self {
        case .assetNotFound:
            return L10n.string("Media item was not found.")
        case .imageUnavailable:
            return L10n.string("Media preview is unavailable.")
        }
    }
}

final class PhotoThumbnailService {
    private let imageManager: PHImageManager
    private var currentRequestID: PHImageRequestID?

    init(imageManager: PHImageManager = .default()) {
        self.imageManager = imageManager
    }

    func cancelCurrentRequest() {
        guard let currentRequestID else {
            return
        }

        imageManager.cancelImageRequest(currentRequestID)
        self.currentRequestID = nil
    }

    func requestThumbnail(
        localIdentifier: String,
        targetSize: CGSize,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        cancelCurrentRequest()

        let assets = PHAsset.fetchAssets(
            withLocalIdentifiers: [localIdentifier],
            options: nil
        )

        guard let asset = assets.firstObject else {
            completion(.failure(PhotoThumbnailServiceError.assetNotFound))
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true

        currentRequestID = imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { [weak self] image, info in
            if let isCancelled = info?[PHImageCancelledKey] as? Bool, isCancelled {
                return
            }

            if let error = info?[PHImageErrorKey] as? Error {
                self?.currentRequestID = nil
                completion(.failure(error))
                return
            }

            guard let image else {
                self?.currentRequestID = nil
                completion(.failure(PhotoThumbnailServiceError.imageUnavailable))
                return
            }

            let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
            if !isDegraded {
                self?.currentRequestID = nil
            }

            completion(.success(image))
        }
    }
}
