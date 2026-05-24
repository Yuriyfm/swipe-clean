import Photos
import SwiftUI
import UIKit

struct MonthListScreen: View {
    private let previewMonths: [MonthGroup]?
    private let photoLibraryService = PhotoLibraryService()

    @Environment(\.dismiss) private var dismiss
    @State private var months: [MonthGroup] = []
    @State private var loadingState: LoadingState = .idle
    @State private var permissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

    init(months: [MonthGroup]? = nil) {
        self.previewMonths = months
    }

    var body: some View {
        Group {
            switch loadingState {
            case .idle, .loading:
                ProgressView("Loading media months...")
            case .loaded where months.isEmpty:
                emptyStateView
            case .loaded:
                monthList
            case .failed(let message):
                errorStateView(message)
            }
        }
        .navigationTitle("Choose Month")
        .task {
            await loadMonthsIfNeeded()
        }
        .refreshable {
            await loadMonths()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            permissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
    }

    private var monthList: some View {
        List(months) { month in
            NavigationLink {
                SwipeSessionScreen(
                    month: month,
                    onDeletionCompleted: {
                        Task {
                            await loadMonths()
                        }
                    },
                    onSessionCancelled: {
                        dismiss()
                    }
                )
            } label: {
                MonthRow(month: month)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(.secondarySystemBackground))
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)

            Text("No Accessible Media")
                .font(.title2)
                .fontWeight(.semibold)

            Text(emptyStateMessage)
                .font(.callout)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            if permissionStatus == .limited {
                Button("Manage Selected Photos") {
                    manageLimitedAccess()
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Back to Cleanup Modes") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding(24)
    }

    private func errorStateView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Color(red: 0.72, green: 0.48, blue: 0.18))

            Text("Could Not Load Media")
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .font(.callout)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            if permissionStatus == .denied || permissionStatus == .restricted {
                Button("Open Settings") {
                    PhotoLibraryAccessHelper.openAppSettings()
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Back to Cleanup Modes") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding(24)
    }

    private var emptyStateMessage: String {
        if permissionStatus == .limited {
            return L10n.string("SwipeClean could not find accessible photos or videos to group by month. With limited access, only selected media is available.")
        }

        return L10n.string("SwipeClean could not find photos or videos available for monthly review.")
    }

    @MainActor
    private func loadMonthsIfNeeded() async {
        guard loadingState == .idle else {
            return
        }

        await loadMonths()
    }

    @MainActor
    private func loadMonths() async {
        if let previewMonths {
            months = previewMonths
            loadingState = .loaded
            return
        }

        permissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        loadingState = .loading

        do {
            months = try await photoLibraryService.fetchMonthGroups()
            loadingState = .loaded
        } catch {
            loadingState = .failed(error.localizedDescription)
        }
    }

    private func manageLimitedAccess() {
        Task { @MainActor in
            PhotoLibraryAccessHelper.openPhotoAccessSettings()
            permissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            await loadMonths()
        }
    }
}

private enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

private struct MonthRow: View {
    let month: MonthGroup

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(month.title)
                    .font(.headline)

                Text(L10n.string(format: "%d accessible items", month.photoCount))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text("\(month.photoCount)")
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        MonthListScreen(months: MockPhotoLibrary.months)
    }
}
