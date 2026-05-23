import SwiftUI

struct OnboardingScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 72))
                    .foregroundStyle(.blue)

                VStack(spacing: 12) {
                    Text("SwipeClean")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Review photos month by month. Keep the ones you want and mark unwanted photos for a later confirmation step.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                NavigationLink {
                    MonthListScreen(months: MockPhotoLibrary.months)
                } label: {
                    Text("Start Cleanup")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .navigationTitle("Welcome")
        }
    }
}

#Preview {
    OnboardingScreen()
}
