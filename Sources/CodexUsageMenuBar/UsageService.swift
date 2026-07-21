import Foundation
import Darwin

protocol UsageProvider {
    var displayName: String { get }
    func fetchUsage(configuration: ProviderConfiguration) async throws -> UsageSnapshot
    func fetchAccountBalance(configuration: ProviderConfiguration) async throws -> AccountBalance?
}

func selectTodayModelUsage(
    primary: [ModelUsage],
    fallback: [ModelUsage]?,
    today: UsageBucket
) -> [ModelUsage] {
    guard today.requests > 0 || today.totalTokens > 0 else { return [] }

    for candidate in [primary, fallback ?? []] {
        let activeModels = candidate
            .filter { $0.requests > 0 || $0.totalTokens > 0 || $0.charge > 0 }
            .sorted { $0.totalTokens > $1.totalTokens }
        guard !activeModels.isEmpty else { continue }

        // Both endpoints have existed in versions that ignored the requested
        // period. Reject obviously cumulative results before showing them as
        // today's model usage.
        let modelRequests = activeModels.reduce(0) { $0 + $1.requests }
        let modelTokens = activeModels.reduce(0) { $0 + $1.totalTokens }
        let requestsPlausible = today.requests == 0
            || Double(modelRequests) <= Double(today.requests) * 2.0 + 10
        let tokensPlausible = today.totalTokens == 0
            || Double(modelTokens) <= Double(today.totalTokens) * 1.5 + 1_000_000
        guard requestsPlausible, tokensPlausible else {
            continue
        }
        return activeModels
    }
    return []
}

