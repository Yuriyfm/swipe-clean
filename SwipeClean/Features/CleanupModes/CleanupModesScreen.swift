import SwiftUI

struct CleanupModesScreen: View {
    private let photoLibraryService = PhotoLibraryService()

    @State private var loadingMode: CleanupMode?
    @State private var activeSession: MonthGroup?
    @State private var emptyMode: CleanupMode?
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section {
                NavigationLink {
                    MonthListScreen()
                } label: {
                    CleanupModeRow(mode: .monthlyReview, isLoading: false)
                }

                ForEach(CleanupMode.flatModes) { mode in
                    Button {
                        loadSession(for: mode)
                    } label: {
                        CleanupModeRow(mode: mode, isLoading: loadingMode == mode)
                    }
                    .disabled(loadingMode != nil)
                }
            }
        }
        .navigationTitle("Cleanup Mode")
        .navigationDestination(item: $activeSession) { session in
            SwipeSessionScreen(
                month: session,
                onDeletionCompleted: {
                    activeSession = nil
                }
            )
        }
        .alert("Nothing to Review", isPresented: isShowingEmptyAlert) {
            Button("OK", role: .cancel) {
                emptyMode = nil
            }
        } message: {
            Text(emptyMode?.emptyMessage ?? "")
        }
        .alert("Could Not Load Media", isPresented: isShowingErrorAlert) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
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

    private func loadSession(for mode: CleanupMode) {
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
            return "Monthly Review"
        case .allMedia:
            return "All Media"
        case .screenshots:
            return "Screenshots"
        case .videos:
            return "Videos"
        }
    }

    var description: String {
        switch self {
        case .monthlyReview:
            return "Review your library month by month."
        case .allMedia:
            return "Review all available photos and videos."
        case .screenshots:
            return "Clean up screenshots."
        case .videos:
            return "Review videos only."
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

    var emptyMessage: String {
        switch self {
        case .monthlyReview:
            return "No month groups are available."
        case .allMedia:
            return "No media items are available."
        case .screenshots:
            return "No screenshots are available."
        case .videos:
            return "No videos are available."
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
                .foregroundStyle(.blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(mode.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isLoading {
                ProgressView()
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        CleanupModesScreen()
    }
}
