import XCTest
@testable import CodexUsageMenuBar

final class UsageModelsTests: XCTestCase {
    func testDecodesSub2APIUsagePayload() throws {
        let data = #"""
        {
          "usage": {
            "today": {
              "requests": 12,
              "input_tokens": "1200",
              "output_tokens": 800,
              "cache_read_tokens": 100,
              "total_tokens": 2100,
              "actual_cost": 0.42
            },
            "total": {}
          },
          "daily_usage": [
            {"date":"2026-07-18","requests":12,"input_tokens":1200,"output_tokens":800,"total_tokens":2100,"actual_cost":0.42}
          ]
        }
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(Sub2APIUsageResponse.self, from: data)

        XCTAssertEqual(response.usage.today.requests, 12)
        XCTAssertEqual(response.usage.today.inputTokens, 1200)
        XCTAssertEqual(response.usage.today.totalTokens, 2100)
        XCTAssertEqual(response.usage.today.actualCost, 0.42, accuracy: 0.0001)
        XCTAssertEqual(response.dailyUsage.count, 1)
        XCTAssertTrue(response.hasUsagePayload)
    }

    func testConfigurationNormalizesTrailingSlashAndRejectsEmptyKey() throws {
        let configuration = try ProviderConfiguration(
              baseURL: "http://localhost:8080/",
            apiKey: " sk-test "
        )
        XCTAssertEqual(configuration.usageURL.absoluteString, "http://localhost:8080/v1/usage")

        XCTAssertThrowsError(try ProviderConfiguration(baseURL: "http://localhost:8080", apiKey: ""))
        XCTAssertNoThrow(try ProviderConfiguration(
            baseURL: "http://localhost:8080",
            apiKey: "",
            requireAPIKey: false
        ))
    }

    func testNewAPIConfigurationAndLogResponse() throws {
        let configuration = try ProviderConfiguration(
            provider: .newAPI,
            baseURL: "https://newapi.example.com/",
            apiKey: "access-token",
            newAPIUserID: "42"
        )
        XCTAssertEqual(configuration.newAPILogsURL.absoluteString, "https://newapi.example.com/api/log/self")

        let data = #"{"success":true,"message":"","data":{"total":1,"items":[{"model_name":"gpt-5","prompt_tokens":10,"completion_tokens":"20","quota":3.5,"use_time":420,"created_at":1784376000,"other":{"trace":"ignored"}}]}}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(NewAPILogsResponse.self, from: data)
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data?.items.first?.totalTokens, 30)
        XCTAssertEqual(response.data?.items.first?.modelName, "gpt-5")
    }

    func testNewAPIConfigurationAcceptsConsoleAPIPaths() throws {
        let inputs = [
            "https://newapi.example.com/api",
            "https://newapi.example.com/api/",
            "https://newapi.example.com/api/v1",
            "https://newapi.example.com/api/v1/"
        ]

        for input in inputs {
            let configuration = try ProviderConfiguration(
                provider: .newAPI,
                baseURL: input,
                apiKey: "access-token",
                newAPIUserID: "42"
            )
            XCTAssertEqual(configuration.newAPILogsURL.absoluteString, "https://newapi.example.com/api/log/self")
        }
    }

    func testOfficialConfigurationDoesNotRequireKeyOrURL() throws {
        let configuration = try ProviderConfiguration(provider: .officialCodex)
        XCTAssertNil(configuration.baseURL)
        XCTAssertEqual(configuration.apiKey, "")
    }

    func testSub2APIDashboardModelResponse() throws {
        let data = #"{"code":0,"message":"","data":{"models":[{"model":"gpt-5.2-codex","requests":3,"input_tokens":10,"output_tokens":20,"cache_creation_tokens":4,"cache_read_tokens":6,"total_tokens":30,"cost":0.18,"actual_cost":0.12}]}}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(Sub2APIModelsResponse.self, from: data)
        XCTAssertEqual(response.models.first?.model, "gpt-5.2-codex")
        XCTAssertEqual(response.models.first?.totalTokens, 30)
        XCTAssertEqual(response.models.first?.cacheReadTokens, 6)
        XCTAssertEqual(response.models.first?.actualCost, 0.12, accuracy: 0.0001)

        let usage = ModelUsage(
            id: response.models[0].model,
            requests: response.models[0].requests,
            inputTokens: response.models[0].inputTokens,
            outputTokens: response.models[0].outputTokens,
            totalTokens: response.models[0].totalTokens,
            charge: response.models[0].actualCost
        )
        XCTAssertEqual(usage.descriptor.provider, "OpenAI")
        XCTAssertEqual(usage.descriptor.name, "Codex")
        XCTAssertEqual(usage.descriptor.version, "5.2")
    }

    func testTodayModelSelectionRejectsCumulativeFallback() {
        let today = UsageBucket(
            requests: 3,
            inputTokens: 700,
            outputTokens: 300,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            totalTokens: 1_000,
            actualCost: 1,
            standardCost: 1
        )
        let cumulative = ModelUsage(
            id: "gpt-5",
            requests: 40,
            inputTokens: 7_000,
            outputTokens: 3_000,
            totalTokens: 10_000,
            charge: 10
        )
        let daily = ModelUsage(
            id: "claude-sonnet-4",
            requests: 2,
            inputTokens: 600,
            outputTokens: 200,
            totalTokens: 800,
            charge: 0.8
        )

        let result = selectTodayModelUsage(
            primary: [cumulative],
            fallback: [daily],
            today: today
        )

        XCTAssertEqual(result, [daily])
    }

    func testTodayModelSelectionHidesUnverifiedCumulativeData() {
        let today = UsageBucket(
            requests: 0,
            inputTokens: 0,
            outputTokens: 0,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            totalTokens: 0,
            actualCost: 0,
            standardCost: 0
        )
        let cumulative = ModelUsage(
            id: "gpt-5",
            requests: 20,
            inputTokens: 2_000,
            outputTokens: 500,
            totalTokens: 2_500,
            charge: 2
        )

        XCTAssertTrue(selectTodayModelUsage(primary: [cumulative], fallback: nil, today: today).isEmpty)
    }

    func testModelDescriptorSupportsCommonProviderVersions() {
        let cases: [(String, String, String, String?)] = [
            ("claude-sonnet-4", "Anthropic", "Sonnet", "4"),
            ("gemini-2.5-pro", "Google", "Gemini", "2.5"),
            ("deepseek-v3", "DeepSeek", "DeepSeek", "3")
        ]

        for (rawID, provider, name, version) in cases {
            let descriptor = ModelDescriptor(rawID: rawID)
            XCTAssertEqual(descriptor.provider, provider)
            XCTAssertEqual(descriptor.name, name)
            XCTAssertEqual(descriptor.version, version)
        }
    }
}
