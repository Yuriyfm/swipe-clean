import SwiftUI

enum MockPhotoLibrary {
    static let months: [MonthGroup] = [
        MonthGroup(
            id: "2026-05",
            month: 5,
            name: "May",
            year: 2026,
            title: "May 2026",
            photos: makePhotos(prefix: "may", count: 12, color: .blue)
        ),
        MonthGroup(
            id: "2026-04",
            month: 4,
            name: "April",
            year: 2026,
            title: "April 2026",
            photos: makePhotos(prefix: "april", count: 8, color: .purple)
        ),
        MonthGroup(
            id: "2026-03",
            month: 3,
            name: "March",
            year: 2026,
            title: "March 2026",
            photos: makePhotos(prefix: "march", count: 10, color: .orange)
        )
    ]

    private static func makePhotos(prefix: String, count: Int, color: Color) -> [PhotoAsset] {
        (1...count).map { index in
            PhotoAsset(
                id: "\(prefix)-photo-\(index)",
                localIdentifier: "\(prefix)-photo-\(index)",
                creationDate: nil,
                mediaType: index.isMultiple(of: 5) ? .video : .image,
                duration: index.isMultiple(of: 5) ? 42 : nil,
                title: index.isMultiple(of: 5) ? "Mock Video \(index)" : "Mock Photo \(index)",
                systemImageName: index.isMultiple(of: 5) ? "play.rectangle" : "photo",
                placeholderColor: index.isMultiple(of: 5) ? .purple.opacity(0.75) : color.opacity(0.75)
            )
        }
    }
}
