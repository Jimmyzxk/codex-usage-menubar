import Foundation
import LocalAuthentication
import Security

final class SettingsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AppSettings {
        let storedInterval = defaults.double(forKey: "refreshInterval")
        let interval = storedInterval.isFinite
            ? min(max(storedInterval, 60), 86_400)
            : AppSettings.default.refreshInterval
        let theme = ThemeMode(rawValue: defaults.string(forKey: "theme") ?? "") ?? .system
        let dashboardTheme = DashboardTheme(rawValue: defaults.string(forKey: "dashboardTheme") ?? "") ?? .clarity
        let panelSize = PanelSize(rawValue: defaults.string(forKey: "panelSize") ?? "") ?? .standard
        let tokenDisplayMode = TokenDisplayMode(rawValue: defaults.string(forKey: "tokenDisplayMode") ?? "") ?? .compact
        if let data = defaults.data(forKey: "profiles"),
           let profiles = try? JSONDecoder().decode([ProviderProfile].self, from: data),
           !profiles.isEmpty {
            let selectedID = defaults.string(forKey: "selectedProfileID") ?? profiles[0].id
            return AppSettings(
                profiles: profiles,
                selectedProfileID: selectedID,
                refreshInterval: interval > 0 ? interval : AppSettings.default.refreshInterval,
                theme: theme,
                dashboardTheme: dashboardTheme,
                panelSize: panelSize,
                tokenDisplayMode: tokenDisplayMode
            )
        }

        let baseURL = defaults.string(forKey: "baseURL") ?? AppSettings.defaultBaseURL
        let provider = ProviderKind(rawValue: defaults.string(forKey: "provider") ?? "") ?? .sub2api
        let newAPIUserID = defaults.string(forKey: "newAPIUserID") ?? ""
        let legacyProfile = ProviderProfile(
            id: "legacy-sub2api",
            name: provider == .sub2api ? "默认 Sub2API" : "默认供应商",
            provider: provider,
            baseURL: baseURL,
            newAPIUserID: newAPIUserID
        )
        return AppSettings(
            profiles: [legacyProfile],
            selectedProfileID: legacyProfile.id,
            refreshInterval: interval > 0 ? interval : AppSettings.default.refreshInterval,
            theme: theme,
            dashboardTheme: dashboardTheme,
            panelSize: panelSize,
            tokenDisplayMode: tokenDisplayMode
        )
    }

    func save(_ settings: AppSettings) {
        if let data = try? JSONEncoder().encode(settings.profiles) {
            defaults.set(data, forKey: "profiles")
        }
        defaults.set(settings.selectedProfileID, forKey: "selectedProfileID")
        defaults.set(settings.refreshInterval, forKey: "refreshInterval")
        defaults.set(settings.theme.rawValue, forKey: "theme")
        defaults.set(settings.dashboardTheme.rawValue, forKey: "dashboardTheme")
        defaults.set(settings.panelSize.rawValue, forKey: "panelSize")
        defaults.set(settings.tokenDisplayMode.rawValue, forKey: "tokenDisplayMode")

        // Keep the old keys for one-way compatibility with older builds.
        let selected = settings.selectedProfile
        defaults.set(selected.baseURL, forKey: "baseURL")
        defaults.set(selected.provider.rawValue, forKey: "provider")
        defaults.set(selected.newAPIUserID, forKey: "newAPIUserID")
    }
}

final class KeychainStore {
    // Use a fresh item name so old ad-hoc-signed entries are never queried on
    // launch. The read query also explicitly forbids UI authentication.
    private let service = "com.codexusage.menubar.v4"
    private let legacyService = "com.codexusage.menubar"
    private let legacyAccount = "sub2api-api-key"

    func readAPIKey() throws -> String? {
        try readAPIKey(for: "legacy-sub2api", includeLegacy: true)
    }

    func readAPIKey(for profileID: String, includeLegacy: Bool = false) throws -> String? {
        let account = account(for: profileID)
        // Do not query legacy services on launch. Older entries may carry an
        // ACL that macOS turns into a password sheet before the app can fail.
        _ = includeLegacy
        return try readValue(service: service, account: account)
    }

    private func readValue(service: String, account: String) throws -> String? {
        let authenticationContext = LAContext()
        authenticationContext.interactionNotAllowed = true
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            // Keep the literal value for the deprecated constant so older
            // ACL-protected items cannot open a system authentication sheet.
            kSecUseAuthenticationUI as String: "fail",
            kSecUseAuthenticationContext as String: authenticationContext
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw UsageServiceError.keychain(status)
        }
        return value
    }

    func saveAPIKey(_ apiKey: String) throws {
        try saveAPIKey(apiKey, for: "legacy-sub2api")
    }

    func saveAPIKey(_ apiKey: String, for profileID: String) throws {
        let account = account(for: profileID)
        try saveValue(apiKey, service: service, account: account)
        // Do not leave a second copy behind after a successful migration.
        try? deleteValue(service: legacyService, account: account)
    }

    private func saveValue(_ value: String, service: String, account: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw UsageServiceError.keychain(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw UsageServiceError.keychain(updateStatus)
        }
    }

    func deleteAPIKey() throws {
        try deleteAPIKey(for: "legacy-sub2api", includeLegacy: true)
    }

    func deleteAPIKey(for profileID: String, includeLegacy: Bool = false) throws {
        let account = account(for: profileID)
        try deleteValue(service: service, account: account)
        try deleteValue(service: legacyService, account: account)
        if includeLegacy, account != legacyAccount {
            try deleteValue(service: service, account: legacyAccount)
            try deleteValue(service: legacyService, account: legacyAccount)
        }
    }

    private func deleteValue(service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw UsageServiceError.keychain(status)
        }
    }

    private func account(for profileID: String) -> String {
        profileID == "legacy-sub2api" ? legacyAccount : "api-key-\(profileID)"
    }
}