final class Sub2APIUsageProvider: UsageProvider {
    let displayName = "Sub2API"

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            configuration.urlCache = nil
            configuration.httpCookieStorage = nil
            configuration.httpMaximumConnectionsPerHost = 1
            configuration.timeoutIntervalForRequest = 15
            configuration.timeoutIntervalForResource = 20
            configuration.waitsForConnectivity = false
            self.session = URLSession(configuration: configuration)
        }
        self.decoder = JSONDecoder()
    }

    func fetchUsage(configuration: ProviderConfiguration) async throws -> UsageSnapshot {
        var components = URLComponents(url: configuration.usageURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "period", value: "today"),
            URLQueryItem(name: "start_date", value: todayDateKey()),
            URLQueryItem(name: "days", value: "7"),
            URLQueryItem(name: "timezone", value: TimeZone.current.identifier)
        ]

        guard let url = components?.url else {
            throw UsageServiceError.invalidConfiguration("无法生成用量查询地址")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw UsageServiceError.invalidResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                throw decodeHTTPError(status: httpResponse.statusCode, data: data)
            }

            do {
                let payload = try decoder.decode(Sub2APIUsageResponse.self, from: data)
                guard payload.hasUsagePayload else {
                    throw UsageServiceError.invalidResponse
                }
                if payload.success == false || payload.code.map({ $0 != 0 }) == true {
                    throw UsageServiceError.httpStatus(
                        httpResponse.statusCode,
                        payload.message.isEmpty ? "Sub2API 返回了失败状态" : payload.message
                    )
                }
                let dashboardModelUsage = try? await fetchModelUsage(configuration: configuration)
                let modelUsage = selectTodayModelUsage(
                    primary: payload.modelUsage,
                    fallback: dashboardModelUsage,
                    today: payload.usage.today
                )
                let accountBalance = try? await fetchAccountBalance(configuration: configuration)
                return UsageSnapshot(
                    providerName: displayName,
                    today: payload.usage.today,
                    dailyUsage: payload.dailyUsage,
                    averageDurationMs: payload.usage.averageDurationMs,
                    rpm: payload.usage.rpm,
                    tpm: payload.usage.tpm,
                    billingMode: .currency,
                    modelUsage: modelUsage,
                    official: nil,
                    accountBalance: accountBalance ?? nil,
                    fetchedAt: Date()
                )
            } catch {
                throw UsageServiceError.decoding(error.localizedDescription)
            }
        } catch let error as UsageServiceError {
            throw error
        } catch {
            throw UsageServiceError.httpStatus(0, networkMessage(for: error))
        }
    }

    func fetchAccountBalance(configuration: ProviderConfiguration) async throws -> AccountBalance? {
        var request = URLRequest(url: configuration.sub2APICurrentUserURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw UsageServiceError.invalidResponse
        }
        let account = try decoder.decode(Sub2APIAccountResponse.self, from: data)
        guard account.success != false, account.hasBalance else {
            throw UsageServiceError.httpStatus(
                httpResponse.statusCode,
                account.message.isEmpty ? "Sub2API 账户余额接口没有返回余额" : account.message
            )
        }
        return AccountBalance(value: account.balance, rawValue: nil, label: "账户余额", unit: .currency)
    }

    private func fetchModelUsage(configuration: ProviderConfiguration) async throws -> [ModelUsage] {
        var components = URLComponents(url: configuration.sub2APIModelsURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "period", value: "today"),
            URLQueryItem(name: "start_date", value: todayDateKey()),
            URLQueryItem(name: "timezone", value: TimeZone.current.identifier)
        ]
        guard let url = components?.url else {
            throw UsageServiceError.invalidConfiguration("无法生成 Sub2API 模型查询地址")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw UsageServiceError.invalidResponse
        }
        let payload = try decoder.decode(Sub2APIModelsResponse.self, from: data)
        return payload.models.map { model in
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

    private func todayDateKey() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private func decodeHTTPError(status: Int, data: Data) -> UsageServiceError {
        struct ErrorPayload: Decodable {
            let message: String?
            let error: String?
            let code: String?
        }

        let payload = try? decoder.decode(ErrorPayload.self, from: data)
        let message = payload?.message ?? payload?.error ?? payload?.code ?? ""
        return .httpStatus(status, message)
    }

    private func networkMessage(for error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost:
                return "无法连接到 Sub2API 服务"
            case NSURLErrorTimedOut:
                return "Sub2API 请求超时"
            case NSURLErrorAppTransportSecurityRequiresSecureConnection:
                return "HTTP 地址被 macOS 安全策略拦截，请检查 App 配置"
            default:
                break
            }
        }
        return error.localizedDescription
    }
}

enum UsageProviderFactory {
    static func make(for provider: ProviderKind) -> UsageProvider {
        switch provider {
        case .sub2api:
            return Sub2APIUsageProvider()
        case .newAPI:
            return NewAPIUsageProvider()
        case .officialCodex:
            return OfficialCodexUsageProvider()
        }
    }
}

