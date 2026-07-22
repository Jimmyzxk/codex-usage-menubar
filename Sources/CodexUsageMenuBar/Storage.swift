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

struct UsageHistoryEntry: Codable, Equatable, Identifiable {
    let id: String
    let profileID: String
    let profileName: String
    let provider: String
    let dateKey: String
    let capturedAt: Date
    let requests: Int
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int
    let charge: Double
    let balance: Double?
}

final class UsageHistoryStore {
    private let defaults: UserDefaults
    private let key = "usageHistory.v1"
    private let retention: TimeInterval = 90 * 86_400
    private let maxEntries = 2_000
    private var cachedEntries: [UsageHistoryEntry]?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func entries(for profileID: String) -> [UsageHistoryEntry] {
        load()
            .filter { $0.profileID == profileID }
            .sorted { $0.capturedAt < $1.capturedAt }
    }

    func record(snapshot: UsageSnapshot, profile: ProviderProfile, at date: Date = Date()) {
        let hour = floor(date.timeIntervalSince1970 / 3_600) * 3_600
        let bucketDate = Date(timeIntervalSince1970: hour)
        let components = Calendar.current.dateComponents([.year, .month, .day], from: bucketDate)
        let dateKey = String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
        var entries = load().filter { $0.capturedAt >= date.addingTimeInterval(-retention) }
        let currentEntry = UsageHistoryEntry(
            id: "\(profile.id)|hour|\(Int(hour))",
            profileID: profile.id,
            profileName: profile.displayName,
            provider: profile.provider.rawValue,
            dateKey: dateKey,
            capturedAt: date,
            requests: snapshot.today.requests,
            inputTokens: snapshot.today.inputTokens,
            outputTokens: snapshot.today.outputTokens,
            totalTokens: snapshot.today.totalTokens,
            charge: snapshot.today.actualCost,
            balance: snapshot.accountBalance?.value
        )
        let dailyEntries = snapshot.dailyUsage.map { item in
            UsageHistoryEntry(
                id: "\(profile.id)|day|\(item.date)",
                profileID: profile.id,
                profileName: profile.displayName,
                provider: profile.provider.rawValue,
                dateKey: item.date,
                capturedAt: date,
                requests: item.requests,
                inputTokens: item.inputTokens,
                outputTokens: item.outputTokens,
                totalTokens: item.totalTokens,
                charge: item.actualCost,
                balance: item.date == dateKey ? snapshot.accountBalance?.value : nil
            )
        }
        for entry in [currentEntry] + dailyEntries {
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index] = entry
            } else {
                entries.append(entry)
            }
        }
        entries.sort { $0.capturedAt < $1.capturedAt }
        if entries.count > maxEntries {
            entries = Array(entries.suffix(maxEntries))
        }
        save(entries)
    }

    private func load() -> [UsageHistoryEntry] {
        if let cachedEntries { return cachedEntries }
        guard let data = defaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([UsageHistoryEntry].self, from: data) else {
            cachedEntries = []
            return []
        }
        cachedEntries = entries
        return entries
    }

    private func save(_ entries: [UsageHistoryEntry]) {
        cachedEntries = entries
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: key)
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
        if let value = try readValue(service: service, account: account, allowAuthentication: false) {
            return value
        }
        guard includeLegacy else { return nil }

        // Legacy entries are checked only after an explicit user action (for
        // example opening a profile in Settings), never during app startup.
        if let value = try readValue(service: legacyService, account: account, allowAuthentication: true) {
            migrateLegacyValue(value, account: account)
            return value
        }
        if profileID == "legacy-sub2api", account != legacyAccount {
            if let value = try readValue(service: legacyService, account: legacyAccount, allowAuthentication: true) {
                migrateLegacyValue(value, account: legacyAccount)
                return value
            }
        }
        return nil
    }

    private func readValue(service: String, account: String, allowAuthentication: Bool) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var authenticatedQuery = query
        if !allowAuthentication {
            let authenticationContext = LAContext()
            authenticationContext.interactionNotAllowed = true
            // Keep the literal value for the deprecated constant so old
            // ACL-protected items cannot open a system authentication sheet.
            authenticatedQuery[kSecUseAuthenticationUI as String] = "fail"
            authenticatedQuery[kSecUseAuthenticationContext as String] = authenticationContext
        }

        var result: CFTypeRef?
        let status = SecItemCopyMatching(authenticatedQuery as CFDictionary, &result)
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
        // The v4 item is already the source of truth. Cleanup of an old ACL
        // protected item must not make a successful save look like a failure.
        try? deleteValue(service: legacyService, account: account, allowAuthentication: false)
    }

    private func migrateLegacyValue(_ value: String, account: String) {
        guard (try? saveValue(value, service: service, account: account)) != nil else { return }
        // A failed cleanup is harmless on the next launch because the v4 item
        // is read first and legacy reads remain limited to explicit settings.
        try? deleteValue(service: legacyService, account: account, allowAuthentication: false)
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
        try deleteValue(service: service, account: account, allowAuthentication: true)
        try deleteValue(service: legacyService, account: account, allowAuthentication: true)
        if includeLegacy, account != legacyAccount {
            try deleteValue(service: service, account: legacyAccount, allowAuthentication: true)
            try deleteValue(service: legacyService, account: legacyAccount, allowAuthentication: true)
        }
    }

    private func deleteValue(service: String, account: String, allowAuthentication: Bool) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        var authenticatedQuery = query
        if !allowAuthentication {
            let authenticationContext = LAContext()
            authenticationContext.interactionNotAllowed = true
            authenticatedQuery[kSecUseAuthenticationUI as String] = "fail"
            authenticatedQuery[kSecUseAuthenticationContext as String] = authenticationContext
        }
        let status = SecItemDelete(authenticatedQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw UsageServiceError.keychain(status)
        }
    }

    private func account(for profileID: String) -> String {
        profileID == "legacy-sub2api" ? legacyAccount : "api-key-\(profileID)"
    }
}
