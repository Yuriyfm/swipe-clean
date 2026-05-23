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
    let title: String
    let systemImageName: String
    let placeholderColor: Color
}
