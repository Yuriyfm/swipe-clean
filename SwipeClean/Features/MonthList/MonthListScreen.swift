import SwiftUI

struct MonthListScreen: View {
    let months: [MonthGroup]

    var body: some View {
        List(months) { month in
            NavigationLink {
                SwipeSessionScreen(month: month)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(month.name)
                            .font(.headline)

                        Text(String(month.year))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(month.photoCount) photos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Choose Month")
    }
}

#Preview {
    NavigationStack {
        MonthListScreen(months: MockPhotoLibrary.months)
    }
}
