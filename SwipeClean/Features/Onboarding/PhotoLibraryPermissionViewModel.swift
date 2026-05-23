import Combine
import Foundation
import Photos

final class PhotoLibraryPermissionViewModel: ObservableObject {
    @Published private(set) var currentPermissionStatus: PHAuthorizationStatus

    init() {
        self.currentPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    var canContinue: Bool {
        currentPermissionStatus == .authorized || currentPermissionStatus == .limited
    }

    var statusTitle: String {
        switch currentPermissionStatus {
        case .notDetermined:
            return "Photo access is not set"
        case .authorized:
            return "Full photo access granted"
        case .limited:
            return "Limited photo access granted"
        case .denied:
            return "Photo access denied"
        case .restricted:
            return "Photo access restricted"
        @unknown default:
            return "Unknown photo access status"
        }
    }

    var statusMessage: String {
        switch currentPermissionStatus {
        case .notDetermined:
            return "SwipeClean needs photo access before cleanup can start. This task only requests permission; it does not load, modify, or delete photos."
        case .authorized:
            return "You can continue to your photo months. This version loads only photo metadata and identifiers."
        case .limited:
            return "You can continue with limited access. Only the photos you selected will appear."
        case .denied:
            return "Photo access is needed to review your library. You can enable access later in iOS Settings."
        case .restricted:
            return "Photo access is restricted on this device, so SwipeClean cannot continue yet."
        @unknown default:
            return "SwipeClean cannot determine the current photo access state."
        }
    }

    var requestButtonTitle: String {
        switch currentPermissionStatus {
        case .notDetermined:
            return "Allow Photo Access"
        case .denied, .restricted:
            return "Check Again"
        case .authorized, .limited:
            return "Access Granted"
        @unknown default:
            return "Check Access"
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
}
