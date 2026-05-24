import Foundation
import Photos
import SwiftUI

enum PhotoLibraryServiceError: LocalizedError {
    case accessNotGranted

    var errorDescription: String? {
        switch self {
        case .accessNotGranted:
            return L10n.string("Photo library access is not authorized.")
        }
    }
}

struct PhotoLibraryService {
    func fetchMonthGroups() async throws -> [MonthGroup] {
        let mediaItems = try await fetchMediaItems(kind: .allMedia)
        return Self.groupPhotosByMonth(mediaItems)
    }

    func fetchAllMedia() async throws -> [PhotoAsset] {
        try await fetchMediaItems(kind: .allMedia)
    }

    func fetchScreenshots() async throws -> [PhotoAsset] {
        try await fetchMediaItems(kind: .screenshots)
    }

    func fetchVideos() async throws -> [PhotoAsset] {
        try await fetchMediaItems(kind: .videos)
    }

    private func fetchMediaItems(kind: MediaFetchKind) async throws -> [PhotoAsset] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PhotoAsset], Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

                guard status == .authorized || status == .limited else {
                    continuation.resume(throwing: PhotoLibraryServiceError.accessNotGranted)
                    return
                }

                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = kind.predicate
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]

                let assets = PHAsset.fetchAssets(with: fetchOptions)
                var mediaItems: [PhotoAsset] = []
                mediaItems.reserveCapacity(assets.count)

                assets.enumerateObjects { asset, _, _ in
                    guard kind.includes(asset) else {
                        return
                    }

                    guard let mediaType = Self.mediaType(for: asset) else {
                        return
                    }

                    mediaItems.append(
                        PhotoAsset(
                            id: asset.localIdentifier,
                            localIdentifier: asset.localIdentifier,
                            creationDate: asset.creationDate,
                            mediaType: mediaType,
                            duration: mediaType == .video ? asset.duration : nil,
                            pixelWidth: asset.pixelWidth,
                            pixelHeight: asset.pixelHeight,
                            title: Self.photoTitle(for: asset),
                            systemImageName: mediaType.systemImageName,
                            placeholderColor: mediaType.placeholderColor
                        )
                    )
                }

                continuation.resume(returning: mediaItems)
            }
        }
    }

    private static func groupPhotosByMonth(_ photos: [PhotoAsset]) -> [MonthGroup] {
        let calendar = Calendar.current
        let groupedPhotos = Dictionary(grouping: photos) { photo in
            guard let date = photo.creationDate else {
                return MonthKey(year: 0, month: 0)
            }

            let components = calendar.dateComponents([.year, .month], from: date)
            return MonthKey(
                year: components.year ?? 0,
                month: components.month ?? 0
            )
        }

        return groupedPhotos
            .map { key, photos in
                let monthName = monthName(for: key.month)
                let title = key.year == 0 ? L10n.string("Unknown Date") : "\(monthName) \(key.year)"

                return MonthGroup(
                    id: "\(key.year)-\(String(format: "%02d", key.month))",
                    month: key.month,
                    name: monthName,
                    year: key.year,
                    title: title,
                    photos: photos
                )
            }
            .sorted { first, second in
                if first.year == second.year {
                    return first.month > second.month
                }

                return first.year > second.year
            }
    }

    private static func photoTitle(for asset: PHAsset) -> String {
        guard let creationDate = asset.creationDate else {
            return asset.mediaType == .video ? L10n.string("Video fallback title") : L10n.string("Photo fallback title")
        }

        let formatter = DateFormatter()
        formatter.locale = L10n.locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: creationDate)
    }

    private static func monthName(for month: Int) -> String {
        guard (1...12).contains(month) else {
            return L10n.string("Unknown")
        }

        let formatter = DateFormatter()
        formatter.locale = L10n.locale
        return formatter.monthSymbols[month - 1]
    }

    private static func mediaType(for asset: PHAsset) -> MediaType? {
        switch asset.mediaType {
        case .image:
            return .image
        case .video:
            return .video
        default:
            return nil
        }
    }
}

private struct MonthKey: Hashable {
    let year: Int
    let month: Int
}

private enum MediaFetchKind {
    case allMedia
    case screenshots
    case videos

    var predicate: NSPredicate {
        switch self {
        case .allMedia:
            return NSPredicate(
                format: "mediaType == %d OR mediaType == %d",
                PHAssetMediaType.image.rawValue,
                PHAssetMediaType.video.rawValue
            )
        case .screenshots:
            return NSPredicate(
                format: "mediaType == %d",
                PHAssetMediaType.image.rawValue
            )
        case .videos:
            return NSPredicate(
                format: "mediaType == %d",
                PHAssetMediaType.video.rawValue
            )
        }
    }

    func includes(_ asset: PHAsset) -> Bool {
        switch self {
        case .allMedia:
            return asset.mediaType == .image || asset.mediaType == .video
        case .screenshots:
            return asset.mediaType == .image && asset.mediaSubtypes.contains(.photoScreenshot)
        case .videos:
            return asset.mediaType == .video
        }
    }
}

private extension MediaType {
    var systemImageName: String {
        switch self {
        case .image:
            return "photo"
        case .video:
            return "play.rectangle"
        }
    }

    var placeholderColor: Color {
        switch self {
        case .image:
            return Color(red: 0.34, green: 0.50, blue: 0.56).opacity(0.55)
        case .video:
            return Color(red: 0.44, green: 0.38, blue: 0.54).opacity(0.55)
        }
    }
}
