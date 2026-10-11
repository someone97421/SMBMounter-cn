import Foundation
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .simplifiedChinese: return "简体中文"
        case .english: return "English"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }
}

// 使用独立的文案键，避免语言切换影响共享配置和连接状态。
enum AppText: String, CaseIterable {
    case language = "Language"
    case connectAutoShares = "Connect all Auto-Shares"
    case addShare = "Add Share"
    case editShare = "Edit Share"
    case noShares = "No shares configured"
    case addShareHint = "Click + to add an SMB/WebDAV share"
    case edit = "Edit"
    case connectNow = "Connect now"
    case connect = "Connect"
    case disconnect = "Disconnect"
    case openInFinder = "Open in Finder"
    case delete = "Delete"
    case quit = "Quit"
    case connectedCount = "%d/%d connected"
    case general = "General"
    case name = "Name"
    case namePlaceholder = "My Network Drive"
    case connectionProtocol = "Protocol"
    case host = "Host / IP"
    case hostPlaceholder = "192.168.1.100 or server.local"
    case port = "Port"
    case shareName = "Share Name"
    case shareNamePlaceholder = "SharedFolder"
    case mountPoint = "Mount Point"
    case mountPointPlaceholder = "ShareName"
    case autoMount = "Auto-Mount"
    case autoMountHint = "Automatically connect and reconnect on disconnect"
    case credentials = "Credentials (optional)"
    case username = "Username"
    case usernamePlaceholder = "domain\\user or user"
    case password = "Password"
    case showPassword = "Show password"
    case hidePassword = "Hide password"
    case keychainHint = "The password is securely stored in the macOS Keychain."
    case preview = "Preview"
    case cancel = "Cancel"
    case save = "Save"
    case autoMountActive = "Auto-Mount active"
    case connectedSince = "Connected since %@"
    case connected = "Connected"
    case disconnected = "Disconnected"
    case connecting = "Connecting..."
    case error = "Error"
    case smbUnavailable = "Host is currently unreachable (SMB port 445)."
    case webDAVUnavailable = "Host is currently unreachable (WebDAV port %d)."
    case connectionSucceeded = "%@ successfully connected."
    case automationDenied = "Allow SMBMounter to control Finder in System Settings > Privacy & Security > Automation."
    case mountFailed = "Connection failed. Check the shared folder name, account and access permissions."
    case mountTimeout = "Connection timed out. Check the server or any pending Finder login dialog."
}

final class AppLocalization: ObservableObject {
    static let shared = AppLocalization()
    static let languagePreferenceKey = "appLanguage"

    @Published var language: AppLanguage {
        didSet {
            defaults.set(language.rawValue, forKey: Self.languagePreferenceKey)
        }
    }

    private let defaults: UserDefaults
    private let resourceBundle: Bundle

    init(defaults: UserDefaults = .standard, bundle: Bundle = .main) {
        self.defaults = defaults
        self.resourceBundle = bundle
        language = defaults.string(forKey: Self.languagePreferenceKey)
            .flatMap(AppLanguage.init(rawValue:)) ?? .simplifiedChinese
    }

    var locale: Locale { language.locale }

    func text(_ key: AppText) -> String {
        guard let path = resourceBundle.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key.rawValue
        }
        return bundle.localizedString(forKey: key.rawValue, value: key.rawValue, table: "Localizable")
    }

    func format(_ key: AppText, _ arguments: CVarArg...) -> String {
        String(format: text(key), arguments: arguments)
    }
}
