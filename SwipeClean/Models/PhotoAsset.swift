import SwiftUI

struct PhotoAsset: Identifiable {
    let id: String
    let localIdentifier: String
    let creationDate: Date?
    let title: String
    let systemImageName: String
    let placeholderColor: Color
}
