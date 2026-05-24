import SwiftUI

enum MockPhotoLibrary {
    static let months: [MonthGroup] = [
        MonthGroup(
            id: "2026-05",
            month: 5,
            name: "May",
            year: 2026,
            title: "May 2026",
            photos: makePhotos(prefix: "may", count: 12, color: Color(red: 0.34, green: 0.50, blue: 0.56))
        ),
        MonthGroup(
            id: "2026-04",
            month: 4,
            name: "April",
            year: 2026,
            title: "April 2026",
            photos: makePhotos(prefix: "april", count: 8, color: Color(red: 0.44, green: 0.38, blue: 0.54))
        ),
        MonthGroup(
            id: "2026-03",
            month: 3,
            name: "March",
            year: 2026,
            title: "March 2026",
            photos: makePhotos(prefix: "march", count: 10, color: Color(red: 0.72, green: 0.48, blue: 0.18))
        )
    ]

    private static func makePhotos(prefix: String, count: Int, color: Color) -> [PhotoAsset] {
        (1...count).map { index in
            let dimensions = mockDimensions(for: index)
            let isVideo = index.isMultiple(of: 5)

            return PhotoAsset(
                id: "\(prefix)-photo-\(index)",
                localIdentifier: "\(prefix)-photo-\(index)",
                creationDate: nil,
                mediaType: isVideo ? .video : .image,
                duration: isVideo ? 42 : nil,
                pixelWidth: dimensions.width,
                pixelHeight: dimensions.height,
                title: isVideo ? "Mock Video \(index)" : "Mock Photo \(index)",
                systemImageName: isVideo ? "play.rectangle" : "photo",
                placeholderColor: isVideo ? Color(red: 0.44, green: 0.38, blue: 0.54).opacity(0.55) : color.opacity(0.55)
            )
        }
    }

    private static func mockDimensions(for index: Int) -> (width: Int, height: Int) {
        switch index % 5 {
        case 1:
            return (width: 3024, height: 4032)
        case 2:
            return (width: 4032, height: 3024)
        case 3:
            return (width: 3000, height: 3000)
        case 4:
            return (width: 4096, height: 1200)
        default:
            return (width: 1200, height: 4096)
        }
    }
}
