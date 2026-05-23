import SwiftUI

enum MockPhotoLibrary {
    static let months: [MonthGroup] = [
        MonthGroup(
            id: "2026-05",
            name: "May",
            year: 2026,
            photos: makePhotos(prefix: "may", count: 12, color: .blue)
        ),
        MonthGroup(
            id: "2026-04",
            name: "April",
            year: 2026,
            photos: makePhotos(prefix: "april", count: 8, color: .purple)
        ),
        MonthGroup(
            id: "2026-03",
            name: "March",
            year: 2026,
            photos: makePhotos(prefix: "march", count: 10, color: .orange)
        )
    ]

    private static func makePhotos(prefix: String, count: Int, color: Color) -> [PhotoAsset] {
        (1...count).map { index in
            PhotoAsset(
                id: "\(prefix)-photo-\(index)",
                title: "Mock Photo \(index)",
                systemImageName: index.isMultiple(of: 2) ? "photo" : "camera",
                placeholderColor: color.opacity(0.75)
            )
        }
    }
}
