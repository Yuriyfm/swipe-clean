import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case russian

    static let storageKey = "selectedAppLanguage"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .system:
            return L10n.string("System")
        case .english:
            return L10n.string("English")
        case .russian:
            return L10n.string("Russian")
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system:
            return nil
        case .english:
            return "en"
        case .russian:
            return "ru"
        }
    }
}

enum L10n {
    static func string(_ key: String) -> String {
        localizedBundle.localizedString(forKey: key, value: key, table: nil)
    }

    static func string(format key: String, _ arguments: CVarArg...) -> String {
        String(format: string(key), locale: locale, arguments: arguments)
    }

    static var locale: Locale {
        let rawValue = UserDefaults.standard.string(forKey: AppLanguage.storageKey) ?? AppLanguage.system.rawValue
        guard let language = AppLanguage(rawValue: rawValue),
              let localeIdentifier = language.localeIdentifier else {
            return .autoupdatingCurrent
        }

        return Locale(identifier: localeIdentifier)
    }

    private static var localizedBundle: Bundle {
        let rawValue = UserDefaults.standard.string(forKey: AppLanguage.storageKey) ?? AppLanguage.system.rawValue
        guard let language = AppLanguage(rawValue: rawValue),
              let localeIdentifier = language.localeIdentifier,
              let path = Bundle.main.path(forResource: localeIdentifier, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }

        return bundle
    }
}
