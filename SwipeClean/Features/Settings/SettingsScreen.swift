import SwiftUI

struct SettingsScreen: View {
    @AppStorage(AppTheme.storageKey) private var selectedThemeRawValue = AppTheme.system.rawValue
    @AppStorage(AppLanguage.storageKey) private var selectedLanguageRawValue = AppLanguage.system.rawValue

    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $selectedThemeRawValue) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.title)
                            .tag(theme.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Theme")
            } footer: {
                Text("System follows your iOS appearance. Light and Dark force SwipeClean to use that appearance.")
            }

            Section {
                Picker("Language", selection: $selectedLanguageRawValue) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.title)
                            .tag(language.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Language")
            } footer: {
                Text("System follows your iOS language. English and Russian force SwipeClean to use that language.")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
