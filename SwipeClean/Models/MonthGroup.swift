struct MonthGroup: Identifiable {
    let id: String
    let name: String
    let year: Int
    let photos: [PhotoAsset]

    var photoCount: Int {
        photos.count
    }
}
