import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "selectedAppTheme"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .system:
            return L10n.string("System")
        case .light:
            return L10n.string("Light")
        case .dark:
            return L10n.string("Dark")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
