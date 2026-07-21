import Foundation

enum ProviderKind: String, CaseIterable, Identifiable, Codable {
    case sub2api
    case newAPI = "newapi"
    case officialCodex = "official_codex"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sub2api: return "Sub2API"
        case .newAPI: return "NewAPI"
        case .officialCodex: return "官方 Codex"
        }
    }

    var subtitle: String {
        switch self {
        case .sub2api: return "API Key / 今日用量"
        case .newAPI: return "AccessToken + 用户 ID / 用量日志"
        case .officialCodex: return "本机 Codex / 配额窗口"
        }
    }
}

enum ThemeMode: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}

enum DashboardTheme: String, CaseIterable, Identifiable, Codable {
    case clarity
    case graphite
    case pulse

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clarity: return "原生"
        case .graphite: return "彩色卡片"
        case .pulse: return "数据实验室"
        }
    }
}

enum PanelSize: String, CaseIterable, Identifiable, Codable {
    case compact
    case standard
    case spacious

    var id: String { rawValue }

    var title: String {
        switch self {
        case .compact: return "紧凑"
        case .standard: return "标准"
        case .spacious: return "宽松"
        }
    }

    var width: Double {
        switch self {
        case .compact: return 390
        case .standard: return 410
        case .spacious: return 450
        }
    }

    var height: Double {
        switch self {
        case .compact: return 500
        case .standard: return 540
        case .spacious: return 600
        }
    }
}

enum TokenDisplayMode: String, CaseIterable, Identifiable, Codable {
    case full
    case compact

    var id: String { rawValue }

    var title: String {
        switch self {
        case .full: return "完整"
        case .compact: return "缩写"
        }
    }
}

struct ProviderProfile: Identifiable, Equatable, Codable {
    let id: String
    var name: String
    var provider: ProviderKind
    var baseURL: String
    var newAPIUserID: String

    init(
        id: String = UUID().uuidString,
        name: String = "",
        provider: ProviderKind = .sub2api,
        baseURL: String = "",
        newAPIUserID: String = ""
    ) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.provider = provider
        self.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        self.newAPIUserID = newAPIUserID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var displayName: String {
        name.isEmpty ? provider.title : name
    }

    var detailText: String {
        if provider == .officialCodex { return "本机登录态" }
        guard let url = URL(string: baseURL), let host = url.host else {
            return provider.title
        }
        return "\(provider.title) · \(host)"
    }
}

enum BalanceUnit: Equatable {
    case currency
    case quota
    case credits
}

struct AccountBalance: Equatable {
    let value: Double?
    let rawValue: String?
    let label: String
    let unit: BalanceUnit
}

struct AppSettings: Equatable {
    var profiles: [ProviderProfile]
    var selectedProfileID: String
    var refreshInterval: TimeInterval
    var theme: ThemeMode
    var dashboardTheme: DashboardTheme
    var panelSize: PanelSize
    var tokenDisplayMode: TokenDisplayMode

    init(
        profiles: [ProviderProfile],
        selectedProfileID: String,
        refreshInterval: TimeInterval,
        theme: ThemeMode = .system,
        dashboardTheme: DashboardTheme = .clarity,
        panelSize: PanelSize = .standard,
        tokenDisplayMode: TokenDisplayMode = .compact
    ) {
        let safeProfiles = profiles.isEmpty ? [ProviderProfile(name: "默认供应商", baseURL: AppSettings.defaultBaseURL)] : profiles
        self.profiles = safeProfiles
        self.selectedProfileID = safeProfiles.contains(where: { $0.id == selectedProfileID })
            ? selectedProfileID
            : safeProfiles[0].id
        self.refreshInterval = refreshInterval
        self.theme = theme
        self.dashboardTheme = dashboardTheme
        self.panelSize = panelSize
        self.tokenDisplayMode = tokenDisplayMode
    }

    var selectedProfile: ProviderProfile {
        profiles.first(where: { $0.id == selectedProfileID }) ?? profiles[0]
    }

    // Compatibility accessors for older UI and migration code.
    var baseURL: String { selectedProfile.baseURL }
    var provider: ProviderKind { selectedProfile.provider }
    var newAPIUserID: String { selectedProfile.newAPIUserID }

