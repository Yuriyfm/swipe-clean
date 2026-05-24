import Photos
import SwiftUI
import UIKit

struct CleanupModesScreen: View {
    private let photoLibraryService = PhotoLibraryService()

    @State private var loadingMode: CleanupMode?
    @State private var activeSession: MonthGroup?
    @State private var emptyMode: CleanupMode?
    @State private var errorMessage: String?
    @State private var permissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

    var body: some View {
        List {
            if permissionStatus == .limited {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Limited photo access", systemImage: "photo.badge.checkmark")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("SwipeClean can only review the photos and videos you selected. You can update that selection in Settings.")
                            .font(.callout)
                            .foregroundStyle(.primary)

                        Button("Manage Selected Photos") {
                            manageLimitedAccess()
                        }
                        .foregroundStyle(.primary)
                        .buttonStyle(.bordered)
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical, 4)
                }
            }

            if permissionStatus == .denied || permissionStatus == .restricted {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Photo access needed", systemImage: "exclamationmark.triangle")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("SwipeClean needs photo library access to review media. Open Settings and allow access before starting a cleanup mode.")
                            .font(.callout)
                            .foregroundStyle(.primary)

                        Button("Open Settings") {
                            PhotoLibraryAccessHelper.openAppSettings()
                        }
                        .foregroundStyle(.primary)
                        .buttonStyle(.bordered)
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical, 4)
                }
            }

            Section {
                NavigationLink {
                    MonthListScreen()
                } label: {
                    CleanupModeRow(mode: .monthlyReview, isLoading: false)
                }
                .foregroundStyle(.primary)
                .disabled(loadingMode != nil || !canLoadMedia)

                ForEach(CleanupMode.flatModes) { mode in
                    Button {
                        loadSession(for: mode)
                    } label: {
                        CleanupModeRow(mode: mode, isLoading: loadingMode == mode)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                    .disabled(loadingMode != nil || !canLoadMedia)
                }
            }
        }
        .navigationTitle("Cleanup Mode")
        .scrollContentBackground(.hidden)
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsScreen()
                } label: {
                    Image(systemName: "gearshape")
                        .accessibilityLabel("Settings")
                }
            }
        }
        .navigationDestination(isPresented: isShowingSession) {
            if let activeSession {
                SwipeSessionScreen(
                    month: activeSession,
                    onDeletionCompleted: {
                        self.activeSession = nil
                    }
                )
            }
        }
        .alert(emptyMode?.emptyTitle ?? L10n.string("Nothing to Review"), isPresented: isShowingEmptyAlert) {
            if permissionStatus == .limited {
                Button("Manage Selected Photos") {
                    manageLimitedAccess()
                }
            }

            Button("OK", role: .cancel) {
                emptyMode = nil
            }
        } message: {
            Text(emptyMode?.emptyMessage(isLimitedAccess: permissionStatus == .limited) ?? "")
        }
        .alert("Could Not Load Media", isPresented: isShowingErrorAlert) {
            if permissionStatus == .denied || permissionStatus == .restricted {
                Button("Open Settings") {
                    PhotoLibraryAccessHelper.openAppSettings()
                }
            }

            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            checkPermissionStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            checkPermissionStatus()
        }
    }

    private var isShowingEmptyAlert: Binding<Bool> {
        Binding(
            get: { emptyMode != nil },
            set: { isShowing in
                if !isShowing {
                    emptyMode = nil
                }
            }
        )
    }

    private var isShowingErrorAlert: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isShowing in
                if !isShowing {
                    errorMessage = nil
                }
            }
        )
    }

    private var isShowingSession: Binding<Bool> {
        Binding(
            get: { activeSession != nil },
            set: { isShowing in
                if !isShowing {
                    activeSession = nil
                }
            }
        )
    }

    private var canLoadMedia: Bool {
        permissionStatus == .authorized || permissionStatus == .limited
    }

    private func loadSession(for mode: CleanupMode) {
        checkPermissionStatus()

        guard canLoadMedia else {
            errorMessage = L10n.string("SwipeClean needs photo library access to review media. Open Settings and allow access to continue.")
            return
        }

        loadingMode = mode

        Task {
            do {
                let mediaItems = try await mediaItems(for: mode)

                await MainActor.run {
                    loadingMode = nil

                    guard !mediaItems.isEmpty else {
                        emptyMode = mode
                        return
                    }

                    activeSession = MonthGroup(
                        id: mode.rawValue,
                        month: 0,
                        name: mode.title,
                        year: 0,
                        title: mode.title,
                        photos: mediaItems
                    )
                }
            } catch {
                await MainActor.run {
                    loadingMode = nil
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func checkPermissionStatus() {
        permissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    private func manageLimitedAccess() {
        Task { @MainActor in
            PhotoLibraryAccessHelper.openPhotoAccessSettings()
            checkPermissionStatus()
        }
    }

    private func mediaItems(for mode: CleanupMode) async throws -> [PhotoAsset] {
        switch mode {
        case .monthlyReview:
            return []
        case .allMedia:
            return try await photoLibraryService.fetchAllMedia()
        case .screenshots:
            return try await photoLibraryService.fetchScreenshots()
        case .videos:
            return try await photoLibraryService.fetchVideos()
        }
    }
}

private enum CleanupMode: String, Identifiable, CaseIterable {
    case monthlyReview
    case allMedia
    case screenshots
    case videos

    static let flatModes: [CleanupMode] = [.allMedia, .screenshots, .videos]

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .monthlyReview:
            return L10n.string("Monthly Review")
        case .allMedia:
            return L10n.string("All Media")
        case .screenshots:
            return L10n.string("Screenshots")
        case .videos:
            return L10n.string("Videos")
        }
    }

    var description: String {
        switch self {
        case .monthlyReview:
            return L10n.string("Review your library month by month.")
        case .allMedia:
            return L10n.string("Review all available photos and videos.")
        case .screenshots:
            return L10n.string("Clean up screenshots.")
        case .videos:
            return L10n.string("Review videos only.")
        }
    }

    var systemImageName: String {
        switch self {
        case .monthlyReview:
            return "calendar"
        case .allMedia:
            return "photo.on.rectangle"
        case .screenshots:
            return "iphone"
        case .videos:
            return "play.rectangle"
        }
    }

    var emptyTitle: String {
        switch self {
        case .monthlyReview:
            return L10n.string("No Accessible Media")
        case .allMedia:
            return L10n.string("No Accessible Media")
        case .screenshots:
            return L10n.string("No Screenshots")
        case .videos:
            return L10n.string("No Videos")
        }
    }

    func emptyMessage(isLimitedAccess: Bool) -> String {
        let limitedAccessNote = isLimitedAccess ? L10n.string(" With limited access, only selected media is available. You can manage your selected photos and videos in Settings.") : ""

        switch self {
        case .monthlyReview:
            return L10n.string(format: "SwipeClean could not find accessible media to group by month.%@", limitedAccessNote)
        case .allMedia:
            return L10n.string(format: "SwipeClean could not find accessible photos or videos.%@", limitedAccessNote)
        case .screenshots:
            return L10n.string(format: "SwipeClean could not find accessible screenshots.%@", limitedAccessNote)
        case .videos:
            return L10n.string(format: "SwipeClean could not find accessible videos.%@", limitedAccessNote)
        }
    }
}

private struct CleanupModeRow: View {
    let mode: CleanupMode
    let isLoading: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: mode.systemImageName)
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(mode.description)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Spacer()

            if isLoading {
                ProgressView()
            }
        }
        .foregroundStyle(.primary)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        CleanupModesScreen()
    }
}
