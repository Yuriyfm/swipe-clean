enum SwipeAction {
    case keep
    case pendingDeletion
}

struct SwipeDecision: Identifiable {
    let id: String
    let photoID: String
    let action: SwipeAction

    init(photoID: String, action: SwipeAction) {
        self.id = photoID
        self.photoID = photoID
        self.action = action
    }
}
