import SwiftUI

@main
struct SwipeCleanApp: App {
    @AppStorage(AppTheme.storageKey) private var selectedThemeRawValue = AppTheme.system.rawValue

    var body: some Scene {
        WindowGroup {
            OnboardingScreen()
                .preferredColorScheme(selectedTheme.colorScheme)
        }
    }

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRawValue) ?? .system
    }
}
