import SwiftUI

@main
struct SwipeCleanApp: App {
    @AppStorage(AppTheme.storageKey) private var selectedThemeRawValue = AppTheme.system.rawValue
    @AppStorage(AppLanguage.storageKey) private var selectedLanguageRawValue = AppLanguage.system.rawValue

    var body: some Scene {
        WindowGroup {
            OnboardingScreen()
                .preferredColorScheme(selectedTheme.colorScheme)
                .environment(\.locale, selectedLocale)
        }
    }

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRawValue) ?? .system
    }

    private var selectedLocale: Locale {
        guard let localeIdentifier = selectedLanguage.localeIdentifier else {
            return .autoupdatingCurrent
        }

        return Locale(identifier: localeIdentifier)
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRawValue) ?? .system
    }
}
