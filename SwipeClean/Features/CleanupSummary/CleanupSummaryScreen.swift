import SwiftUI

struct CleanupSummary {
    let reviewedCount: Int
    let keptCount: Int
    let pendingDeletionCount: Int
}

struct CleanupSummaryScreen: View {
    let summary: CleanupSummary

    @Environment(\.dismiss) private var dismiss
    @State private var confirmationMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "checklist")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue)

                Text("Review Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                SummaryRow(title: "Reviewed", value: summary.reviewedCount)
                SummaryRow(title: "Kept", value: summary.keptCount)
                SummaryRow(title: "Pending deletion", value: summary.pendingDeletionCount)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if let confirmationMessage {
                Text(confirmationMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    confirmationMessage = "Real deletion will be implemented in a later task."
                } label: {
                    Text("Confirm Delete")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(24)
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SummaryRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text("\(value)")
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    CleanupSummaryScreen(
        summary: CleanupSummary(
            reviewedCount: 12,
            keptCount: 8,
            pendingDeletionCount: 4
        )
    )
}
