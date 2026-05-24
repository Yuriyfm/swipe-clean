import SwiftUI

struct OnboardingScreen: View {
    @StateObject private var permissionViewModel = PhotoLibraryPermissionViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)

                VStack(spacing: 12) {
                    Text("SwipeClean")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Review photos and videos by cleanup mode. Keep the ones you want and mark unwanted items for a later confirmation step.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Text("SwipeClean needs photo library access so you can review available photos and videos. Permission does not delete or modify anything.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    Text(permissionViewModel.statusTitle)
                        .font(.headline)

                    Text(permissionViewModel.statusMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Spacer()

                Button {
                    permissionViewModel.requestAccess()
                } label: {
                    Text(permissionViewModel.requestButtonTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(permissionViewModel.canContinue)

                NavigationLink {
                    CleanupModesScreen()
                } label: {
                    Text("Start Cleanup")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!permissionViewModel.canContinue)
            }
            .padding(24)
            .navigationTitle("Welcome")
            .onAppear {
                permissionViewModel.checkCurrentStatus()
            }
        }
    }
}

#Preview {
    OnboardingScreen()
}
