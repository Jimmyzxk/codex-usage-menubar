import Foundation

enum PreviewData {
    static let proxy = UsageSnapshot(
        providerName: "Sub2API",
        today: UsageBucket(
            requests: 1_328,
            inputTokens: 11_420_000,
            outputTokens: 2_128_400,
            cacheCreationTokens: 0,
            cacheReadTokens: 11_345_360,
            totalTokens: 24_893_760,
            actualCost: 18.6842,
            standardCost: 27.9138
        ),
        dailyUsage: [
            DailyUsage(date: "2026-07-19", requests: 1_328, inputTokens: 11_420_000, outputTokens: 2_128_400, cacheReadTokens: 11_345_360, cacheWriteTokens: 0, totalTokens: 24_893_760, actualCost: 18.6842),
            DailyUsage(date: "2026-07-18", requests: 982, inputTokens: 8_614_000, outputTokens: 1_820_000, cacheReadTokens: 8_702_000, cacheWriteTokens: 0, totalTokens: 19_136_000, actualCost: 14.4210),
            DailyUsage(date: "2026-07-17", requests: 741, inputTokens: 6_210_000, outputTokens: 1_340_000, cacheReadTokens: 7_272_000, cacheWriteTokens: 0, totalTokens: 14_822_000, actualCost: 10.7840),
            DailyUsage(date: "2026-07-16", requests: 426, inputTokens: 3_620_000, outputTokens: 844_000, cacheReadTokens: 4_448_000, cacheWriteTokens: 0, totalTokens: 8_912_000, actualCost: 6.2570)
        ],
        averageDurationMs: 842,
        rpm: 18,
        tpm: 286_400,
        billingMode: .currency,
        modelUsage: [
            ModelUsage(id: "gpt-5.2-codex", requests: 612, inputTokens: 7_420_000, outputTokens: 1_240_000, totalTokens: 13_240_000, charge: 9.8421),
            ModelUsage(id: "claude-sonnet-4", requests: 302, inputTokens: 3_260_000, outputTokens: 642_000, totalTokens: 6_480_000, charge: 5.2160),
            ModelUsage(id: "gemini-2.5-pro", requests: 248, inputTokens: 2_410_000, outputTokens: 174_000, totalTokens: 3_540_000, charge: 2.4100),
            ModelUsage(id: "deepseek-v3", requests: 166, inputTokens: 1_120_000, outputTokens: 72_400, totalTokens: 1_633_760, charge: 1.2161)
        ],
        official: nil,
        accountBalance: AccountBalance(value: 126.40, rawValue: nil, label: "账户余额", unit: .currency),
        fetchedAt: Date()
    )

    static let official = UsageSnapshot(
        providerName: "官方 Codex",
        today: UsageBucket(
            requests: 0,
            inputTokens: 3_420_000,
            outputTokens: 812_000,
            cacheCreationTokens: 0,
            cacheReadTokens: 1_184_000,
            totalTokens: 5_416_000,
            actualCost: 0,
            standardCost: 0
        ),
        dailyUsage: [],
        averageDurationMs: 0,
        rpm: 0,
        tpm: 0,
        billingMode: .quota,
        modelUsage: [],
        official: OfficialCodexUsage(
            planType: "plus",
            primary: OfficialRateLimitWindow(id: "five-hours", usedPercent: 37, durationMinutes: 300, resetsAt: Date().addingTimeInterval(2.2 * 3600)),
            secondary: OfficialRateLimitWindow(id: "thirty-days", usedPercent: 68, durationMinutes: 43_200, resetsAt: Date().addingTimeInterval(12 * 24 * 3600)),
            lifetimeTokens: 482_764_330,
            peakDailyTokens: 32_841_200,
            currentStreakDays: 18,
            dailyBuckets: [
                OfficialDailyTokenBucket(date: "2026-07-19", tokens: 5_416_000),
                OfficialDailyTokenBucket(date: "2026-07-18", tokens: 8_120_000),
                OfficialDailyTokenBucket(date: "2026-07-17", tokens: 4_680_000),
                OfficialDailyTokenBucket(date: "2026-07-16", tokens: 6_240_000),
                OfficialDailyTokenBucket(date: "2026-07-15", tokens: 3_440_000),
                OfficialDailyTokenBucket(date: "2026-07-14", tokens: 7_820_000),
                OfficialDailyTokenBucket(date: "2026-07-13", tokens: 2_980_000)
            ],
            creditsBalance: "1,240",
            creditsUnlimited: false
        ),
        accountBalance: AccountBalance(value: nil, rawValue: "1,240", label: "可用 Credits", unit: .credits),
        fetchedAt: Date()
    )
}
