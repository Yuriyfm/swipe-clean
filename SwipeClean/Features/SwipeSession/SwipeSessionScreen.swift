import SwiftUI

struct SwipeSessionScreen: View {
    let month: MonthGroup

    @State private var currentIndex = 0
    @State private var decisions: [SwipeDecision] = []
    @State private var isShowingSummary = false

    private var currentPhoto: PhotoAsset? {
        guard currentIndex < month.photos.count else {
            return nil
        }

        return month.photos[currentIndex]
    }

    private var progressText: String {
        let reviewedCount = min(currentIndex + 1, month.photos.count)
        return "\(reviewedCount) of \(month.photos.count)"
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("\(month.name) \(month.year)")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(progressText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let currentPhoto {
                MockPhotoCard(photo: currentPhoto)
                    .transition(.opacity)
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    recordDecision(.keep)
                } label: {
                    Label("Keep", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button {
                    recordDecision(.pendingDeletion)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding(24)
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingSummary) {
            CleanupSummaryScreen(summary: summary)
        }
    }

    private var summary: CleanupSummary {
        CleanupSummary(
            reviewedCount: decisions.count,
            keptCount: decisions.filter { $0.action == .keep }.count,
            pendingDeletionCount: decisions.filter { $0.action == .pendingDeletion }.count
        )
    }

    private func recordDecision(_ action: SwipeAction) {
        guard let currentPhoto else {
            return
        }

        decisions.append(
            SwipeDecision(photoID: currentPhoto.id, action: action)
        )

        if currentIndex + 1 >= month.photos.count {
            isShowingSummary = true
        } else {
            currentIndex += 1
        }
    }
}

private struct MockPhotoCard: View {
    let photo: PhotoAsset

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(photo.placeholderColor)
            .overlay {
                VStack(spacing: 16) {
                    Image(systemName: photo.systemImageName)
                        .font(.system(size: 72))

                    Text(photo.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
            }
            .aspectRatio(0.75, contentMode: .fit)
            .shadow(radius: 12)
    }
}

#Preview {
    NavigationStack {
        SwipeSessionScreen(month: MockPhotoLibrary.months[0])
    }
}
