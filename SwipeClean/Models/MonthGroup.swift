struct MonthGroup: Identifiable {
    let id: String
    let month: Int
    let name: String
    let year: Int
    let title: String
    let photos: [PhotoAsset]

    var photoCount: Int {
        photos.count
    }
}
