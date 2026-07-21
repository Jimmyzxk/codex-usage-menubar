import Foundation

@main
struct ModelsSmoke {
    static func main() throws {
        let data = #"""
        {"usage":{"today":{"requests":"3","input_tokens":10,"output_tokens":20,"total_tokens":30,"actual_cost":"0.12"},"total":{}},"daily_usage":[],"model_usage":[{"model_name":"gpt-5","requests":3,"input_tokens":10,"output_tokens":20,"actual_cost":0.12}]}
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(Sub2APIUsageResponse.self, from: data)
        precondition(response.usage.today.requests == 3)
        precondition(response.usage.today.totalTokens == 30)
        precondition(response.usage.today.actualCost == 0.12)
        precondition(response.modelUsage.first?.id == "gpt-5")

        let failedSub2API = #"{"success":false,"message":"invalid key"}"#.data(using: .utf8)!
        let failedResponse = try JSONDecoder().decode(Sub2APIUsageResponse.self, from: failedSub2API)
        precondition(!failedResponse.hasUsagePayload)
        precondition(failedResponse.success == false)

        let dashboardModels = #"{"code":0,"message":"","data":{"models":[{"model":"gpt-5.2-codex","requests":3,"input_tokens":10,"output_tokens":20,"cache_read_tokens":6,"total_tokens":30,"actual_cost":0.12}]}}"#.data(using: .utf8)!
        let dashboardResponse = try JSONDecoder().decode(Sub2APIModelsResponse.self, from: dashboardModels)
        precondition(dashboardResponse.models.first?.model == "gpt-5.2-codex")
        precondition(dashboardResponse.models.first?.cacheReadTokens == 6)
        precondition(ModelDescriptor(rawID: "gpt-5.2-codex").version == "5.2")

        let sub2APIAccount = #"{"code":0,"message":"","data":{"balance":12.5}}"#.data(using: .utf8)!
        let sub2APIAccountResponse = try JSONDecoder().decode(Sub2APIAccountResponse.self, from: sub2APIAccount)
        precondition(sub2APIAccountResponse.balance == 12.5)
        let missingBalance = #"{"success":true,"message":"missing"}"#.data(using: .utf8)!
        let missingBalanceResponse = try JSONDecoder().decode(Sub2APIAccountResponse.self, from: missingBalance)
        precondition(!missingBalanceResponse.hasBalance)

        let newAPIAccount = #"{"success":true,"message":"","data":{"quota":100000,"used_quota":25000}}"#.data(using: .utf8)!
        let newAPIAccountResponse = try JSONDecoder().decode(NewAPIAccountResponse.self, from: newAPIAccount)
        precondition(newAPIAccountResponse.quota - newAPIAccountResponse.usedQuota == 75000)
        precondition(newAPIAccountResponse.hasQuotaData)
        let missingQuota = #"{"message":"missing"}"#.data(using: .utf8)!
        let missingQuotaResponse = try JSONDecoder().decode(NewAPIAccountResponse.self, from: missingQuota)
        precondition(!missingQuotaResponse.success)
        precondition(!missingQuotaResponse.hasQuotaData)

        let config = try ProviderConfiguration(
            baseURL: "http://localhost:8080/",
            apiKey: "Bearer sk-test"
        )
        precondition(config.usageURL.absoluteString == "http://localhost:8080/v1/usage")
        precondition(config.apiKey == "sk-test")
        let clearedConfig = try ProviderConfiguration(
            baseURL: "http://localhost:8080",
            apiKey: "",
            requireAPIKey: false
        )
        precondition(clearedConfig.apiKey.isEmpty)

        let newAPIConfig = try ProviderConfiguration(
            provider: .newAPI,
            baseURL: "https://newapi.example.com/",
            apiKey: "access-token",
            newAPIUserID: "42"
        )
        precondition(newAPIConfig.newAPILogsURL.absoluteString == "https://newapi.example.com/api/log/self")
        for input in [
            "https://newapi.example.com/api",
            "https://newapi.example.com/api/",
            "https://newapi.example.com/api/v1",
            "https://newapi.example.com/api/v1/"
        ] {
            let config = try ProviderConfiguration(
                provider: .newAPI,
                baseURL: input,
                apiKey: "access-token",
                newAPIUserID: "42"
            )
            precondition(config.newAPILogsURL.absoluteString == "https://newapi.example.com/api/log/self")
        }

        let newAPILogData = #"{"success":true,"message":"","data":{"total":1,"items":[{"model_name":"gpt-5","prompt_tokens":10,"completion_tokens":"20","quota":3.5,"use_time":420,"created_at":1784376000,"other":{"trace":"ignored"}}]}}"#.data(using: .utf8)!
        let newAPILogs = try JSONDecoder().decode(NewAPILogsResponse.self, from: newAPILogData)
        precondition(newAPILogs.success)
        precondition(newAPILogs.data?.items.first?.totalTokens == 30)

        let officialConfig = try ProviderConfiguration(provider: .officialCodex)
        precondition(officialConfig.baseURL == nil)

        let profiles = [
            ProviderProfile(id: "sub", name: "公司 Sub2API", provider: .sub2api, baseURL: "https://sub.example.com"),
            ProviderProfile(id: "new", name: "个人 NewAPI", provider: .newAPI, baseURL: "https://new.example.com", newAPIUserID: "7")
        ]
        let settings = AppSettings(
            profiles: profiles,
            selectedProfileID: "new",
            refreshInterval: 300,
            theme: .dark,
            dashboardTheme: .pulse,
            panelSize: .compact,
            tokenDisplayMode: .full
        )
        precondition(settings.selectedProfile.provider == .newAPI)
        precondition(settings.theme == .dark)
        precondition(settings.dashboardTheme == .pulse)
        precondition(settings.panelSize == .compact)
        precondition(settings.tokenDisplayMode == .full)
        precondition(DashboardTheme.allCases.count == 3)
        precondition(PanelSize.compact.height < PanelSize.standard.height)
        precondition(PanelSize.standard.height < PanelSize.spacious.height)
        precondition(PanelSize.standard.height == 540)

        let suiteName = "com.codexusage.models-smoke.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = SettingsStore(defaults: defaults)
        store.save(settings)
        let restored = store.load()
        precondition(restored.dashboardTheme == .pulse)
        precondition(restored.theme == .dark)
        precondition(restored.panelSize == .compact)
        precondition(restored.tokenDisplayMode == .full)
        defaults.removePersistentDomain(forName: suiteName)
        print("models smoke test passed")
    }
}