final class NewAPIUsageProvider: UsageProvider {
    let displayName = "NewAPI"

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            configuration.urlCache = nil
            configuration.httpCookieStorage = nil
            configuration.httpMaximumConnectionsPerHost = 2
            configuration.timeoutIntervalForRequest = 15
            configuration.timeoutIntervalForResource = 20
            configuration.waitsForConnectivity = false
            self.session = URLSession(configuration: configuration)
        }
        self.decoder = JSONDecoder()
    }

    func fetchUsage(configuration: ProviderConfiguration) async throws -> UsageSnapshot {
        guard configuration.provider == .newAPI,
              let baseURL = configuration.baseURL,
              let userID = Int(configuration.newAPIUserID) else {
            throw UsageServiceError.invalidConfiguration("NewAPI 配置不完整")
        }

        let now = Date()
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: now)
        // The dashboard renders seven calendar days including today.
        let rangeStart = calendar.date(byAdding: .day, value: -6, to: todayStart) ?? todayStart
        let startTimestamp = Int64(rangeStart.timeIntervalSince1970)
        let endTimestamp = Int64(now.timeIntervalSince1970)

        async let stats = fetchStats(
            baseURL: baseURL,
            apiKey: configuration.apiKey,
            userID: userID,
            startTimestamp: Int64(todayStart.timeIntervalSince1970),
            endTimestamp: endTimestamp
        )
        async let recentLogs = fetchLogs(
            baseURL: baseURL,
            apiKey: configuration.apiKey,
            userID: userID,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp
        )
        let logs = try await recentLogs
        let todayLogs = logs.items.filter { isInDay($0.createdAt, start: todayStart, calendar: calendar) }
        let todayStats = try await stats
        let accountBalance = try? await fetchAccountBalance(configuration: configuration)

        let todayTokens = todayLogs.reduce(0) { $0 + $1.totalTokens }
        let todayInput = todayLogs.reduce(0) { $0 + $1.promptTokens }
        let todayOutput = todayLogs.reduce(0) { $0 + $1.completionTokens }
        let averageDuration = todayLogs.isEmpty
            ? 0
            : todayLogs.reduce(0) { $0 + $1.useTime } / Double(todayLogs.count)

        let today = UsageBucket(
            requests: todayLogs.count,
            inputTokens: todayInput,
            outputTokens: todayOutput,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            totalTokens: todayTokens,
            actualCost: todayStats.quota,
            standardCost: todayStats.quota
        )

        let groupedDays = Dictionary(grouping: logs.items) {
            dateKey(for: $0.createdAt, calendar: calendar)
        }
        let dailyUsage = groupedDays.compactMap { key, items -> DailyUsage? in
            guard !key.isEmpty else { return nil }
            return DailyUsage(
                date: key,
                requests: items.count,
                inputTokens: items.reduce(0) { $0 + $1.promptTokens },
                outputTokens: items.reduce(0) { $0 + $1.completionTokens },
                cacheReadTokens: 0,
                cacheWriteTokens: 0,
                totalTokens: items.reduce(0) { $0 + $1.totalTokens },
                actualCost: items.reduce(0) { $0 + $1.quota }
            )
        }
        .sorted { $0.date > $1.date }

        let models = Dictionary(grouping: todayLogs, by: { $0.modelName })
            .map { model, items in
                ModelUsage(
                    id: model,
                    requests: items.count,
                    inputTokens: items.reduce(0) { $0 + $1.promptTokens },
                    outputTokens: items.reduce(0) { $0 + $1.completionTokens },
                    totalTokens: items.reduce(0) { $0 + $1.totalTokens },
                    charge: items.reduce(0) { $0 + $1.quota }
                )
            }
            .sorted { $0.totalTokens > $1.totalTokens }

        return UsageSnapshot(
            providerName: displayName,
            today: today,
            dailyUsage: dailyUsage,
            averageDurationMs: averageDuration,
            rpm: todayStats.rpm,
            tpm: todayStats.tpm,
            billingMode: .quota,
            modelUsage: models,
            official: nil,
            accountBalance: accountBalance ?? nil,
            fetchedAt: Date()
        )
    }

    func fetchAccountBalance(configuration: ProviderConfiguration) async throws -> AccountBalance? {
        guard let userID = Int(configuration.newAPIUserID) else {
            throw UsageServiceError.invalidConfiguration("NewAPI 配置不完整")
        }
        let (data, _) = try await performRequest(
            url: configuration.newAPISelfURL,
            apiKey: configuration.apiKey,
            userID: userID,
            stage: "账户余额"
        )
        let account: NewAPIAccountResponse
        do {
            account = try decoder.decode(NewAPIAccountResponse.self, from: data)
        } catch {
            throw UsageServiceError.decoding("NewAPI 账户余额接口数据格式不兼容：\(error.localizedDescription)")
        }
        guard account.success, account.hasQuotaData else {
            throw UsageServiceError.httpStatus(200, "NewAPI 账户余额接口：\(account.message)")
        }
        return AccountBalance(
            value: max(account.quota - account.usedQuota, 0),
            rawValue: nil,
            label: "剩余额度",
            unit: .quota
        )
    }

    private func fetchStats(
        baseURL: URL,
        apiKey: String,
        userID: Int,
        startTimestamp: Int64,
        endTimestamp: Int64
    ) async throws -> NewAPIStat {
        let url = try makeURL(
            baseURL: baseURL,
            path: "api/log/self/stat",
            queryItems: [
                URLQueryItem(name: "type", value: "2"),
                URLQueryItem(name: "start_timestamp", value: String(startTimestamp)),
                URLQueryItem(name: "end_timestamp", value: String(endTimestamp))
            ]
        )
        let (data, response) = try await performRequest(
            url: url,
            apiKey: apiKey,
            userID: userID,
            stage: "统计接口"
        )
        let payload: NewAPIStatResponse
        do {
            payload = try decoder.decode(NewAPIStatResponse.self, from: data)
        } catch {
            throw UsageServiceError.decoding("NewAPI 统计接口数据格式不兼容：\(error.localizedDescription)")
        }
        guard payload.success, let stat = payload.data else {
            throw UsageServiceError.httpStatus(200, "NewAPI 统计接口：\(payload.message)")
        }
        _ = response
        return stat
    }

    private func fetchLogs(
        baseURL: URL,
        apiKey: String,
        userID: Int,
        startTimestamp: Int64,
        endTimestamp: Int64
    ) async throws -> (items: [NewAPILog], total: Int) {
        var allLogs: [NewAPILog] = []
        var total = 0
        let pageSize = 100
        let maxPages = 500
        var page = 1

        while page <= maxPages {
            let url = try makeURL(
                baseURL: baseURL,
                path: "api/log/self",
                queryItems: [
                    URLQueryItem(name: "type", value: "2"),
                    URLQueryItem(name: "start_timestamp", value: String(startTimestamp)),
                    URLQueryItem(name: "end_timestamp", value: String(endTimestamp)),
                    URLQueryItem(name: "p", value: String(page)),
                    URLQueryItem(name: "page_size", value: String(pageSize))
                ]
            )
            let (data, _) = try await performRequest(
                url: url,
                apiKey: apiKey,
                userID: userID,
                stage: "日志接口"
            )
            let payload: NewAPILogsResponse
            do {
                payload = try decoder.decode(NewAPILogsResponse.self, from: data)
            } catch {
                throw UsageServiceError.decoding("NewAPI 日志接口数据格式不兼容：\(error.localizedDescription)")
            }
            guard payload.success, let pageData = payload.data else {
                throw UsageServiceError.httpStatus(200, "NewAPI 日志接口：\(payload.message)")
            }

            total = pageData.total
            allLogs.append(contentsOf: pageData.items)
            // Some NewAPI builds report total=0 while still returning rows.
            // Only use total as an early-stop condition when it is positive.
            if pageData.items.isEmpty || (total > 0 && allLogs.count >= total) || pageData.items.count < pageSize {
                break
            }
            page += 1
        }

        if page > maxPages {
            throw UsageServiceError.httpStatus(
                0,
                "NewAPI 日志数量超过安全读取上限（(maxPages * pageSize) 条），请缩小查询范围"
            )
        }
        return (allLogs, total)
    }

    private func performRequest(
        url: URL,
        apiKey: String,
        userID: Int,
        stage: String
    ) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(String(userID), forHTTPHeaderField: "New-Api-User")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw UsageServiceError.httpStatus(0, "NewAPI \(stage)（\(url.path)）：服务返回了无效响应")
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw UsageServiceError.httpStatus(
                    httpResponse.statusCode,
                    "NewAPI \(stage)（\(url.path)）：\(decodeHTTPMessage(data) ?? "请求失败")"
                )
            }
            return (data, httpResponse)
        } catch let error as UsageServiceError {
            throw error
        } catch {
            throw UsageServiceError.httpStatus(0, "NewAPI \(stage)（\(url.path)）：\(networkMessage(for: error))")
        }
    }

    private func makeURL(baseURL: URL, path: String, queryItems: [URLQueryItem]) throws -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw UsageServiceError.invalidConfiguration("无法生成 NewAPI 查询地址")
        }
        return url
    }

    private func decodeHTTPMessage(_ data: Data) -> String? {
        struct ErrorPayload: Decodable {
            let message: String?
            let error: String?
            let code: String?
        }

        guard let payload = try? decoder.decode(ErrorPayload.self, from: data) else {
            let body = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return body?.isEmpty == false ? body : nil
        }
        let message = payload.message ?? payload.error ?? payload.code
        return message?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? message : nil
    }

    private func dateKey(for timestamp: TimeInterval, calendar: Calendar) -> String {
        let normalized = timestamp > 100_000_000_000 ? timestamp / 1_000 : timestamp
        let components = calendar.dateComponents([.year, .month, .day], from: Date(timeIntervalSince1970: normalized))
        guard let year = components.year, let month = components.month, let day = components.day else { return "" }
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    private func isInDay(_ timestamp: TimeInterval, start: Date, calendar: Calendar) -> Bool {
        let normalized = timestamp > 100_000_000_000 ? timestamp / 1_000 : timestamp
        return calendar.isDate(Date(timeIntervalSince1970: normalized), inSameDayAs: start)
    }

    private func networkMessage(for error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost:
                return "无法连接到服务"
            case NSURLErrorTimedOut:
                return "请求超时"
            default:
                break
            }
        }
        return error.localizedDescription
    }
}

