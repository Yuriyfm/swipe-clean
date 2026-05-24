import UIKit

enum PhotoLibraryAccessHelper {
    static func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }

    @MainActor
    static func openPhotoAccessSettings() {
        openAppSettings()
    }
}
