import Foundation
import SwiftUI

enum MediaType: Equatable {
    case image
    case video
}

struct PhotoAsset: Identifiable {
    let id: String
    let localIdentifier: String
    let creationDate: Date?
    let mediaType: MediaType
    let duration: TimeInterval?
    let pixelWidth: Int
    let pixelHeight: Int
    let title: String
    let systemImageName: String
    let placeholderColor: Color

    var aspectRatio: Double {
        guard pixelWidth > 0, pixelHeight > 0 else {
            return 1.0
        }

        return Double(pixelWidth) / Double(pixelHeight)
    }
}
