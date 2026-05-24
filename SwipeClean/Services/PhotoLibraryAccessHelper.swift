import Photos
import UIKit

enum PhotoLibraryAccessHelper {
    static func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }

    @MainActor
    static func presentLimitedLibraryPicker() {
        guard let viewController = rootViewController else {
            return
        }

        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController)
    }

    @MainActor
    private static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
