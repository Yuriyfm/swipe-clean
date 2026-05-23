import SwiftUI

struct MonthListScreen: View {
    private let previewMonths: [MonthGroup]?
    private let photoLibraryService = PhotoLibraryService()

    @State private var months: [MonthGroup] = []
    @State private var loadingState: LoadingState = .idle

    init(months: [MonthGroup]? = nil) {
        self.previewMonths = months
    }

    var body: some View {
        Group {
            switch loadingState {
            case .idle, .loading:
                ProgressView("Loading media months...")
            case .loaded where months.isEmpty:
                ContentUnavailableView(
                    "No Media Available",
                    systemImage: "photo.on.rectangle",
                    description: Text("SwipeClean could not find any accessible photos or videos. If you granted limited access, add more items in Settings.")
                )
            case .loaded:
                monthList
            case .failed(let message):
                ContentUnavailableView(
                    "Could Not Load Media",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            }
        }
        .navigationTitle("Choose Month")
        .task {
            await loadMonthsIfNeeded()
        }
        .refreshable {
            await loadMonths()
        }
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
                    }
                )
            } label: {
                MonthRow(month: month)
            }
        }
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

        loadingState = .loading

        do {
            months = try await photoLibraryService.fetchMonthGroups()
            loadingState = .loaded
        } catch {
            loadingState = .failed(error.localizedDescription)
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
                .foregroundStyle(.blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(month.title)
                    .font(.headline)

                Text("\(month.photoCount) accessible items")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(month.photoCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        MonthListScreen(months: MockPhotoLibrary.months)
    }
}
