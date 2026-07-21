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

    private let settingsStore: SettingsStore
    private let keychainStore: KeychainStore
    private let injectedProvider: UsageProvider?
    private let isPreviewMode: Bool
    private var apiKeys: [String: String] = [:]
    private var loadedAPIKeyProfiles = Set<String>()
    private var refreshTask: Task<Void, Never>?
    private var requestTask: Task<Void, Never>?
    private var requestGeneration = 0

    init(
        settingsStore: SettingsStore = SettingsStore(),
        keychainStore: KeychainStore = KeychainStore(),
        provider: UsageProvider? = nil,
        initialSettings: AppSettings? = nil,
        previewSnapshot: UsageSnapshot? = nil
    ) {
        self.settingsStore = settingsStore
        self.keychainStore = keychainStore
        self.injectedProvider = provider
        self.isPreviewMode = previewSnapshot != nil
        self.settings = initialSettings ?? settingsStore.load()

        if let previewSnapshot {
            self.snapshot = previewSnapshot
            self.hasConfiguredAPIKey = true
            if let balance = previewSnapshot.accountBalance {
                self.profileBalances[self.settings.selectedProfileID] = balance
            }
            return
        }

        let profile = self.settings.selectedProfile
        if profile.provider != .officialCodex {
            do {
                let key = try keychainStore.readAPIKey(
                    for: profile.id,
                    includeLegacy: profile.id == "legacy-sub2api"
                ) ?? ""
                apiKeys[profile.id] = key
                loadedAPIKeyProfiles.insert(profile.id)
            } catch {
                self.lastError = error.localizedDescription
                loadedAPIKeyProfiles.insert(profile.id)
            }
        }
        self.hasConfiguredAPIKey = isConfigured(profile)
    }

    deinit {
        refreshTask?.cancel()
        requestTask?.cancel()
    }

    var selectedProfile: ProviderProfile { settings.selectedProfile }

    func start() {
        guard !isPreviewMode else { return }
        guard hasConfiguredAPIKey else { return }
        scheduleRefreshTimer()
        refresh()
    }

    func refresh() {
        guard !isPreviewMode else { return }
        guard !isLoading else { return }
        let profile = selectedProfile
        let apiKey = apiKeys[profile.id] ?? ""
        guard profile.provider == .officialCodex || !apiKey.isEmpty else {
            hasConfiguredAPIKey = false
            return
        }

        do {
            let configuration = try ProviderConfiguration(
                provider: profile.provider,
                baseURL: profile.baseURL,
                apiKey: apiKey,
                newAPIUserID: profile.newAPIUserID
            )
            let provider = injectedProvider ?? UsageProviderFactory.make(for: profile.provider)
            isLoading = true
            lastError = nil
            requestGeneration += 1
            let generation = requestGeneration

            requestTask = Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let nextSnapshot = try await provider.fetchUsage(configuration: configuration)
                    guard self.isCurrentRequest(generation, profileID: profile.id) else { return }
                    self.snapshot = nextSnapshot
                    if let balance = nextSnapshot.accountBalance {
                        self.profileBalances[profile.id] = balance
                    }
                    self.lastError = nil
                } catch is CancellationError {
                    return
                } catch {
                    guard self.isCurrentRequest(generation, profileID: profile.id) else { return }
                    self.lastError = error.localizedDescription
                }
                guard self.isCurrentRequest(generation, profileID: profile.id) else { return }
                self.isLoading = false
                self.requestTask = nil
            }
        } catch {
            lastError = error.localizedDescription
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

        refreshTask?.cancel()
        refreshTask = nil
        cancelInFlightRequest()
        snapshot = nil
        lastError = nil
        settings.selectedProfileID = profileID
        settingsStore.save(settings)

        do {
            let profile = selectedProfile
            if profile.provider != .officialCodex {
                _ = try loadStoredAPIKey(for: profile)
            }
            hasConfiguredAPIKey = isConfigured(profile)
            if hasConfiguredAPIKey {
                scheduleRefreshTimer()
                refresh()
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
        cancelInFlightRequest()

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
        lastError = nil
        snapshot = nil
        profileBalances.removeValue(forKey: profileID)
        scheduleRefreshTimer()
        refresh()
    }

    func deleteProfile(_ profileID: String) {
        guard settings.profiles.count > 1 else {
            lastError = "至少保留一个供应商配置"
            return
        }
        guard settings.profiles.contains(where: { $0.id == profileID }) else { return }

        cancelInFlightRequest()
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
        profileBalances.removeValue(forKey: profileID)
        snapshot = nil
        lastError = nil
        isLoading = false
        hasConfiguredAPIKey = isConfigured(selectedProfile)
        scheduleRefreshTimer()
        refresh()
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
        requestGeneration == generation && selectedProfile.id == profileID
    }

    private func cancelInFlightRequest() {
        requestGeneration += 1
        requestTask?.cancel()
        requestTask = nil
        isLoading = false
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
