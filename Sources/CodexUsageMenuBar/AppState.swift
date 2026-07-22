import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var settings: AppSettings
    @Published private(set) var snapshot: UsageSnapshot?
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?
    @Published private(set) var hasConfiguredAPIKey = false
    @Published private(set) var profileBalances: [String: AccountBalance] = [:]
    @Published private(set) var profileSnapshots: [String: UsageSnapshot] = [:]
    @Published private(set) var profileErrors: [String: String] = [:]
    @Published private(set) var profileLoading: Set<String> = []
    @Published private(set) var profileHistory: [String: [UsageHistoryEntry]] = [:]
    @Published private(set) var profileConfigured: [String: Bool] = [:]

    private let settingsStore: SettingsStore
    private let keychainStore: KeychainStore
    private let historyStore: UsageHistoryStore
    private let injectedProvider: UsageProvider?
    private let isPreviewMode: Bool
    private var apiKeys: [String: String] = [:]
    private var loadedAPIKeyProfiles = Set<String>()
    private var refreshTask: Task<Void, Never>?
    private var historyLoadTask: Task<Void, Never>?
    private var requestTasks: [String: Task<Void, Never>] = [:]
    private var requestGenerations: [String: Int] = [:]

    init(
        settingsStore: SettingsStore = SettingsStore(),
        keychainStore: KeychainStore = KeychainStore(),
        historyStore: UsageHistoryStore = UsageHistoryStore(),
        provider: UsageProvider? = nil,
        initialSettings: AppSettings? = nil,
        previewSnapshot: UsageSnapshot? = nil
    ) {
        self.settingsStore = settingsStore
        self.keychainStore = keychainStore
        self.historyStore = historyStore
        self.injectedProvider = provider
        self.isPreviewMode = previewSnapshot != nil
        self.settings = initialSettings ?? settingsStore.load()

        if let previewSnapshot {
            self.snapshot = previewSnapshot
            self.profileSnapshots[self.settings.selectedProfileID] = previewSnapshot
            self.profileHistory[self.settings.selectedProfileID] = historyStore.entries(for: self.settings.selectedProfileID)
            self.profileConfigured[self.settings.selectedProfileID] = true
            self.hasConfiguredAPIKey = true
            if let balance = previewSnapshot.accountBalance {
                self.profileBalances[self.settings.selectedProfileID] = balance
            }
            return
        }

        let profile = self.settings.selectedProfile
        historyLoadTask = Task { @MainActor [weak self] in
            // Let the status item render before decoding the optional local history.
            await Task.yield()
            guard let self else { return }
            self.profileHistory[profile.id] = self.historyStore.entries(for: profile.id)
        }
        if profile.provider != .officialCodex {
            do {
                let key = try keychainStore.readAPIKey(
                    for: profile.id,
                    includeLegacy: false
                ) ?? ""
                apiKeys[profile.id] = key
                loadedAPIKeyProfiles.insert(profile.id)
            } catch {
                self.lastError = error.localizedDescription
                loadedAPIKeyProfiles.insert(profile.id)
            }
        }
        self.hasConfiguredAPIKey = isConfigured(profile)
        self.profileConfigured[profile.id] = self.hasConfiguredAPIKey
    }

    deinit {
        refreshTask?.cancel()
        historyLoadTask?.cancel()
        requestTasks.values.forEach { $0.cancel() }
    }

    var selectedProfile: ProviderProfile { settings.selectedProfile }

    var hasAnyConfiguredProfile: Bool { profileConfigured.values.contains(true) }

    func start() {
        guard !isPreviewMode else { return }
        scheduleRefreshTimer()
        refresh()
    }

    func refresh() {
        guard !isPreviewMode else { return }
        guard !isLoading else { return }
        for profile in settings.profiles {
            refreshProfile(profile.id)
        }
    }

    func loadStoredAPIKey() throws -> String {
        let profile = selectedProfile
        guard profile.provider != .officialCodex else { return "" }
        return try loadStoredAPIKey(for: profile)
    }

    func loadStoredAPIKey(for profileID: String) throws -> String {
        guard let profile = settings.profiles.first(where: { $0.id == profileID }) else {
            throw UsageServiceError.invalidConfiguration("找不到供应商配置")
        }
        guard profile.provider != .officialCodex else { return "" }
        return try loadStoredAPIKey(for: profile)
    }

    func selectProfile(_ profileID: String) {
        guard settings.profiles.contains(where: { $0.id == profileID }) else { return }
        guard profileID != settings.selectedProfileID else { return }

        settings.selectedProfileID = profileID
        settingsStore.save(settings)

        do {
            let profile = selectedProfile
            if profile.provider != .officialCodex { _ = try loadStoredAPIKey(for: profile) }
            hasConfiguredAPIKey = isConfigured(profile)
            profileConfigured[profile.id] = hasConfiguredAPIKey
            snapshot = profileSnapshots[profileID]
            lastError = profileErrors[profileID]
            if hasConfiguredAPIKey && snapshot == nil {
                refreshProfile(profileID)
            }
        } catch {
            hasConfiguredAPIKey = false
            lastError = error.localizedDescription
        }
    }

    func saveProfile(
        id profileID: String,
        name: String,
        provider: ProviderKind,
        baseURL: String,
        apiKey: String,
        newAPIUserID: String,
        refreshInterval: TimeInterval,
        theme: ThemeMode
    ) throws {
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let configuration = try ProviderConfiguration(
            provider: provider,
            baseURL: baseURL,
            apiKey: cleanKey,
            newAPIUserID: newAPIUserID,
            requireAPIKey: false
        )
        let profile = ProviderProfile(
            id: profileID,
            name: name,
            provider: provider,
            baseURL: configuration.baseURL?.absoluteString ?? "",
            newAPIUserID: configuration.newAPIUserID
        )

        var profiles = settings.profiles
        if let index = profiles.firstIndex(where: { $0.id == profileID }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        let nextSettings = AppSettings(
            profiles: profiles,
            selectedProfileID: profileID,
            refreshInterval: refreshInterval,
            theme: theme,
            dashboardTheme: settings.dashboardTheme,
            panelSize: settings.panelSize,
            tokenDisplayMode: settings.tokenDisplayMode
        )
        cancelProfileRequest(profileID)

        if provider == .officialCodex {
            try keychainStore.deleteAPIKey(
                for: profileID,
                includeLegacy: profileID == "legacy-sub2api"
            )
            apiKeys.removeValue(forKey: profileID)
        } else if configuration.apiKey.isEmpty {
            try keychainStore.deleteAPIKey(
                for: profileID,
                includeLegacy: profileID == "legacy-sub2api"
            )
            apiKeys[profileID] = ""
        } else {
            // Store the normalized token so the UI and requests do not carry
            // an accidental "Bearer " prefix from a pasted header value.
            try keychainStore.saveAPIKey(configuration.apiKey, for: profileID)
            apiKeys[profileID] = configuration.apiKey
        }
        // Commit the profile only after its credential operation succeeded.
        settingsStore.save(nextSettings)
        loadedAPIKeyProfiles.insert(profileID)
        settings = nextSettings
        hasConfiguredAPIKey = isConfigured(profile)
        profileConfigured[profile.id] = hasConfiguredAPIKey
        lastError = nil
        snapshot = nil
        profileSnapshots.removeValue(forKey: profileID)
        profileErrors.removeValue(forKey: profileID)
        profileBalances.removeValue(forKey: profileID)
        profileHistory[profileID] = historyStore.entries(for: profileID)
        scheduleRefreshTimer()
        refreshProfile(profileID)
    }

    func deleteProfile(_ profileID: String) {
        guard settings.profiles.count > 1 else {
            lastError = "至少保留一个供应商配置"
            return
        }
        guard settings.profiles.contains(where: { $0.id == profileID }) else { return }

        cancelProfileRequest(profileID)
        do {
            try keychainStore.deleteAPIKey(
                for: profileID,
                includeLegacy: profileID == "legacy-sub2api"
            )
        } catch {
            lastError = error.localizedDescription
            return
        }

        let remaining = settings.profiles.filter { $0.id != profileID }
        let nextSelectedID = profileID == settings.selectedProfileID
            ? remaining[0].id
            : settings.selectedProfileID
        settings = AppSettings(
            profiles: remaining,
            selectedProfileID: nextSelectedID,
            refreshInterval: settings.refreshInterval,
            theme: settings.theme,
            dashboardTheme: settings.dashboardTheme,
            panelSize: settings.panelSize,
            tokenDisplayMode: settings.tokenDisplayMode
        )
        settingsStore.save(settings)
        apiKeys.removeValue(forKey: profileID)
        loadedAPIKeyProfiles.remove(profileID)
        profileSnapshots.removeValue(forKey: profileID)
        profileErrors.removeValue(forKey: profileID)
        profileLoading.remove(profileID)
        profileHistory.removeValue(forKey: profileID)
        profileConfigured.removeValue(forKey: profileID)
        profileBalances.removeValue(forKey: profileID)
        snapshot = profileSnapshots[nextSelectedID]
        lastError = nil
        updateLoadingState()
        hasConfiguredAPIKey = isConfigured(selectedProfile)
        scheduleRefreshTimer()
        if snapshot == nil { refreshProfile(nextSelectedID) }
    }

    func setTheme(_ theme: ThemeMode) {
        settings.theme = theme
        settingsStore.save(settings)
    }

    func savePreferences(
        refreshInterval: TimeInterval,
        theme: ThemeMode,
        dashboardTheme: DashboardTheme,
        panelSize: PanelSize,
        tokenDisplayMode: TokenDisplayMode
    ) {
        settings = AppSettings(
            profiles: settings.profiles,
            selectedProfileID: settings.selectedProfileID,
            refreshInterval: refreshInterval,
            theme: theme,
            dashboardTheme: dashboardTheme,
            panelSize: panelSize,
            tokenDisplayMode: tokenDisplayMode
        )
        settingsStore.save(settings)
        scheduleRefreshTimer()
    }

    func setDashboardTheme(_ dashboardTheme: DashboardTheme) {
        settings.dashboardTheme = dashboardTheme
        settingsStore.save(settings)
    }

    func setPanelSize(_ panelSize: PanelSize) {
        settings.panelSize = panelSize
        settingsStore.save(settings)
    }

    func setTokenDisplayMode(_ mode: TokenDisplayMode) {
        settings.tokenDisplayMode = mode
        settingsStore.save(settings)
    }

    private func loadStoredAPIKey(for profile: ProviderProfile) throws -> String {
        guard !loadedAPIKeyProfiles.contains(profile.id) else {
            return apiKeys[profile.id] ?? ""
        }
        let key = try keychainStore.readAPIKey(
            for: profile.id,
            includeLegacy: profile.id == "legacy-sub2api"
        ) ?? ""
        apiKeys[profile.id] = key
        loadedAPIKeyProfiles.insert(profile.id)
        return key
    }

    private func isCurrentRequest(_ generation: Int, profileID: String) -> Bool {
        requestGenerations[profileID] == generation
    }

    private func cancelProfileRequest(_ profileID: String) {
        requestGenerations[profileID, default: 0] += 1
        requestTasks[profileID]?.cancel()
        requestTasks.removeValue(forKey: profileID)
        profileLoading.remove(profileID)
        updateLoadingState()
    }

    private func refreshProfile(_ profileID: String) {
        guard let profile = settings.profiles.first(where: { $0.id == profileID }) else { return }
        cancelProfileRequest(profileID)
        do {
            let apiKey: String
            if profile.provider == .officialCodex {
                apiKey = ""
            } else {
                apiKey = try loadStoredAPIKeySilently(for: profile)
            }
            guard profile.provider == .officialCodex || !apiKey.isEmpty else {
                hasConfiguredAPIKey = profile.id == selectedProfile.id ? false : hasConfiguredAPIKey
                profileConfigured[profile.id] = false
                profileErrors[profile.id] = "尚未配置访问凭据"
                if profile.id == selectedProfile.id { lastError = profileErrors[profile.id] }
                return
            }
            let configuration = try ProviderConfiguration(
                provider: profile.provider,
                baseURL: profile.baseURL,
                apiKey: apiKey,
                newAPIUserID: profile.newAPIUserID
            )
            let provider = injectedProvider ?? UsageProviderFactory.make(for: profile.provider)
            profileConfigured[profile.id] = true
            profileLoading.insert(profileID)
            profileErrors.removeValue(forKey: profileID)
            if profile.id == selectedProfile.id { lastError = nil }
            updateLoadingState()
            let generation = requestGenerations[profileID, default: 0] + 1
            requestGenerations[profileID] = generation
            requestTasks[profileID] = Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let nextSnapshot = try await provider.fetchUsage(configuration: configuration)
                    guard self.isCurrentRequest(generation, profileID: profile.id) else { return }
                    self.profileSnapshots[profile.id] = nextSnapshot
                    self.historyStore.record(snapshot: nextSnapshot, profile: profile)
                    self.profileHistory[profile.id] = self.historyStore.entries(for: profile.id)
                    if let balance = nextSnapshot.accountBalance { self.profileBalances[profile.id] = balance }
                    if profile.id == self.selectedProfile.id {
                        self.snapshot = nextSnapshot
                        self.lastError = nil
                    }
                } catch is CancellationError {
                    return
                } catch {
                    guard self.isCurrentRequest(generation, profileID: profile.id) else { return }
                    self.profileErrors[profile.id] = error.localizedDescription
                    if profile.id == self.selectedProfile.id { self.lastError = error.localizedDescription }
                }
                guard self.isCurrentRequest(generation, profileID: profile.id) else { return }
                self.profileLoading.remove(profile.id)
                self.requestTasks.removeValue(forKey: profile.id)
                self.updateLoadingState()
            }
        } catch {
            profileConfigured[profile.id] = false
            profileErrors[profile.id] = error.localizedDescription
            if profile.id == selectedProfile.id {
                hasConfiguredAPIKey = false
                lastError = error.localizedDescription
            }
        }
    }

    private func updateLoadingState() {
        isLoading = !profileLoading.isEmpty
    }

    private func loadStoredAPIKeySilently(for profile: ProviderProfile) throws -> String {
        guard !loadedAPIKeyProfiles.contains(profile.id) else { return apiKeys[profile.id] ?? "" }
        let key = try keychainStore.readAPIKey(for: profile.id, includeLegacy: false) ?? ""
        apiKeys[profile.id] = key
        loadedAPIKeyProfiles.insert(profile.id)
        return key
    }

    private func isConfigured(_ profile: ProviderProfile) -> Bool {
        profile.provider == .officialCodex || !(apiKeys[profile.id] ?? "").isEmpty
    }

    private func scheduleRefreshTimer() {
        refreshTask?.cancel()
        let safeInterval = min(max(settings.refreshInterval, 1), 86_400)
        let interval = UInt64(safeInterval * 1_000_000_000)
        refreshTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: interval)
                } catch {
                    break
                }
                guard let self, !Task.isCancelled else { break }
                self.refresh()
            }
        }
    }
}
