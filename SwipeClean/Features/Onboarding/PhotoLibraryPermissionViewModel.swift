import Combine
import Foundation
import Photos

final class PhotoLibraryPermissionViewModel: ObservableObject {
    @Published private(set) var currentPermissionStatus: PHAuthorizationStatus

    init() {
        self.currentPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    var canOpenSettings: Bool {
        currentPermissionStatus == .denied || currentPermissionStatus == .restricted
    }

    var canManageLimitedAccess: Bool {
        currentPermissionStatus == .limited
    }

    var statusTitle: String {
        switch currentPermissionStatus {
        case .notDetermined:
            return L10n.string("Photo access is not set")
        case .authorized:
            return L10n.string("Full photo access granted")
        case .limited:
            return L10n.string("Limited photo access granted")
        case .denied:
            return L10n.string("Photo access denied")
        case .restricted:
            return L10n.string("Photo access restricted")
        @unknown default:
            return L10n.string("Unknown photo access status")
        }
    }

    var statusMessage: String {
        switch currentPermissionStatus {
        case .notDetermined:
            return L10n.string("SwipeClean needs photo access before cleanup can start. Permission does not delete or modify photos or videos.")
        case .authorized:
            return L10n.string("You can continue to your media months. This version loads only metadata and identifiers.")
        case .limited:
            return L10n.string("You can continue with limited access. Only the photos and videos you selected will appear.")
        case .denied:
            return L10n.string("Photo access is needed to review your library. Open iOS Settings and allow photo access to continue.")
        case .restricted:
            return L10n.string("Photo access is restricted on this device. Check iOS Settings or device restrictions before continuing.")
        @unknown default:
            return L10n.string("SwipeClean cannot determine the current photo access state.")
        }
    }

    func checkCurrentStatus() {
        currentPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestAccess() {
        guard currentPermissionStatus == .notDetermined else {
            checkCurrentStatus()
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.currentPermissionStatus = status
            }
        }
    }

    func openSettings() {
        PhotoLibraryAccessHelper.openAppSettings()
    }

    @MainActor
    func manageLimitedAccess() {
        PhotoLibraryAccessHelper.openPhotoAccessSettings()
        checkCurrentStatus()
    }
}