private final class ProcessTimeoutState {
    private let lock = NSLock()
    private var finished = false
    private var timedOut = false

    func markTimedOut() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard !finished else { return false }
        timedOut = true
        return true
    }

    func markFinished() {
        lock.lock()
        finished = true
        lock.unlock()
    }

    var didTimeOut: Bool {
        lock.lock()
        defer { lock.unlock() }
        return timedOut
    }
}

final class OfficialCodexUsageProvider: UsageProvider {
    let displayName = "官方 Codex"

    func fetchUsage(configuration: ProviderConfiguration) async throws -> UsageSnapshot {
        guard configuration.provider == .officialCodex else {
            throw UsageServiceError.invalidConfiguration("官方 Codex 配置不完整")
        }
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                do {
                    continuation.resume(returning: try Self.fetchSynchronously())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchAccountBalance(configuration: ProviderConfiguration) async throws -> AccountBalance? {
        guard configuration.provider == .officialCodex else { return nil }
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                do {
                    continuation.resume(returning: try Self.fetchSynchronously().accountBalance)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func fetchSynchronously() throws -> UsageSnapshot {
        let executable = try findCodexExecutable()
        let process = Process()
        let input = Pipe()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = ["app-server", "--stdio"]
        process.standardInput = input
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            throw UsageServiceError.httpStatus(0, "无法启动 Codex app-server：\(error.localizedDescription)")
        }
        let outputHandle = output.fileHandleForReading
        let timeoutState = ProcessTimeoutState()
        let timeoutWork = DispatchWorkItem {
            guard timeoutState.markTimedOut() else { return }
            if process.isRunning {
                process.terminate()
            }
            // Closing the pipe is what unblocks a synchronous read.
            outputHandle.closeFile()
        }
        DispatchQueue.global(qos: .utility).asyncAfter(
            deadline: .now() + 20,
            execute: timeoutWork
        )
        defer {
            timeoutState.markFinished()
            timeoutWork.cancel()
            input.fileHandleForWriting.closeFile()
            outputHandle.closeFile()
            Self.stop(process)
        }

        try write(["method": "initialize", "id": 1, "params": [
            "clientInfo": [
                "name": "codex_usage_menubar",
                "title": "Codex Usage Menu Bar",
                "version": "0.1.0"
            ]
        ]], to: input.fileHandleForWriting)
        try write(["method": "initialized"], to: input.fileHandleForWriting)
        try write(["method": "account/rateLimits/read", "id": 2], to: input.fileHandleForWriting)
        try write(["method": "account/usage/read", "id": 3], to: input.fileHandleForWriting)

        var responses: [Int: [String: Any]] = [:]
        var pending = Data()
        while responses[2] == nil || responses[3] == nil {
            do {
                guard let chunk = try outputHandle.read(upToCount: 4_096), !chunk.isEmpty else {
                    break
                }
                pending.append(chunk)
            } catch {
                if timeoutState.didTimeOut {
                    throw UsageServiceError.httpStatus(0, "官方 Codex 请求超时")
                }
                throw error
            }
            while let newline = pending.firstIndex(of: 10) {
                let line = pending.prefix(upTo: newline)
                pending.removeSubrange(...newline)
                guard let object = try JSONSerialization.jsonObject(with: Data(line)) as? [String: Any],
                      let id = (object["id"] as? NSNumber)?.intValue else {
                    continue
                }
                responses[id] = object
            }
        }

        if timeoutState.didTimeOut {
            throw UsageServiceError.httpStatus(0, "官方 Codex 请求超时")
        }

        if let error = rpcError(in: responses[1]) {
            throw UsageServiceError.httpStatus(401, error)
        }
        if let error = rpcError(in: responses[2]) ?? rpcError(in: responses[3]) {
            throw UsageServiceError.httpStatus(401, error)
        }
        guard let rateResult = responses[2]?["result"] as? [String: Any],
              let usageResult = responses[3]?["result"] as? [String: Any] else {
            throw UsageServiceError.invalidResponse
        }
        return makeSnapshot(rateResult: rateResult, usageResult: usageResult)
    }

    private static func stop(_ process: Process) {
        if process.isRunning {
            process.terminate()
            let deadline = Date().addingTimeInterval(1)
            while process.isRunning && Date() < deadline {
                Thread.sleep(forTimeInterval: 0.01)
            }
            if process.isRunning {
                _ = kill(process.processIdentifier, SIGKILL)
            }
        }
        process.waitUntilExit()
    }

    private static func write(_ object: [String: Any], to handle: FileHandle) throws {
        let data = try JSONSerialization.data(withJSONObject: object)
        handle.write(data)
        handle.write(Data([10]))
    }

    private static func findCodexExecutable() throws -> String {
        let candidates = [
            ProcessInfo.processInfo.environment["CODEX_CLI_PATH"],
            "/Applications/ChatGPT.app/Contents/Resources/codex",
            "/opt/homebrew/bin/codex",
            "/usr/local/bin/codex"
        ].compactMap { $0 }
        if let path = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) {
            return path
        }
        throw UsageServiceError.invalidConfiguration("未找到 Codex，请先安装并登录官方 Codex")
    }

    private static func rpcError(in response: [String: Any]?) -> String? {
        guard let error = response?["error"] as? [String: Any] else { return nil }
        return error["message"] as? String ?? "Codex app-server 请求失败"
    }

    private static func makeSnapshot(rateResult: [String: Any], usageResult: [String: Any]) -> UsageSnapshot {
        let rateLimits = rateResult["rateLimits"] as? [String: Any] ?? rateResult
        let primary = makeWindow(id: "primary", from: rateLimits["primary"] as? [String: Any])
        let secondary = makeWindow(id: "secondary", from: rateLimits["secondary"] as? [String: Any])
        let summary = usageResult["summary"] as? [String: Any] ?? [:]
        let credits = rateLimits["credits"] as? [String: Any]
        let buckets = (usageResult["dailyUsageBuckets"] as? [[String: Any]] ?? []).compactMap { bucket -> OfficialDailyTokenBucket? in
            guard let date = bucket["startDate"] as? String else { return nil }
            return OfficialDailyTokenBucket(date: date, tokens: intValue(bucket["tokens"]))
        }.sorted { $0.date > $1.date }

        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let todayKey = String(format: "%04d-%02d-%02d", todayComponents.year ?? 0, todayComponents.month ?? 0, todayComponents.day ?? 0)
        let todayTokens = buckets.first(where: { $0.date.hasPrefix(todayKey) })?.tokens ?? 0
        let today = UsageBucket(
            requests: 0,
            inputTokens: 0,
            outputTokens: 0,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            totalTokens: todayTokens,
            actualCost: 0,
            standardCost: 0
        )
        let daily = buckets.map {
            DailyUsage(
                date: String($0.date.prefix(10)),
                requests: 0,
                inputTokens: 0,
                outputTokens: 0,
                cacheReadTokens: 0,
                cacheWriteTokens: 0,
                totalTokens: $0.tokens,
                actualCost: 0
            )
        }
        let creditsBalance = stringValue(credits?["balance"])
        let creditsUnlimited = credits?["unlimited"] as? Bool ?? false
        let accountBalance: AccountBalance? = if creditsUnlimited {
            AccountBalance(value: nil, rawValue: "无限", label: "Credits", unit: .credits)
        } else if let creditsBalance {
            AccountBalance(
                value: Double(creditsBalance),
                rawValue: creditsBalance,
                label: "Credits",
                unit: .credits
            )
        } else {
            nil
        }

        return UsageSnapshot(
            providerName: "官方 Codex",
            today: today,
            dailyUsage: daily,
            averageDurationMs: 0,
            rpm: 0,
            tpm: 0,
            billingMode: .currency,
            modelUsage: [],
            official: OfficialCodexUsage(
                planType: summaryString(rateLimits["planType"]),
                primary: primary,
                secondary: secondary,
                lifetimeTokens: optionalInt(summary["lifetimeTokens"]),
                peakDailyTokens: optionalInt(summary["peakDailyTokens"]),
                currentStreakDays: optionalInt(summary["currentStreakDays"]),
                dailyBuckets: buckets,
                creditsBalance: creditsBalance,
                creditsUnlimited: creditsUnlimited
            ),
            accountBalance: accountBalance,
            fetchedAt: Date()
        )
    }

    private static func makeWindow(id: String, from object: [String: Any]?) -> OfficialRateLimitWindow? {
        guard let object else { return nil }
        return OfficialRateLimitWindow(
            id: id,
            usedPercent: doubleValue(object["usedPercent"]),
            durationMinutes: optionalInt(object["windowDurationMins"]),
            resetsAt: dateValue(object["resetsAt"])
        )
    }

    private static func doubleValue(_ value: Any?) -> Double {
        if let number = value as? NSNumber { return number.doubleValue }
        if let string = value as? String, let number = Double(string) { return number }
        return 0
    }

    private static func intValue(_ value: Any?) -> Int {
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String, let number = Double(string) { return Int(number) }
        return 0
    }

    private static func optionalInt(_ value: Any?) -> Int? {
        guard value != nil else { return nil }
        return intValue(value)
    }

    private static func dateValue(_ value: Any?) -> Date? {
        if let number = value as? NSNumber {
            let timestamp = number.doubleValue
            return Date(timeIntervalSince1970: timestamp > 100_000_000_000 ? timestamp / 1_000 : timestamp)
        }
        if let string = value as? String {
            if let timestamp = Double(string) {
                return Date(timeIntervalSince1970: timestamp > 100_000_000_000 ? timestamp / 1_000 : timestamp)
            }
            return ISO8601DateFormatter().date(from: string)
        }
        return nil
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let string = value as? String, !string.isEmpty { return string }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
    }

    private static func summaryString(_ value: Any?) -> String? {
        guard let value = value as? String, !value.isEmpty else { return nil }
        return value
    }
}