    static let `default` = AppSettings(
        profiles: [ProviderProfile(
            id: "legacy-sub2api",
            name: "默认 Sub2API",
            provider: .sub2api,
            baseURL: defaultBaseURL
        )],
        selectedProfileID: "legacy-sub2api",
        refreshInterval: 300,
        theme: .system
    )

    static let defaultBaseURL = "http://localhost:8080"
}

struct ProviderConfiguration {
    let provider: ProviderKind
    let baseURL: URL?
    let apiKey: String
    let newAPIUserID: String

    init(
        provider: ProviderKind = .sub2api,
        baseURL: String = "",
        apiKey: String = "",
        newAPIUserID: String = "",
        requireAPIKey: Bool = true
    ) throws {
        let trimmedURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        var normalizedURL: URL?
        if provider != .officialCodex {
            guard var components = URLComponents(string: trimmedURL),
                  let scheme = components.scheme?.lowercased(),
                  ["http", "https"].contains(scheme),
                  components.host != nil,
                  components.user == nil,
                  components.password == nil else {
                throw UsageServiceError.invalidConfiguration("请输入有效的 http 或 https 服务地址")
            }

            var pathComponents = components.path
                .split(separator: "/")
                .map(String.init)
            if provider == .newAPI {
                // NewAPI's endpoints already include /api. Accept the common
                // console URL forms without producing /api/api/... requests.
                let lowercasedPath = pathComponents.map { $0.lowercased() }
                if lowercasedPath.suffix(2).elementsEqual(["api", "v1"]) {
                    pathComponents.removeLast(2)
                } else if lowercasedPath.last == "api" || lowercasedPath.last == "v1" {
                    pathComponents.removeLast()
                }
            }
            components.path = pathComponents.isEmpty ? "" : "/" + pathComponents.joined(separator: "/")
            components.query = nil
            components.fragment = nil

            guard let url = components.url else {
                throw UsageServiceError.invalidConfiguration("服务地址格式不正确")
            }
            normalizedURL = url
        }

        var trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKey.lowercased().hasPrefix("bearer ") {
            trimmedKey = String(trimmedKey.dropFirst("bearer ".count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if requireAPIKey && provider != .officialCodex && trimmedKey.isEmpty {
            throw UsageServiceError.invalidConfiguration(provider == .newAPI ? "请填写 NewAPI AccessToken" : "请填写 API Key")
        }

        if provider == .newAPI {
            guard let userID = Int(newAPIUserID.trimmingCharacters(in: .whitespacesAndNewlines)), userID > 0 else {
                throw UsageServiceError.invalidConfiguration("请填写 NewAPI 用户 ID")
            }
        }

        self.provider = provider
        self.baseURL = normalizedURL
        self.apiKey = trimmedKey
        self.newAPIUserID = newAPIUserID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var usageURL: URL {
        baseURL!.appendingPathComponent("v1/usage")
    }

    var newAPILogsURL: URL {
        baseURL!.appendingPathComponent("api/log/self")
    }

    var newAPIStatsURL: URL {
        baseURL!.appendingPathComponent("api/log/self/stat")
    }

    var sub2APIModelsURL: URL {
        baseURL!.appendingPathComponent("api/v1/usage/dashboard/models")
    }

    var sub2APICurrentUserURL: URL {
        baseURL!.appendingPathComponent("api/v1/auth/me")
    }

    var newAPISelfURL: URL {
        baseURL!.appendingPathComponent("api/user/self")
    }
}

struct UsageBucket: Equatable, Decodable {
    let requests: Int
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let totalTokens: Int
    let actualCost: Double
    let standardCost: Double

    static let zero = UsageBucket(
        requests: 0,
        inputTokens: 0,
        outputTokens: 0,
        cacheCreationTokens: 0,
        cacheReadTokens: 0,
        totalTokens: 0,
        actualCost: 0,
        standardCost: 0
    )

    private enum CodingKeys: String, CodingKey {
        case requests
        case requestCount = "request_count"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case cacheCreationTokens = "cache_creation_tokens"
        case cacheReadTokens = "cache_read_tokens"
        case totalTokens = "total_tokens"
        case actualCost = "actual_cost"
        case cost
        case standardCost = "standard_cost"
    }

    init(
        requests: Int,
        inputTokens: Int,
        outputTokens: Int,
        cacheCreationTokens: Int,
        cacheReadTokens: Int,
        totalTokens: Int,
        actualCost: Double,
        standardCost: Double
    ) {
        self.requests = requests
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cacheCreationTokens = cacheCreationTokens
        self.cacheReadTokens = cacheReadTokens
        self.totalTokens = totalTokens
        self.actualCost = actualCost
        self.standardCost = standardCost
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        requests = container.decodeInt(for: [.requests, .requestCount])
        inputTokens = container.decodeInt(for: [.inputTokens])
        outputTokens = container.decodeInt(for: [.outputTokens])
        cacheCreationTokens = container.decodeInt(for: [.cacheCreationTokens])
        cacheReadTokens = container.decodeInt(for: [.cacheReadTokens])
        totalTokens = container.decodeInt(for: [.totalTokens])
        actualCost = container.decodeDouble(for: [.actualCost, .cost])
        standardCost = container.decodeDouble(for: [.standardCost, .cost])
    }
}

struct UsagePayload: Equatable, Decodable {
    let today: UsageBucket
    let total: UsageBucket
    let averageDurationMs: Double
    let rpm: Double
    let tpm: Double

    private enum CodingKeys: String, CodingKey {
        case today
        case total
        case averageDurationMs = "average_duration_ms"
        case rpm
        case tpm
    }

    init(today: UsageBucket, total: UsageBucket, averageDurationMs: Double = 0, rpm: Double = 0, tpm: Double = 0) {
        self.today = today
        self.total = total
        self.averageDurationMs = averageDurationMs
        self.rpm = rpm
        self.tpm = tpm
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        today = try container.decodeIfPresent(UsageBucket.self, forKey: .today) ?? .zero
        total = try container.decodeIfPresent(UsageBucket.self, forKey: .total) ?? .zero
        averageDurationMs = container.decodeDouble(for: [.averageDurationMs])
        rpm = container.decodeDouble(for: [.rpm])
        tpm = container.decodeDouble(for: [.tpm])
    }
}

struct DailyUsage: Equatable, Decodable, Identifiable {
    let date: String
    let requests: Int
    let inputTokens: Int
    let outputTokens: Int
    let cacheReadTokens: Int
    let cacheWriteTokens: Int
    let totalTokens: Int
    let actualCost: Double

    var id: String { date }

    init(
        date: String,
        requests: Int,
        inputTokens: Int,
        outputTokens: Int,
        cacheReadTokens: Int,
        cacheWriteTokens: Int,
        totalTokens: Int,
        actualCost: Double
    ) {
        self.date = date
        self.requests = requests
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cacheReadTokens = cacheReadTokens
        self.cacheWriteTokens = cacheWriteTokens
        self.totalTokens = totalTokens
        self.actualCost = actualCost
    }

    private enum CodingKeys: String, CodingKey {
        case date
        case requests
        case requestCount = "request_count"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case cacheReadTokens = "cache_read_tokens"
        case cacheWriteTokens = "cache_write_tokens"
        case cacheCreationTokens = "cache_creation_tokens"
        case totalTokens = "total_tokens"
        case actualCost = "actual_cost"
        case cost
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
        requests = container.decodeInt(for: [.requests, .requestCount])
        inputTokens = container.decodeInt(for: [.inputTokens])
        outputTokens = container.decodeInt(for: [.outputTokens])
        cacheReadTokens = container.decodeInt(for: [.cacheReadTokens])
        cacheWriteTokens = max(
            container.decodeInt(for: [.cacheWriteTokens]),
            container.decodeInt(for: [.cacheCreationTokens])
        )
        totalTokens = container.decodeInt(for: [.totalTokens])
        actualCost = container.decodeDouble(for: [.actualCost, .cost])
    }
}

struct Sub2APIUsageResponse: Decodable {
    let usage: UsagePayload
    let dailyUsage: [DailyUsage]
    let modelUsage: [ModelUsage]
    let success: Bool?
    let code: Int?
    let message: String
    let hasUsagePayload: Bool

    private enum CodingKeys: String, CodingKey {
        case usage
        case today
        case total
        case dailyUsage = "daily_usage"
        case modelUsage = "model_usage"
        case modelStats = "model_stats"
        case models
        case success
        case code
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try? container.decode(Bool.self, forKey: .success)
        code = container.contains(.code) ? container.decodeInt(for: [.code]) : nil
        message = (try? container.decode(String.self, forKey: .message)) ?? ""
        hasUsagePayload = container.contains(.usage) || container.contains(.today) || container.contains(.total)
        if let nestedUsage = try container.decodeIfPresent(UsagePayload.self, forKey: .usage) {
            usage = nestedUsage
        } else {
            usage = try UsagePayload(from: decoder)
        }
        dailyUsage = try container.decodeIfPresent([DailyUsage].self, forKey: .dailyUsage) ?? []
        let rawModels = (try? container.decode([Sub2APIModelUsage].self, forKey: .modelUsage))
            ?? (try? container.decode([Sub2APIModelUsage].self, forKey: .modelStats))
            ?? (try? container.decode([Sub2APIModelUsage].self, forKey: .models))
            ?? []
        modelUsage = rawModels.map { model in
            ModelUsage(
                id: model.model,
                requests: model.requests,
                inputTokens: model.inputTokens,
                outputTokens: model.outputTokens,
                totalTokens: model.totalTokens,
                charge: model.actualCost,
                cacheReadTokens: model.cacheReadTokens,
                cacheWriteTokens: model.cacheCreationTokens
            )
        }
    }
}

struct Sub2APIModelUsage: Decodable {
    let model: String
    let requests: Int
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let totalTokens: Int
    let cost: Double
    let actualCost: Double

    private enum CodingKeys: String, CodingKey {
        case model
        case modelName = "model_name"
        case modelNameCamel = "modelName"
        case modelID = "model_id"
        case name
        case version
        case requests
        case requestCount = "request_count"
        case inputTokens = "input_tokens"
        case inputTokensCamel = "inputTokens"
        case outputTokens = "output_tokens"
        case outputTokensCamel = "outputTokens"
        case cacheCreationTokens = "cache_creation_tokens"
        case cacheCreationTokensCamel = "cacheCreationTokens"
        case cacheReadTokens = "cache_read_tokens"
        case cacheReadTokensCamel = "cacheReadTokens"
        case totalTokens = "total_tokens"
        case totalTokensCamel = "totalTokens"
        case charge
        case cost
        case actualCost = "actual_cost"
        case actualCostCamel = "actualCost"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var resolvedModel = container.decodeString(for: [.model, .modelName, .modelNameCamel, .modelID, .name]) ?? "未知模型"
        if let version = try container.decodeIfPresent(String.self, forKey: .version),
           !version.isEmpty,
           !resolvedModel.localizedCaseInsensitiveContains(version) {
            resolvedModel += "-\(version)"
        }
        model = resolvedModel
        requests = container.decodeInt(for: [.requests, .requestCount])
        inputTokens = container.decodeInt(for: [.inputTokens, .inputTokensCamel])
        outputTokens = container.decodeInt(for: [.outputTokens, .outputTokensCamel])
        cacheCreationTokens = container.decodeInt(for: [.cacheCreationTokens, .cacheCreationTokensCamel])
        cacheReadTokens = container.decodeInt(for: [.cacheReadTokens, .cacheReadTokensCamel])
        totalTokens = max(container.decodeInt(for: [.totalTokens, .totalTokensCamel]), inputTokens + outputTokens)
        cost = container.decodeDouble(for: [.cost, .charge])
        actualCost = container.decodeDouble(for: [.actualCost, .actualCostCamel, .charge, .cost])
    }
}

struct Sub2APIModelsResponse: Decodable {
    let models: [Sub2APIModelUsage]

    private enum CodingKeys: String, CodingKey {
        case models
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let models = try? container.decode([Sub2APIModelUsage].self, forKey: .models) {
            self.models = models
            return
        }
        if let models = try? container.decode([Sub2APIModelUsage].self, forKey: .data) {
            self.models = models
            return
        }
        if let nested = try? container.decode(Sub2APIModelsResponse.self, forKey: .data) {
            self.models = nested.models
            return
        }
        self.models = []
    }
}

struct Sub2APIAccountResponse: Decodable {
    let balance: Double
    let success: Bool?
    let message: String
    let hasBalance: Bool

    private enum CodingKeys: String, CodingKey {
        case balance
        case accountBalance = "account_balance"
        case data
        case success
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let outerSuccess = try? container.decode(Bool.self, forKey: .success)
        let outerMessage = (try? container.decode(String.self, forKey: .message)) ?? ""
        if container.contains(.balance) || container.contains(.accountBalance) {
            balance = container.decodeDouble(for: [.balance, .accountBalance])
            success = outerSuccess
            message = outerMessage
            hasBalance = true
            return
        }
        if let nested = try? container.decode(Sub2APIAccountResponse.self, forKey: .data) {
            balance = nested.balance
            success = outerSuccess ?? nested.success
            message = outerMessage.isEmpty ? nested.message : outerMessage
            hasBalance = nested.hasBalance
            return
        }
        balance = 0
        success = outerSuccess
        message = outerMessage
        hasBalance = false
    }
}

struct NewAPIAccountResponse: Decodable {
    let success: Bool
    let message: String
    let quota: Double
    let usedQuota: Double
    let hasQuotaData: Bool

    private enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
        case quota
        case usedQuota = "used_quota"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let directQuotaData = container.contains(.quota) || container.contains(.usedQuota)
        let decodedSuccess = try? container.decode(Bool.self, forKey: .success)
        message = (try? container.decode(String.self, forKey: .message)) ?? ""
        if let data = try? container.decode(NewAPIAccountData.self, forKey: .data) {
            quota = data.quota
            usedQuota = data.usedQuota
            hasQuotaData = true
        } else {
            quota = container.decodeDouble(for: [.quota])
            usedQuota = container.decodeDouble(for: [.usedQuota])
            hasQuotaData = directQuotaData
        }
        success = decodedSuccess ?? hasQuotaData
    }
}

private struct NewAPIAccountData: Decodable {
    let quota: Double
    let usedQuota: Double

    private enum CodingKeys: String, CodingKey {
        case quota
        case usedQuota = "used_quota"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quota = container.decodeDouble(for: [.quota])
        usedQuota = container.decodeDouble(for: [.usedQuota])
    }
}

struct NewAPILog: Decodable {
    let modelName: String
    let promptTokens: Int
    let completionTokens: Int
    let quota: Double
    let useTime: Double
    let createdAt: TimeInterval
    let other: String

    private enum CodingKeys: String, CodingKey {
        case modelName = "model_name"
        case model
        case modelNameCamel = "modelName"
        case modelID = "model_id"
        case name
        case version
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case quota
        case useTime = "use_time"
        case createdAt = "created_at"
        case other
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var resolvedModel = container.decodeString(for: [.modelName, .modelNameCamel, .model, .modelID, .name]) ?? "未知模型"
        if let version = try container.decodeIfPresent(String.self, forKey: .version),
           !version.isEmpty,
           !resolvedModel.localizedCaseInsensitiveContains(version) {
            resolvedModel += "-\(version)"
        }
        modelName = resolvedModel
        promptTokens = container.decodeInt(for: [.promptTokens])
        completionTokens = container.decodeInt(for: [.completionTokens])
        quota = container.decodeDouble(for: [.quota])
        useTime = container.decodeDouble(for: [.useTime])
        createdAt = container.decodeDouble(for: [.createdAt])
        // NewAPI versions have returned both a string and a JSON object here.
        // This field is not used for aggregation, so an unsupported shape must
        // not invalidate the complete page of usage logs.
        other = (try? container.decode(String.self, forKey: .other)) ?? ""
    }

    var totalTokens: Int { promptTokens + completionTokens }
}

struct NewAPILogPage: Decodable {
    let items: [NewAPILog]
    let total: Int

    private enum CodingKeys: String, CodingKey {
        case items
        case total
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([NewAPILog].self, forKey: .items) ?? []
        total = container.decodeInt(for: [.total])
    }
}

struct NewAPILogsResponse: Decodable {
    let success: Bool
    let message: String
    let data: NewAPILogPage?
}

struct NewAPIStat: Decodable {
    let quota: Double
    let rpm: Double
    let tpm: Double

    private enum CodingKeys: String, CodingKey {
        case quota
        case rpm
        case tpm
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quota = container.decodeDouble(for: [.quota])
        rpm = container.decodeDouble(for: [.rpm])
        tpm = container.decodeDouble(for: [.tpm])
    }
}

struct NewAPIStatResponse: Decodable {
    let success: Bool
    let message: String
    let data: NewAPIStat?
}

struct UsageSnapshot: Equatable {
    let providerName: String
    let today: UsageBucket
    let dailyUsage: [DailyUsage]
    let averageDurationMs: Double
    let rpm: Double
    let tpm: Double
    let billingMode: BillingMode
    let modelUsage: [ModelUsage]
    let official: OfficialCodexUsage?
    let accountBalance: AccountBalance?
    let fetchedAt: Date
}

enum BillingMode: Equatable {
    case currency
    case quota
}

struct ModelDescriptor: Equatable {
    let provider: String
    let name: String
    let version: String?
    let rawID: String

    init(rawID: String) {
        let trimmed = rawID.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = trimmed.lowercased()
        self.rawID = trimmed.isEmpty ? "未知模型" : trimmed

        if lowercased.contains("claude") {
            provider = "Anthropic"
            if lowercased.contains("sonnet") {
                name = "Sonnet"
            } else if lowercased.contains("opus") {
                name = "Opus"
            } else if lowercased.contains("haiku") {
                name = "Haiku"
            } else {
                name = "Claude"
            }
            version = Self.firstCapture(#"claude[-_ ]?([0-9]+(?:[-.][0-9]+)*)"#, in: trimmed)
                ?? Self.firstCapture(#"(?:sonnet|opus|haiku)[-_ ]?([0-9]+(?:\.[0-9]+)*)"#, in: trimmed)
        } else if lowercased.contains("gpt") || lowercased.contains("codex") || lowercased.hasPrefix("o1") || lowercased.hasPrefix("o3") || lowercased.hasPrefix("o4") {
            provider = "OpenAI"
            name = lowercased.contains("codex") ? "Codex" : (lowercased.hasPrefix("o") ? "o-series" : "GPT")
            version = Self.firstCapture(#"(?:gpt|codex)[-_ ]?([0-9]+(?:\.[0-9]+)*)"#, in: trimmed)
                ?? Self.firstCapture(#"(o[0-9]+(?:\.[0-9]+)*)"#, in: trimmed)
        } else if lowercased.contains("gemini") {
            provider = "Google"
            name = "Gemini"
            version = Self.firstCapture(#"gemini[-_ ]?([0-9]+(?:\.[0-9]+)*)"#, in: trimmed)
        } else if lowercased.contains("deepseek") {
            provider = "DeepSeek"
            name = "DeepSeek"
            version = Self.firstCapture(#"deepseek[-_ ]?(?:chat[-_ ]?)?[v]?([0-9]+(?:\.[0-9]+)*)"#, in: trimmed)
        } else if lowercased.contains("grok") {
            provider = "xAI"
            name = "Grok"
            version = Self.firstCapture(#"grok[-_ ]?[v]?([0-9]+(?:\.[0-9]+)*)"#, in: trimmed)
        } else if lowercased.contains("qwen") {
            provider = "Alibaba"
            name = "Qwen"
            version = Self.firstCapture(#"qwen[-_ ]?[v]?([0-9]+(?:\.[0-9]+)*)"#, in: trimmed)
        } else if lowercased.contains("llama") {
            provider = "Meta"
            name = "Llama"
            version = Self.firstCapture(#"llama[-_ ]?[v]?([0-9]+(?:\.[0-9]+)*)"#, in: trimmed)
        } else {
            provider = "其他"
            name = trimmed.isEmpty ? "未知模型" : trimmed
            version = nil
        }
    }

    private static func firstCapture(_ pattern: String, in value: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        guard let match = regex.firstMatch(in: value, options: [], range: range), match.numberOfRanges > 1,
              let captureRange = Range(match.range(at: 1), in: value) else { return nil }
        return String(value[captureRange]).replacingOccurrences(of: "-", with: ".")
    }
}

struct ModelUsage: Equatable, Identifiable {
    let id: String
    let requests: Int
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int
    let charge: Double
    let cacheReadTokens: Int
    let cacheWriteTokens: Int

    init(
        id: String,
        requests: Int,
        inputTokens: Int,
        outputTokens: Int,
        totalTokens: Int,
        charge: Double,
        cacheReadTokens: Int = 0,
        cacheWriteTokens: Int = 0
    ) {
        self.id = id
        self.requests = requests
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.totalTokens = max(totalTokens, inputTokens + outputTokens)
        self.charge = charge
        self.cacheReadTokens = cacheReadTokens
        self.cacheWriteTokens = cacheWriteTokens
    }

    var descriptor: ModelDescriptor { ModelDescriptor(rawID: id) }
}

struct OfficialRateLimitWindow: Equatable, Identifiable {
    let id: String
    let usedPercent: Double
    let durationMinutes: Int?
    let resetsAt: Date?

    var label: String {
        guard let durationMinutes else { return "使用窗口" }
        switch durationMinutes {
        case 285...315: return "5 小时"
        case 1_368...1_512: return "每日"
        case 9_576...10_584: return "每周"
        case 41_040...45_360: return "30 日"
        default: return "使用窗口"
        }
    }
}

struct OfficialDailyTokenBucket: Equatable, Identifiable {
    let date: String
    let tokens: Int

    var id: String { date }
}

struct OfficialCodexUsage: Equatable {
    let planType: String?
    let primary: OfficialRateLimitWindow?
    let secondary: OfficialRateLimitWindow?
    let lifetimeTokens: Int?
    let peakDailyTokens: Int?
    let currentStreakDays: Int?
    let dailyBuckets: [OfficialDailyTokenBucket]
    let creditsBalance: String?
    let creditsUnlimited: Bool
}

enum UsageServiceError: LocalizedError, Equatable {
    case invalidConfiguration(String)
    case invalidResponse
    case httpStatus(Int, String)
    case decoding(String)
    case keychain(OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return message
        case .invalidResponse:
            return "服务返回了无法识别的数据"
        case .httpStatus(let status, let message):
            let lowercasedMessage = message.lowercased()
            if lowercasedMessage.contains("chatgpt authentication") || lowercasedMessage.contains("official codex") {
                return "官方 Codex 未登录 ChatGPT，请先在 Codex 中完成登录"
            }
            if status == 401 {
                return message.isEmpty ? "API Key 无效或已过期" : message
            }
            if status == 403 {
                return message.isEmpty ? "API Key 没有读取用量的权限" : message
            }
            return message.isEmpty ? "服务请求失败（HTTP \(status)）" : message
        case .decoding(let message):
            return "用量数据格式不兼容：\(message)"
        case .keychain:
            return "无法读取或保存 API Key，请检查钥匙串权限"
        }
    }
}

private extension KeyedDecodingContainer {
    func decodeString(for keys: [K]) -> String? {
        for key in keys {
            if let value = try? decode(String.self, forKey: key), !value.isEmpty {
                return value
            }
        }
        return nil
    }

    func decodeInt(for keys: [K]) -> Int {
        for key in keys {
            if let value = try? decode(Int.self, forKey: key) {
                return value
            }
            if let value = try? decode(Double.self, forKey: key) {
                return Int(value)
            }
            if let value = try? decode(String.self, forKey: key), let number = Double(value) {
                return Int(number)
            }
        }
        return 0
    }

    func decodeDouble(for keys: [K]) -> Double {
        for key in keys {
            if let value = try? decode(Double.self, forKey: key) {
                return value
            }
            if let value = try? decode(Int.self, forKey: key) {
                return Double(value)
            }
            if let value = try? decode(String.self, forKey: key), let number = Double(value) {
                return number
            }
        }
        return 0
    }
}
