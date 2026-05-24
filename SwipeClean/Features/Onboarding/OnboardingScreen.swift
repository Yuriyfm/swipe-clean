import SwiftUI
import Photos
import UIKit

struct OnboardingScreen: View {
    @StateObject private var permissionViewModel = PhotoLibraryPermissionViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)

                headerContent

                statusContent

                Spacer()

                actionContent
            }
            .padding(24)
            .navigationTitle("Welcome")
            .onAppear {
                permissionViewModel.checkCurrentStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                permissionViewModel.checkCurrentStatus()
            }
        }
    }

    private var headerContent: some View {
        VStack(spacing: 12) {
            Text("SwipeClean")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Review photos and videos by cleanup mode. Keep the ones you want and mark unwanted items for a later confirmation step.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var statusContent: some View {
        switch permissionViewModel.currentPermissionStatus {
        case .notDetermined, .denied, .restricted:
            permissionStatusCard
        case .authorized:
            subtleStatusNote("Photo access is enabled. Nothing will be deleted without confirmation.")
        case .limited:
            VStack(spacing: 12) {
                subtleStatusNote("Limited photo access is enabled. SwipeClean can review only the media you selected.")

                Button {
                    Task {
                        await permissionViewModel.manageLimitedAccess()
                    }
                } label: {
                    Text("Manage Selected Photos")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        @unknown default:
            permissionStatusCard
        }
    }

    private var permissionStatusCard: some View {
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
    }

    private func subtleStatusNote(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.callout)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var actionContent: some View {
        switch permissionViewModel.currentPermissionStatus {
        case .notDetermined:
            Button {
                permissionViewModel.requestAccess()
            } label: {
                Text("Allow Photo Access")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        case .authorized, .limited:
            NavigationLink {
                CleanupModesScreen()
            } label: {
                Text("Start Cleanup")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        case .denied, .restricted:
            Button {
                permissionViewModel.openSettings()
            } label: {
                Text("Open Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                permissionViewModel.requestAccess()
            } label: {
                Text("Check Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        @unknown default:
            Button {
                permissionViewModel.requestAccess()
            } label: {
                Text("Check Access")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    OnboardingScreen()
}
