import SwiftUI
import AppKit

private struct UsageVisualStyle {
    let theme: DashboardTheme
    let accent: Color
    let positive: Color
    let secondaryAccent: Color
    let tertiaryAccent: Color
    let quaternaryAccent: Color
    let warning: Color
    let mutedSurface: Color
    let separator: Color
    let windowBackground: Color
    let headerSurface: Color
    let heroSurface: Color
    let outline: Color
    let shadow: Color
    let heroRadius: CGFloat

    var secondaryToken: Color { secondaryAccent }
    var tertiaryToken: Color { tertiaryAccent }

    init(theme: DashboardTheme, colorScheme: ColorScheme) {
        self.theme = theme
        warning = Color(red: 0.88, green: 0.11, blue: 0.27)
        separator = Color(nsColor: .separatorColor)

        switch (theme, colorScheme) {
        case (.clarity, .light):
            accent = Color(red: 0.18, green: 0.39, blue: 0.96)
            positive = Color(red: 0.09, green: 0.55, blue: 0.35)
            secondaryAccent = Color(red: 0.89, green: 0.41, blue: 0.35)
            tertiaryAccent = Color(red: 0.48, green: 0.39, blue: 0.85)
            quaternaryAccent = Color(red: 0.92, green: 0.64, blue: 0.22)
            windowBackground = Color(red: 0.985, green: 0.987, blue: 0.992)
            headerSurface = Color.white
            heroSurface = Color.white
            mutedSurface = Color.black.opacity(0.045)
            outline = Color.black.opacity(0.10)
            shadow = Color.black.opacity(0.07)
            heroRadius = 8
        case (.clarity, .dark):
            accent = Color(red: 0.43, green: 0.58, blue: 1.00)
            positive = Color(red: 0.26, green: 0.80, blue: 0.53)
            secondaryAccent = Color(red: 0.95, green: 0.49, blue: 0.43)
            tertiaryAccent = Color(red: 0.70, green: 0.62, blue: 1.00)
            quaternaryAccent = Color(red: 0.96, green: 0.75, blue: 0.38)
            windowBackground = Color(red: 0.055, green: 0.06, blue: 0.07)
            headerSurface = Color(red: 0.075, green: 0.08, blue: 0.09)
            heroSurface = Color(red: 0.105, green: 0.11, blue: 0.125)
            mutedSurface = Color.white.opacity(0.06)
            outline = Color.white.opacity(0.12)
            shadow = Color.black.opacity(0.24)
            heroRadius = 8
        case (.graphite, .light):
            accent = Color(red: 0.20, green: 0.34, blue: 0.82)
            positive = Color(red: 0.08, green: 0.62, blue: 0.43)
            secondaryAccent = Color(red: 0.90, green: 0.40, blue: 0.34)
            tertiaryAccent = Color(red: 0.52, green: 0.39, blue: 0.90)
            quaternaryAccent = Color(red: 0.92, green: 0.61, blue: 0.20)
            windowBackground = Color(red: 0.992, green: 0.99, blue: 0.988)
            headerSurface = Color.white
            heroSurface = Color.white
            mutedSurface = Color.black.opacity(0.035)
            outline = Color.black.opacity(0.10)
            shadow = Color.black.opacity(0.06)
            heroRadius = 10
        case (.graphite, .dark):
            accent = Color(red: 0.43, green: 0.55, blue: 1.00)
            positive = Color(red: 0.29, green: 0.84, blue: 0.63)
            secondaryAccent = Color(red: 0.96, green: 0.50, blue: 0.43)
            tertiaryAccent = Color(red: 0.72, green: 0.60, blue: 1.00)
            quaternaryAccent = Color(red: 0.97, green: 0.75, blue: 0.40)
            windowBackground = Color(red: 0.045, green: 0.05, blue: 0.06)
            headerSurface = Color(red: 0.065, green: 0.07, blue: 0.085)
            heroSurface = Color(red: 0.10, green: 0.105, blue: 0.125)
            mutedSurface = Color.white.opacity(0.06)
            outline = Color.white.opacity(0.12)
            shadow = Color.black.opacity(0.28)
            heroRadius = 10
        case (.pulse, .light):
            accent = Color(red: 0.38, green: 0.27, blue: 0.67)
            positive = Color(red: 0.04, green: 0.52, blue: 0.64)
            secondaryAccent = Color(red: 0.82, green: 0.31, blue: 0.50)
            tertiaryAccent = Color(red: 0.50, green: 0.38, blue: 0.78)
            quaternaryAccent = Color(red: 0.72, green: 0.55, blue: 0.08)
            windowBackground = Color(red: 1.0, green: 0.988, blue: 0.976)
            headerSurface = Color.white
            heroSurface = Color.white
            mutedSurface = Color(red: 0.95, green: 0.93, blue: 0.98)
            outline = Color(red: 0.25, green: 0.19, blue: 0.31).opacity(0.14)
            shadow = Color(red: 0.25, green: 0.19, blue: 0.31).opacity(0.10)
            heroRadius = 10
        case (.pulse, .dark):
            accent = Color(red: 0.61, green: 0.49, blue: 0.90)
            positive = Color(red: 0.28, green: 0.75, blue: 0.82)
            secondaryAccent = Color(red: 0.96, green: 0.43, blue: 0.62)
            tertiaryAccent = Color(red: 0.71, green: 0.61, blue: 0.94)
            quaternaryAccent = Color(red: 0.91, green: 0.77, blue: 0.28)
            windowBackground = Color(red: 0.075, green: 0.055, blue: 0.09)
            headerSurface = Color(red: 0.105, green: 0.078, blue: 0.13)
            heroSurface = Color(red: 0.14, green: 0.10, blue: 0.17)
            mutedSurface = Color(red: 0.20, green: 0.15, blue: 0.24)
            outline = Color.white.opacity(0.15)
            shadow = Color.black.opacity(0.32)
            heroRadius = 10
        default:
            accent = Color(red: 0.08, green: 0.39, blue: 0.91)
            positive = Color(red: 0.05, green: 0.62, blue: 0.43)
            secondaryAccent = Color(red: 0.04, green: 0.64, blue: 0.64)
            tertiaryAccent = Color(red: 0.47, green: 0.36, blue: 0.93)
            quaternaryAccent = Color(red: 0.17, green: 0.50, blue: 0.96)
            windowBackground = Color(red: 0.96, green: 0.97, blue: 0.98)
            headerSurface = Color(red: 0.99, green: 0.99, blue: 1.00)
            heroSurface = Color.white
            mutedSurface = Color.black.opacity(0.045)
            outline = Color.black.opacity(0.10)
            shadow = Color.black.opacity(0.07)
            heroRadius = 8
        }
    }
}

private struct UsageVisualStyleKey: EnvironmentKey {
    static let defaultValue = UsageVisualStyle(theme: .clarity, colorScheme: .light)
}

private enum PulseLayout {
    static let pageInset: CGFloat = 16
    static let sectionGap: CGFloat = 8
    static let panelRadius: CGFloat = 16
    static let rowRadius: CGFloat = 8
    static let dividerInset: CGFloat = 16
}

private extension EnvironmentValues {
    var usageVisualStyle: UsageVisualStyle {
        get { self[UsageVisualStyleKey.self] }
        set { self[UsageVisualStyleKey.self] = newValue }
    }
}

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    let onOpenSettings: () -> Void

    private var visualStyle: UsageVisualStyle {
        UsageVisualStyle(
            theme: appState.settings.dashboardTheme,
            colorScheme: resolvedColorScheme(theme: appState.settings.theme, system: colorScheme)
        )
    }

    private var sectionVerticalPadding: CGFloat {
        appState.settings.dashboardTheme == .graphite ? 12 : 15
    }

    private var modelRowSpacing: CGFloat {
        switch appState.settings.dashboardTheme {
        case .clarity: return 11
        case .graphite: return 9
        case .pulse: return 12
        }
    }

    private var historyRowSpacing: CGFloat {
        switch appState.settings.dashboardTheme {
        case .clarity: return 9
        case .graphite: return 7
        case .pulse: return 10
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView(.vertical, showsIndicators: false) {
                content
            }
            .frame(maxHeight: .infinity)
            Divider()
            footer
        }
        .frame(
            minWidth: CGFloat(appState.settings.panelSize.width),
            maxWidth: CGFloat(appState.settings.panelSize.width),
            minHeight: CGFloat(appState.settings.panelSize.height),
            maxHeight: CGFloat(appState.settings.panelSize.height)
        )
        .background(visualStyle.windowBackground)
        .preferredColorScheme(themeColorScheme(for: appState.settings.theme))
        .environment(\.usageVisualStyle, visualStyle)
    }

    private var header: some View {
        HStack(spacing: 10) {
            CodexMark(size: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text("CODEX USAGE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                ProfileSwitcher(onOpenSettings: onOpenSettings)
            }
            Spacer()
            IconButton(
                systemImage: appState.isLoading ? "arrow.triangle.2.circlepath" : "arrow.clockwise",
                help: "刷新用量",
                action: appState.refresh
            )
            IconButton(systemImage: "gearshape", help: "连接设置", action: onOpenSettings)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(visualStyle.headerSurface)
    }

    @ViewBuilder
    private var content: some View {
        if !appState.hasConfiguredAPIKey {
            StatePanel(
                mark: true,
                icon: nil,
                title: "连接你的用量来源",
                message: "选择 Sub2API、NewAPI 或官方 Codex，然后完成连接配置。",
                buttonTitle: "打开连接设置",
                action: onOpenSettings
            )
        } else if let snapshot = appState.snapshot {
            VStack(alignment: .leading, spacing: 0) {
                if let error = appState.lastError {
                    staleSyncBanner(error)
                    Divider()
                }
                if let official = snapshot.official {
                    officialContent(snapshot, usage: official)
                } else {
                    proxyContent(snapshot)
                }
            }
        } else if let error = appState.lastError {
            StatePanel(
                mark: false,
                icon: "exclamationmark.triangle",
                title: "连接异常",
                message: error,
                buttonTitle: "重试",
                action: appState.refresh
            )
        } else {
            StatePanel(
                mark: false,
                icon: "chart.bar.xaxis",
                title: "等待读取用量",
                message: "点击刷新开始查询。",
                buttonTitle: "刷新",
                action: appState.refresh
            )
        }
    }

    private func staleSyncBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(visualStyle.warning)
            VStack(alignment: .leading, spacing: 2) {
                Text("本次同步失败，以下数据可能是上一次结果")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
            Button {
                appState.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.borderless)
            .help("重试")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(visualStyle.warning.opacity(0.08))
    }

    private func displayTokenCount(_ value: Int) -> String {
        formatTokenCount(value, mode: appState.settings.tokenDisplayMode)
    }

    private func displayOptionalTokenCount(_ value: Int?) -> String {
        guard let value else { return "-" }
        return displayTokenCount(value)
    }

    @ViewBuilder
    private func proxyContent(_ snapshot: UsageSnapshot) -> some View {
        switch appState.settings.dashboardTheme {
        case .pulse:
            pulseContent(snapshot)
        default:
            VStack(alignment: .leading, spacing: 0) {
                proxyOverview(snapshot)
                if !snapshot.modelUsage.isEmpty {
                    Divider().padding(.horizontal, 18)
                    modelUsage(snapshot.modelUsage, billingMode: snapshot.billingMode)
                }
                if !snapshot.dailyUsage.isEmpty {
                    Divider().padding(.horizontal, 18)
                    history(snapshot.dailyUsage, billingMode: snapshot.billingMode)
                }
            }
            .padding(.bottom, 14)
        }
    }

    @ViewBuilder
    private func proxyOverview(_ snapshot: UsageSnapshot) -> some View {
        switch appState.settings.dashboardTheme {
        case .clarity:
            clarityHero(snapshot)
            Divider()
                .padding(.horizontal, 18)
                .padding(.top, 12)
            clarityDetails(snapshot)
        case .graphite:
            graphiteOverview(snapshot)
        case .pulse:
            pulseOverview(snapshot, dailyUsage: recentDailyUsage(snapshot.dailyUsage, limit: 7, ascending: true))
        }
    }

    private func clarityHero(_ snapshot: UsageSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Text("今日使用")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 8) {
                    Text(snapshot.billingMode == .quota ? "中转额度" : "API 消费")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    TokenDisplayControl(selection: appState.settings.tokenDisplayMode) { mode in
                        appState.setTokenDisplayMode(mode)
                    }
                }
            }
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text(displayTokenCount(snapshot.today.totalTokens))
                    .font(.system(size: 37, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                Text("tokens")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 12)
                VStack(alignment: .trailing, spacing: 3) {
                    if let balance = snapshot.accountBalance {
                        Text(formatAccountBalance(balance))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(visualStyle.positive)
                        Text(balance.label)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                        Text(formatBilling(snapshot.today.actualCost, mode: snapshot.billingMode))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                    Text(snapshot.billingMode == .quota ? "今日额度" : "实际消费")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            Rectangle()
                .fill(visualStyle.accent)
                .frame(height: 3)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(visualStyle.heroSurface)
        .clipShape(RoundedRectangle(cornerRadius: visualStyle.heroRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: visualStyle.heroRadius, style: .continuous)
                .stroke(visualStyle.outline, lineWidth: 1)
        }
        .shadow(color: visualStyle.shadow, radius: 8, y: 3)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private func clarityDetails(_ snapshot: UsageSnapshot) -> some View {
        let input = snapshot.today.inputTokens
        let output = snapshot.today.outputTokens
        let cache = snapshot.today.cacheReadTokens

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日明细")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(formatCount(snapshot.today.requests)) 次请求")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            TokenCompositionBar(input: input, output: output, cache: cache)
                .frame(height: 7)
            HStack(spacing: 0) {
                TokenBreakdownMetric(
                    title: "输入",
                    value: displayTokenCount(input),
                    fullValue: formatCount(input),
                    color: visualStyle.accent
                )
                TokenBreakdownMetric(
                    title: "输出",
                    value: displayTokenCount(output),
                    fullValue: formatCount(output),
                    color: visualStyle.secondaryToken
                )
                TokenBreakdownMetric(
                    title: "缓存读取",
                    value: displayTokenCount(cache),
                    fullValue: formatCount(cache),
                    color: visualStyle.tertiaryToken
                )
            }
            Divider()
            HStack(spacing: 0) {
                InlinePerformanceMetric(title: "RPM", value: formatRate(snapshot.rpm), color: visualStyle.accent)
                InlinePerformanceMetric(title: "TPM", value: formatRate(snapshot.tpm), color: visualStyle.accent)
                InlinePerformanceMetric(
                    title: "平均响应",
                    value: formatLatency(snapshot.averageDurationMs),
                    color: visualStyle.accent
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
    }

    private func graphiteOverview(_ snapshot: UsageSnapshot) -> some View {
        let input = snapshot.today.inputTokens
        let output = snapshot.today.outputTokens
        let cache = snapshot.today.cacheReadTokens
        let secondaryTitle = snapshot.accountBalance?.label ?? "今日消费"
        let secondaryValue = snapshot.accountBalance.map(formatAccountBalance)
            ?? formatBilling(snapshot.today.actualCost, mode: snapshot.billingMode)
        let secondaryCaption = snapshot.accountBalance == nil ? "实际消费" : "可用余额"

        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("今日使用")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                Spacer()
                TokenDisplayControl(selection: appState.settings.tokenDisplayMode) { mode in
                    appState.setTokenDisplayMode(mode)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 11)

            HStack(spacing: 10) {
                ColorMetricTile(
                    title: "Tokens",
                    value: displayTokenCount(snapshot.today.totalTokens),
                    caption: "今日总量",
                    systemImage: "chart.bar.fill",
                    color: visualStyle.accent
                )
                ColorMetricTile(
                    title: secondaryTitle,
                    value: secondaryValue,
                    caption: secondaryCaption,
                    systemImage: snapshot.accountBalance == nil ? "creditcard" : "wallet.pass.fill",
                    color: visualStyle.secondaryAccent
                )
            }
            .padding(.horizontal, 16)

            HStack(spacing: 0) {
                StackedMetric(title: "请求", value: formatCount(snapshot.today.requests), color: visualStyle.accent)
                StackedMetric(title: "RPM", value: formatRate(snapshot.rpm), color: visualStyle.accent)
                StackedMetric(title: "TPM", value: formatRate(snapshot.tpm), color: visualStyle.accent)
                StackedMetric(title: "平均响应", value: formatLatency(snapshot.averageDurationMs), color: visualStyle.accent)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 11)
            .background(visualStyle.mutedSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 11)

            Divider().padding(.top, 13)

            VStack(alignment: .leading, spacing: 11) {
                HStack {
                Text("Token 构成")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    Spacer()
                    Text("输入 · 输出 · 缓存")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                TokenCompositionBar(input: input, output: output, cache: cache)
                    .frame(height: 7)
                HStack(spacing: 0) {
                    TokenBreakdownMetric(title: "输入", value: displayTokenCount(input), fullValue: formatCount(input), color: visualStyle.accent)
                    TokenBreakdownMetric(title: "输出", value: displayTokenCount(output), fullValue: formatCount(output), color: visualStyle.secondaryToken)
                    TokenBreakdownMetric(title: "缓存读取", value: displayTokenCount(cache), fullValue: formatCount(cache), color: visualStyle.tertiaryToken)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .padding(.bottom, 14)
    }

    private func pulseContent(_ snapshot: UsageSnapshot) -> some View {
        let recentUsage = recentDailyUsage(snapshot.dailyUsage, limit: 7, ascending: true)

        return VStack(alignment: .leading, spacing: 0) {
            pulseOverview(snapshot, dailyUsage: recentUsage)
            if snapshot.modelUsage.isEmpty {
                pulseEmptyModels
            } else {
                pulseModelUsage(snapshot.modelUsage, billingMode: snapshot.billingMode)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    private func pulseOverview(_ snapshot: UsageSnapshot, dailyUsage: [DailyUsage]) -> some View {
        let input = snapshot.today.inputTokens
        let output = snapshot.today.outputTokens
        let cache = snapshot.today.cacheReadTokens

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(visualStyle.positive)
                            .frame(width: 6, height: 6)
                        Text("数据实验室")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    Text("今日使用 · \(snapshot.providerName)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                TokenDisplayControl(selection: appState.settings.tokenDisplayMode) { mode in
                    appState.setTokenDisplayMode(mode)
                }
            }
            .padding(.bottom, 12)

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("TOKENS")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .opacity(0.68)
                    Text(displayTokenCount(snapshot.today.totalTokens))
                        .font(.system(size: 34, weight: .black, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.52)
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.right")
                        Text("\(formatCount(snapshot.today.requests)) 次请求")
                    }
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .opacity(0.82)
                }
                .foregroundStyle(.white)
                .padding(14)
                .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .leading)
                .background(visualStyle.accent)

                VStack(alignment: .leading, spacing: 9) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Token 构成")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                        Spacer()
                        Text("今日总量")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    TokenCompositionBar(input: input, output: output, cache: cache, isOnAccent: true)
                        .frame(height: 7)
                    HStack(spacing: 0) {
                        PulseTokenReadout(title: "输入", value: displayTokenCount(input), color: visualStyle.positive, inverted: true)
                        PulseTokenReadout(title: "输出", value: displayTokenCount(output), color: visualStyle.secondaryAccent, inverted: true)
                        PulseTokenReadout(title: "缓存", value: displayTokenCount(cache), color: visualStyle.tertiaryAccent, inverted: true)
                    }
                }
                .padding(13)
                .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .leading)
                .foregroundStyle(.white)
                .background(visualStyle.accent)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(visualStyle.outline.opacity(0.28), lineWidth: 1)
            }
            .padding(.bottom, 8)

            HStack(spacing: 0) {
                PulseGridMetric(title: "请求", value: formatCount(snapshot.today.requests), color: visualStyle.positive)
                PulseGridMetric(title: "RPM", value: formatRate(snapshot.rpm), color: visualStyle.accent)
                PulseGridMetric(title: "TPM", value: formatRate(snapshot.tpm), color: visualStyle.tertiaryAccent)
                PulseGridMetric(title: "平均响应", value: formatLatency(snapshot.averageDurationMs), color: visualStyle.secondaryAccent)
            }
            .padding(.vertical, 8)
            .overlay(alignment: .top) { Divider() }
            .overlay(alignment: .bottom) { Divider() }

            HStack(alignment: .top, spacing: 10) {
                if !dailyUsage.isEmpty {
                    PulseActivityStrip(
                        items: dailyUsage,
                        maximum: max(dailyUsage.map(\.totalTokens).max() ?? 0, 1),
                        color: visualStyle.tertiaryAccent
                    )
                    .frame(maxWidth: .infinity)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("结算概览")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(snapshot.billingMode == .quota ? "今日额度" : "实际消费")
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(formatBilling(snapshot.today.actualCost, mode: snapshot.billingMode))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(visualStyle.secondaryAccent)
                    }
                    if let balance = snapshot.accountBalance {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(balance.label)
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text(formatAccountBalance(balance))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(visualStyle.quaternaryAccent)
                        }
                    }
                }
                .frame(width: 112, alignment: .leading)
                .padding(11)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(visualStyle.secondaryAccent)
                        .frame(width: 3)
                }
            }
            .padding(.top, 12)
        }
        .padding(.top, 14)
    }

    private var pulseEmptyModels: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(visualStyle.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("模型使用")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                    Text("今日暂无模型统计")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .top) { Divider() }
        .overlay(alignment: .bottom) { Divider() }
    }

    private func pulseModelUsage(_ models: [ModelUsage], billingMode: BillingMode) -> some View {
        let visibleModels = models

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("模型使用")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                Spacer()
                Text("今日请求 · Tokens · \(models.count) 个")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 9)

            VStack(spacing: 0) {
                ForEach(visibleModels) { model in
                    let descriptor = model.descriptor
                    HStack(spacing: 9) {
                        Circle()
                            .fill(modelColor(model.id))
                            .frame(width: 7, height: 7)
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 5) {
                                Text(descriptor.name)
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .lineLimit(1)
                                if let version = descriptor.version {
                                    Text("v\(version)")
                                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                                        .foregroundStyle(modelColor(model.id))
                                }
                            }
                            Text("\(descriptor.provider) · \(model.id)")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(displayTokenCount(model.totalTokens))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .help("\(formatCount(model.totalTokens)) tokens")
                            Text("\(formatCount(model.requests)) 次 · \(formatBilling(model.charge, mode: billingMode))")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 9)
                    if model.id != visibleModels.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
        .padding(.top, 12)
        .overlay(alignment: .top) { Divider() }
        .overlay(alignment: .bottom) { Divider() }
    }

    private func modelUsage(_ models: [ModelUsage], billingMode: BillingMode) -> some View {
        let visibleModels = models
        let maximum = max(visibleModels.map(\.totalTokens).max() ?? 0, 1)

        return VStack(alignment: .leading, spacing: 11) {
            HStack {
                Text("今日模型")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Spacer()
                Text("按 Tokens · \(models.count) 个")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: modelRowSpacing) {
                ForEach(visibleModels) { model in
                    let descriptor = model.descriptor
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 5) {
                                    Text(descriptor.provider.uppercased())
                                        .font(.system(size: 8, weight: .bold, design: .rounded))
                                        .foregroundStyle(modelColor(model.id))
                                    Text(descriptor.name)
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .lineLimit(1)
                                }
                                Text(model.id)
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.72)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            if let version = descriptor.version {
                                Text("v\(version)")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundStyle(modelColor(model.id))
                            }
                            Text(displayTokenCount(model.totalTokens))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .help("\(formatCount(model.totalTokens)) tokens")
                            Text(formatBilling(model.charge, mode: billingMode))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        SegmentBar(ratio: Double(model.totalTokens) / Double(maximum), color: modelColor(model.id))
                            .frame(height: 5)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, sectionVerticalPadding)
    }

    private func history(_ items: [DailyUsage], billingMode: BillingMode) -> some View {
        let visibleItems = Array(items.sorted { $0.date > $1.date }.prefix(4))
        let maximum = max(visibleItems.map(\.totalTokens).max() ?? 0, 1)

        return VStack(alignment: .leading, spacing: 11) {
            HStack {
                Text("最近 4 天")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Spacer()
                Text(billingMode == .quota ? "额度 / Tokens" : "消费 / Tokens")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: historyRowSpacing) {
                ForEach(visibleItems) { item in
                    HStack(spacing: 8) {
                        Text(displayDate(item.date))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 37, alignment: .leading)
                        SegmentBar(ratio: Double(item.totalTokens) / Double(maximum), color: visualStyle.accent)
                            .frame(maxWidth: .infinity, minHeight: 6, maxHeight: 6)
                        Text(displayTokenCount(item.totalTokens))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                            .frame(width: 68, alignment: .trailing)
                        Text(formatBilling(item.actualCost, mode: billingMode))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, sectionVerticalPadding)
        .padding(.top, 2)
    }

    private func modelColor(_ modelID: String) -> Color {
        let model = modelID.lowercased()
        if appState.settings.dashboardTheme == .pulse {
            if model.contains("claude") || model.contains("sonnet") || model.contains("opus") {
                return visualStyle.secondaryAccent
            }
            if model.contains("gemini") {
                return visualStyle.tertiaryAccent
            }
            if model.contains("deepseek") {
                return visualStyle.positive
            }
            if model.contains("grok") {
                return visualStyle.quaternaryAccent
            }
            return visualStyle.accent
        }
        if model.contains("claude") || model.contains("sonnet") || model.contains("opus") {
            return Color(red: 0.85, green: 0.47, blue: 0.34)
        }
        if model.contains("gemini") {
            return Color(red: 0.02, green: 0.71, blue: 0.83)
        }
        if model.contains("deepseek") {
            return Color(red: 0.30, green: 0.42, blue: 0.99)
        }
        if model.contains("grok") {
            return Color.primary.opacity(0.64)
        }
        return visualStyle.accent
    }

    private func quotaColor(_ index: Int) -> Color {
        index == 0 ? visualStyle.accent : visualStyle.secondaryAccent
    }

    @ViewBuilder
    private func officialContent(_ snapshot: UsageSnapshot, usage: OfficialCodexUsage) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            officialHero(snapshot, usage: usage)
            Divider()
                .padding(.horizontal, 18)
                .padding(.top, 12)
            officialWindows(usage)
            Divider().padding(.horizontal, 18)
            officialTokenSummary(usage)
            if !usage.dailyBuckets.isEmpty {
                Divider().padding(.horizontal, 18)
                officialDailyUsage(usage.dailyBuckets)
            }
        }
        .padding(.bottom, 14)
    }

    @ViewBuilder
    private func officialHero(_ snapshot: UsageSnapshot, usage: OfficialCodexUsage) -> some View {
        switch appState.settings.dashboardTheme {
        case .clarity:
            clarityOfficialHero(snapshot, usage: usage)
        case .graphite:
            graphiteOfficialHero(snapshot, usage: usage)
        case .pulse:
            pulseOfficialHero(snapshot, usage: usage)
        }
    }

    private func clarityOfficialHero(_ snapshot: UsageSnapshot, usage: OfficialCodexUsage) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Text("官方 Codex")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                TokenDisplayControl(selection: appState.settings.tokenDisplayMode) { mode in
                    appState.setTokenDisplayMode(mode)
                }
            }
            HStack(alignment: .bottom) {
                HStack(alignment: .lastTextBaseline, spacing: 7) {
                    Text(displayTokenCount(snapshot.today.totalTokens))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                    Text("今日 tokens")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 12)
                VStack(alignment: .trailing, spacing: 5) {
                    if let balance = snapshot.accountBalance {
                        Text(formatAccountBalance(balance))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(visualStyle.accent)
                        Text(balance.label)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    Text(planTitle(usage.planType))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Text("ChatGPT / Codex 登录态")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(visualStyle.heroSurface)
        .clipShape(RoundedRectangle(cornerRadius: visualStyle.heroRadius, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private func graphiteOfficialHero(_ snapshot: UsageSnapshot, usage: OfficialCodexUsage) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(visualStyle.accent)
                    .frame(width: 3, height: 14)
                Text("官方 Codex")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Spacer()
                Text(planTitle(usage.planType))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(visualStyle.accent)
                TokenDisplayControl(selection: appState.settings.tokenDisplayMode) { mode in
                    appState.setTokenDisplayMode(mode)
                }
            }
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text(displayTokenCount(snapshot.today.totalTokens))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                Text("今日 tokens")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 10)
                if let balance = snapshot.accountBalance {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatAccountBalance(balance))
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        Text(balance.label)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(visualStyle.heroSurface)
        .clipShape(RoundedRectangle(cornerRadius: visualStyle.heroRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: visualStyle.heroRadius, style: .continuous)
                .stroke(visualStyle.outline, lineWidth: 1)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private func pulseOfficialHero(_ snapshot: UsageSnapshot, usage: OfficialCodexUsage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 7) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(visualStyle.accent)
                Text("官方 Codex")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Spacer()
                Text(planTitle(usage.planType))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(visualStyle.accent)
                TokenDisplayControl(selection: appState.settings.tokenDisplayMode) { mode in
                    appState.setTokenDisplayMode(mode)
                }
            }
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text(displayTokenCount(snapshot.today.totalTokens))
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                Text("今日 tokens")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 10)
                if let balance = snapshot.accountBalance {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatAccountBalance(balance))
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(visualStyle.positive)
                        Text(balance.label)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Rectangle()
                .fill(visualStyle.accent)
                .frame(height: 3)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 16)
        .background(visualStyle.heroSurface)
        .clipShape(RoundedRectangle(cornerRadius: visualStyle.heroRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: visualStyle.heroRadius, style: .continuous)
                .stroke(visualStyle.outline, lineWidth: 1)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private func officialWindows(_ usage: OfficialCodexUsage) -> some View {
        let windows = [usage.primary, usage.secondary].compactMap { $0 }
        return VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text("配额窗口")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Spacer()
                Text("已用")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            if windows.isEmpty {
                Text("官方账户暂未返回配额窗口")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(windows.enumerated()), id: \.element.id) { index, window in
                    QuotaWindowCard(window: window, color: window.usedPercent >= 80 ? visualStyle.warning : quotaColor(index))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, sectionVerticalPadding)
    }

    private func officialTokenSummary(_ usage: OfficialCodexUsage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Token 概览")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
            HStack(spacing: 0) {
                OfficialMetric(title: "累计", value: displayOptionalTokenCount(usage.lifetimeTokens))
                MetricDivider()
                OfficialMetric(title: "单日峰值", value: displayOptionalTokenCount(usage.peakDailyTokens))
                MetricDivider()
                OfficialMetric(title: "连续使用", value: usage.currentStreakDays.map { "\($0) 天" } ?? "-")
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, sectionVerticalPadding)
    }

    private func officialDailyUsage(_ buckets: [OfficialDailyTokenBucket]) -> some View {
        let visible = Array(buckets.prefix(7))
        let maximum = max(visible.map(\.tokens).max() ?? 0, 1)
        return VStack(alignment: .leading, spacing: 11) {
            HStack {
                Text("每日 Tokens")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Spacer()
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: historyRowSpacing) {
                ForEach(visible) { bucket in
                    HStack(spacing: 8) {
                        Text(displayDate(String(bucket.date.prefix(10))))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 37, alignment: .leading)
                        SegmentBar(ratio: Double(bucket.tokens) / Double(maximum), color: visualStyle.accent)
                            .frame(maxWidth: .infinity, minHeight: 6, maxHeight: 6)
                        Text(displayTokenCount(bucket.tokens))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                            .frame(width: 66, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, sectionVerticalPadding)
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.system(size: 10))
            if appState.lastError != nil, appState.snapshot != nil {
                Text("同步失败，显示上次结果")
            } else if let snapshot = appState.snapshot {
                Text("已同步 " + snapshot.fetchedAt.formatted(date: .omitted, time: .shortened))
            } else if appState.isLoading {
                Text("正在读取")
            } else {
                Text("尚未同步")
            }
            Spacer()
            Text("每 " + String(Int(appState.settings.refreshInterval / 60)) + " 分钟")
        }
        .font(.system(size: 10))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(visualStyle.headerSurface)
    }
}

private struct ProfileSwitcher: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.usageVisualStyle) private var visualStyle
    let onOpenSettings: () -> Void

    var body: some View {
        Menu {
            ForEach(appState.settings.profiles) { profile in
                Button {
                    appState.selectProfile(profile.id)
                } label: {
                    if profile.id == appState.settings.selectedProfileID {
                        Label("\(profile.displayName) · \(profile.provider.title)", systemImage: "checkmark")
                    } else {
                        Text("\(profile.displayName) · \(profile.provider.title)")
                    }
                }
            }
            Divider()
            Button("管理供应商") { onOpenSettings() }
        } label: {
            HStack(spacing: 5) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                Text(appState.settings.selectedProfile.displayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .lineLimit(1)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .help("切换供应商")
    }

    private var statusColor: Color {
        if appState.isLoading { return visualStyle.accent }
        if appState.lastError != nil { return .red }
        if appState.snapshot != nil { return visualStyle.positive }
        return visualStyle.separator
    }
}

private enum SettingsScope {
    case connection
    case global
}

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let onCloseWindow: (() -> Void)?

    @State private var provider: ProviderKind = .sub2api
    @State private var profileID = ""
    @State private var profileName = ""
    @State private var baseURL = ""
    @State private var apiKey = ""
    @State private var revealAPIKey = false
    @State private var newAPIUserID = ""
    @State private var refreshInterval = 300.0
    @State private var theme: ThemeMode = .system
    @State private var dashboardTheme: DashboardTheme = .clarity
    @State private var panelSize: PanelSize = .standard
    @State private var tokenDisplayMode: TokenDisplayMode = .compact
    @State private var errorMessage: String?
    @State private var saved = false
    @State private var testMessage: String?
    @State private var testSucceeded = false
    @State private var isTestingConnection = false
    @State private var isDraftNew = false
    @State private var showDeleteConfirmation = false
    @State private var showDiscardConfirmation = false
    @State private var initialDraftFingerprint = ""
    @State private var pendingProfileID: String?
    @State private var pendingNewProfile = false
    @State private var pendingGlobalSettings = false
    @State private var settingsScope: SettingsScope = .connection

    init(onCloseWindow: (() -> Void)? = nil) {
        self.onCloseWindow = onCloseWindow
    }

    private var draftFingerprint: String {
        [
            profileName,
            provider.rawValue,
            baseURL,
            apiKey,
            newAPIUserID,
            String(refreshInterval),
            theme.rawValue,
            dashboardTheme.rawValue,
            panelSize.rawValue,
            tokenDisplayMode.rawValue
        ]
            .joined(separator: "|")
    }

    private var hasUnsavedChanges: Bool {
        isDraftNew || (!initialDraftFingerprint.isEmpty && draftFingerprint != initialDraftFingerprint)
    }

    private var visualStyle: UsageVisualStyle {
        UsageVisualStyle(
            theme: dashboardTheme,
            colorScheme: resolvedColorScheme(theme: theme, system: colorScheme)
        )
    }

    private var usesInsecureHTTP: Bool {
        URLComponents(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines))?
            .scheme?
            .lowercased() == "http"
    }

    var body: some View {
        VStack(spacing: 0) {
            settingsHeader
            Divider()
            HStack(spacing: 0) {
                profileSection
                    .frame(width: 224)

                Divider()

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 28) {
                            if settingsScope == .connection {
                                connectionSection
                            } else {
                                preferencesSection
                            }
                            feedbackSection
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 24)
                    }

                    Divider()
                    actionBar
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 760, idealWidth: 820, minHeight: 560, idealHeight: 700)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(visualStyle.windowBackground)
        .preferredColorScheme(themeColorScheme(for: theme))
        .environment(\.usageVisualStyle, visualStyle)
        .onAppear {
            theme = appState.settings.theme
            dashboardTheme = appState.settings.dashboardTheme
            panelSize = appState.settings.panelSize
            tokenDisplayMode = appState.settings.tokenDisplayMode
            refreshInterval = appState.settings.refreshInterval
            loadProfile(appState.selectedProfile)
        }
        .onReceive(NotificationCenter.default.publisher(for: .codexUsageSettingsCloseRequested)) { notification in
            guard let window = notification.object as? NSWindow,
                  window.title == "Codex 使用量设置" else { return }
            attemptDismiss()
        }
        .onChange(of: profileID) { newID in
            guard !isDraftNew,
                  let profile = appState.settings.profiles.first(where: { $0.id == newID }) else { return }
            loadProfile(profile)
        }
        .onChange(of: provider) { newProvider in
            errorMessage = nil
            testMessage = nil
            testSucceeded = false
            saved = false
            revealAPIKey = false
            let savedProvider = appState.settings.profiles
                .first(where: { $0.id == profileID })?
                .provider
            if isDraftNew || newProvider == .officialCodex || savedProvider != newProvider {
                apiKey = ""
            } else {
                do {
                    apiKey = try appState.loadStoredAPIKey(for: profileID)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        .onChange(of: baseURL) { _ in
            testMessage = nil
            testSucceeded = false
        }
        .onChange(of: apiKey) { _ in
            testMessage = nil
            testSucceeded = false
        }
        .onChange(of: newAPIUserID) { value in
            let digits = value.filter { $0.isNumber }
            if digits != value {
                newAPIUserID = digits
            }
            testMessage = nil
            testSucceeded = false
        }
        .confirmationDialog(
            "删除这个供应商配置？",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("删除配置", role: .destructive) {
                appState.deleteProfile(profileID)
                isDraftNew = false
                loadProfile(appState.selectedProfile)
            }
            Button("取消", role: .cancel) { }
        }
        .confirmationDialog(
            "放弃未保存的连接配置？",
            isPresented: $showDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("放弃修改", role: .destructive) {
                if pendingNewProfile {
                    pendingNewProfile = false
                    resetPreferencesToStored()
                    beginNewProfile()
                } else if let pendingProfileID,
                          let profile = appState.settings.profiles.first(where: { $0.id == pendingProfileID }) {
                    self.pendingProfileID = nil
                    resetPreferencesToStored()
                    loadProfile(profile)
                } else if pendingGlobalSettings {
                    pendingGlobalSettings = false
                    resetPreferencesToStored()
                    loadProfile(appState.selectedProfile)
                    settingsScope = .global
                } else {
                    closeSettingsWindow()
                }
            }
            Button("继续编辑", role: .cancel) { }
        } message: {
            Text(pendingGlobalSettings
                ? "连接信息或全局显示设置的修改尚未保存。"
                : "服务地址、认证信息或配置名称的修改尚未保存。")
        }
    }

    private var settingsHeader: some View {
        HStack(spacing: 10) {
            CodexMark(size: 32)
            VStack(alignment: .leading, spacing: 3) {
                Text("CODEX USAGE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(settingsScope == .connection ? "连接配置" : "全局显示设置")
                    .font(.title2.weight(.semibold))
            }
            Spacer()
            if hasUnsavedChanges {
                Label("未保存", systemImage: "circle.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(visualStyle.warning)
                    .help("当前连接配置有未保存的修改")
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
    }

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionHeader(
                title: "当前连接配置",
                caption: "仅对左侧选中的配置生效；地址、认证信息和用户 ID 独立保存"
            )

            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "配置名称", caption: "只用于识别当前连接配置")
                TextField("例如：公司 Sub2API / 个人 NewAPI", text: $profileName)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel("配置名称")
            }

            VStack(alignment: .leading, spacing: 9) {
                FieldLabel(title: "接口类型", caption: provider.subtitle)
                Picker("数据来源", selection: $provider) {
                    ForEach(ProviderKind.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .accessibilityLabel("数据来源")
            }

            Text("切换左侧配置不会混用其他配置的地址、Key 或用户 ID。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if provider == .officialCodex {
                officialSettings
            } else {
                proxySettings
            }
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(
                title: "全局显示设置",
                caption: "对所有连接配置共用，不会随左侧配置切换"
            )

            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "自动刷新", caption: "后台定时读取频率")
                Picker("自动刷新", selection: $refreshInterval) {
                    Text("1 分钟").tag(60.0)
                    Text("5 分钟").tag(300.0)
                    Text("15 分钟").tag(900.0)
                    Text("30 分钟").tag(1800.0)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .accessibilityLabel("自动刷新频率")
            }

            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "视觉主题", caption: "切换菜单的布局、配色与信息密度")
                DashboardThemeControl(selection: dashboardTheme) { selectedTheme in
                    dashboardTheme = selectedTheme
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "明暗模式", caption: "跟随系统，或固定浅色与深色")
                Picker("外观", selection: $theme) {
                    ForEach(ThemeMode.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .accessibilityLabel("明暗模式")
            }

            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "菜单面板", caption: "调整菜单栏弹出面板的外框尺寸")
                Picker("菜单面板", selection: $panelSize) {
                    ForEach(PanelSize.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .accessibilityLabel("菜单面板尺寸")
            }

            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "Token 显示", caption: "完整数字或使用 k / 万 / 亿缩写")
                TokenDisplayControl(selection: tokenDisplayMode) { mode in
                    tokenDisplayMode = mode
                }
            }
        }
    }

    @ViewBuilder
    private var feedbackSection: some View {
        if errorMessage != nil || testMessage != nil || saved {
            VStack(alignment: .leading, spacing: 8) {
                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(visualStyle.warning)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(visualStyle.warning.opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                if let testMessage {
                    Label(testMessage, systemImage: testSucceeded ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(testSucceeded ? visualStyle.positive : visualStyle.warning)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background((testSucceeded ? visualStyle.positive : visualStyle.warning).opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                if saved {
                    Label(
                        provider != .officialCodex && apiKey.isEmpty
                            ? "已保存，认证信息已清除。"
                            : "已保存，正在读取最新用量。",
                        systemImage: "checkmark.circle.fill"
                    )
                        .font(.subheadline)
                        .foregroundStyle(visualStyle.positive)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(visualStyle.positive.opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(.top, 18)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            if settingsScope == .connection {
                if provider != .officialCodex {
                    Button {
                        // Clearing is a draft change. The key is deleted only
                        // when the user saves this connection.
                        apiKey = ""
                        saved = false
                        errorMessage = nil
                        testMessage = nil
                        testSucceeded = false
                    } label: {
                        Label(provider == .newAPI ? "清除访问令牌" : "清除 API Key", systemImage: "trash")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.red)
                    .disabled(isDraftNew || apiKey.isEmpty)
                }
                Spacer()
                Button("取消") { attemptDismiss() }
                    .keyboardShortcut(.cancelAction)
                testConnectionButton
                Button("保存当前配置并连接") { save() }
                    .buttonStyle(.borderedProminent)
                    .tint(visualStyle.accent)
                    .keyboardShortcut(.defaultAction)
            } else {
                Spacer()
                Button("取消") { attemptDismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("保存全局设置") { save() }
                    .buttonStyle(.borderedProminent)
                    .tint(visualStyle.accent)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(visualStyle.windowBackground)
    }

    private var testConnectionButton: some View {
        Button {
            testConnection()
        } label: {
            if isTestingConnection {
                Label {
                    Text("测试中")
                } icon: {
                    ProgressView()
                        .controlSize(.small)
                }
            } else {
                Label("测试连接", systemImage: "checkmark.shield")
            }
        }
        .buttonStyle(.bordered)
        .disabled(isTestingConnection)
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("连接配置")
                        .font(.headline.weight(.semibold))
                    Text("每项独立保存地址与认证信息")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Button {
                    requestNewProfile()
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("新增供应商配置")
                .help("新增供应商配置")
            }

            VStack(spacing: 4) {
                ForEach(appState.settings.profiles) { profile in
                    profileRow(profile)
                }
                if isDraftNew {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(visualStyle.accent)
                            .frame(width: 7, height: 7)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("新供应商")
                                .font(.callout.weight(.medium))
                            Text("正在编辑")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "pencil")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(visualStyle.accent)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    .padding(.horizontal, 12)
                    .background(visualStyle.accent.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }

            Divider()

            Button {
                requestGlobalSettings()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "slider.horizontal.3")
                        .frame(width: 18)
                    Text("全局显示设置")
                        .font(.callout.weight(.medium))
                    Spacer(minLength: 8)
                    Image(systemName: settingsScope == .global ? "checkmark.circle.fill" : "chevron.right")
                        .foregroundStyle(settingsScope == .global ? visualStyle.accent : .secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .padding(.horizontal, 12)
                .background(settingsScope == .global ? visualStyle.accent.opacity(0.11) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("全局显示设置")
            .accessibilityValue(settingsScope == .global ? "正在编辑" : "")

            Spacer(minLength: 0)

            Divider()

            Button {
                showDeleteConfirmation = true
            } label: {
                Label("删除当前配置", systemImage: "trash")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
            .disabled(settingsScope == .global || isDraftNew || appState.settings.profiles.count <= 1)
            .accessibilityHint("删除前会要求确认")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(visualStyle.mutedSurface.opacity(0.58))
    }

    private func profileRow(_ profile: ProviderProfile) -> some View {
        let isEditing = settingsScope == .connection && profile.id == profileID
        let isActive = profile.id == appState.settings.selectedProfileID

        return Button {
            requestProfileSelection(profile)
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(isActive ? visualStyle.positive : visualStyle.separator)
                    .frame(width: 7, height: 7)
                VStack(alignment: .leading, spacing: 3) {
                    Text(profile.displayName)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                    Text(profile.detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 6)
                Image(systemName: isEditing ? (isActive ? "checkmark.circle.fill" : "pencil.circle.fill") : "chevron.right")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(isEditing ? visualStyle.accent : .secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 12)
            .background(profile.id == profileID ? visualStyle.accent.opacity(0.11) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(profile.displayName)
        .help(profile.displayName + " · " + profile.detailText)
        .accessibilityValue(
            (isActive ? "当前使用，" : "") +
            (isEditing ? "正在编辑，" : "") +
            profile.detailText
        )
    }

    private var proxySettings: some View {
        VStack(alignment: .leading, spacing: 17) {
            VStack(alignment: .leading, spacing: 5) {
                FieldLabel(
                    title: "服务地址",
                    caption: provider == .newAPI ? "填写 NewAPI 根地址，/api 和 /api/v1 会自动处理" : "Sub2API endpoint"
                )
                TextField(
                    provider == .newAPI ? "https://newapi.example.com" : "http://localhost:8080",
                    text: $baseURL
                )
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel("服务地址")
                if usesInsecureHTTP {
                    Label(
                        "HTTP 未加密，API Key 可能被窃听；仅用于可信内网。",
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.caption)
                    .foregroundStyle(visualStyle.warning)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                FieldLabel(
                    title: provider == .newAPI ? "访问令牌" : "API Key",
                    caption: provider == .newAPI
                        ? "NewAPI 管理 AccessToken，不是 sk- 聊天 API Key"
                        : "保存到 macOS 钥匙串，可直接粘贴"
                )
                HStack(spacing: 8) {
                    Group {
                        if revealAPIKey {
                            TextField(provider == .newAPI ? "NewAPI AccessToken" : "以 sk- 开头的 API Key", text: $apiKey)
                        } else {
                            SecureField(provider == .newAPI ? "NewAPI AccessToken" : "以 sk- 开头的 API Key", text: $apiKey)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel(provider == .newAPI ? "NewAPI 访问令牌" : "Sub2API API Key")
                    Button {
                        revealAPIKey.toggle()
                    } label: {
                        Image(systemName: revealAPIKey ? "eye.slash" : "eye")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(revealAPIKey ? "隐藏访问令牌" : "显示访问令牌")
                    .help(revealAPIKey ? "隐藏 Key" : "显示 Key")
                    Button {
                        copyAPIKey()
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.borderless)
                    .disabled(apiKey.isEmpty)
                    .accessibilityLabel("复制访问令牌")
                    .help("复制 Key")
                    Button {
                        pasteAPIKey()
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("粘贴访问令牌")
                    .help("粘贴 Key")
                }
            }

            if provider == .newAPI {
                VStack(alignment: .leading, spacing: 5) {
                    FieldLabel(title: "用户 ID", caption: "必须与 AccessToken 所属账号一致")
                    TextField("例如 1", text: $newAPIUserID)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("NewAPI 用户 ID")
                }
            }
        }
    }

    private var officialSettings: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(visualStyle.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 6) {
                Text("使用本机 Codex 登录态")
                    .font(.headline.weight(.semibold))
                Text("不需要填写 API Key。应用会通过本机 Codex app-server 读取官方的 5 小时、每日或 30 日配额窗口，以及账户 Token 用量。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func save() {
        if settingsScope == .global {
            appState.savePreferences(
                refreshInterval: refreshInterval,
                theme: theme,
                dashboardTheme: dashboardTheme,
                panelSize: panelSize,
                tokenDisplayMode: tokenDisplayMode
            )
            saved = true
            errorMessage = nil
            testMessage = nil
            initialDraftFingerprint = draftFingerprint
            return
        }

        let normalizedKey = normalizedAPIKey(apiKey)
        apiKey = normalizedKey
        do {
            try appState.saveProfile(
                id: profileID,
                name: profileName,
                provider: provider,
                baseURL: baseURL,
                apiKey: normalizedKey,
                newAPIUserID: newAPIUserID,
                refreshInterval: refreshInterval,
                theme: theme
            )
            appState.savePreferences(
                refreshInterval: refreshInterval,
                theme: theme,
                dashboardTheme: dashboardTheme,
                panelSize: panelSize,
                tokenDisplayMode: tokenDisplayMode
            )
            isDraftNew = false
            saved = true
            errorMessage = nil
            testMessage = nil
            initialDraftFingerprint = draftFingerprint
        } catch {
            saved = false
            errorMessage = error.localizedDescription
        }
    }

    private func testConnection() {
        guard !isTestingConnection else { return }

        do {
            let configuration = try ProviderConfiguration(
                provider: provider,
                baseURL: baseURL,
                apiKey: apiKey,
                newAPIUserID: newAPIUserID
            )
            let usageProvider = UsageProviderFactory.make(for: provider)
            isTestingConnection = true
            testMessage = nil
            testSucceeded = false
            errorMessage = nil

            Task { @MainActor in
                do {
                    if provider == .newAPI {
                        // Validate the access token and New-Api-User pair first,
                        // so authentication failures are not hidden by a later
                        // parallel logs/statistics request.
                        _ = try await usageProvider.fetchAccountBalance(configuration: configuration)
                    }
                    let snapshot = try await usageProvider.fetchUsage(configuration: configuration)
                    var message = "连接成功 · 今日 \(formatTokenCount(snapshot.today.totalTokens, mode: appState.settings.tokenDisplayMode)) tokens"
                    if let balance = snapshot.accountBalance {
                        message += " · \(balance.label) \(formatAccountBalance(balance))"
                    }
                    testMessage = message
                    testSucceeded = true
                } catch {
                    testMessage = error.localizedDescription
                    testSucceeded = false
                }
                isTestingConnection = false
            }
        } catch {
            testMessage = error.localizedDescription
            testSucceeded = false
        }
    }

    private func pasteAPIKey() {
        guard let pastedValue = NSPasteboard.general.string(forType: .string) else {
            errorMessage = "剪贴板中没有可用的文本"
            return
        }
        apiKey = normalizedAPIKey(pastedValue)
        errorMessage = nil
        saved = false
        testMessage = nil
        testSucceeded = false
    }

    private func copyAPIKey() {
        guard !apiKey.isEmpty else { return }
        let normalizedKey = normalizedAPIKey(apiKey)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(normalizedKey, forType: .string)
        errorMessage = nil
        testMessage = nil
        testSucceeded = false
    }

    private func normalizedAPIKey(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.lowercased().hasPrefix("bearer ") else { return trimmed }
        return String(trimmed.dropFirst("bearer ".count))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func beginNewProfile() {
        settingsScope = .connection
        isDraftNew = true
        profileID = UUID().uuidString
        profileName = "新供应商"
        provider = .sub2api
        baseURL = ""
        apiKey = ""
        revealAPIKey = false
        newAPIUserID = ""
        errorMessage = nil
        saved = false
        testMessage = nil
        testSucceeded = false
        initialDraftFingerprint = ""
    }

    private func loadProfile(_ profile: ProviderProfile) {
        settingsScope = .connection
        isDraftNew = false
        profileID = profile.id
        profileName = profile.name
        provider = profile.provider
        baseURL = profile.baseURL
        newAPIUserID = profile.newAPIUserID
        apiKey = ""
        revealAPIKey = false
        errorMessage = nil
        testMessage = nil
        testSucceeded = false
        do {
            apiKey = try appState.loadStoredAPIKey(for: profile.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        initialDraftFingerprint = draftFingerprint
    }

    private func resetPreferencesToStored() {
        refreshInterval = appState.settings.refreshInterval
        theme = appState.settings.theme
        dashboardTheme = appState.settings.dashboardTheme
        panelSize = appState.settings.panelSize
        tokenDisplayMode = appState.settings.tokenDisplayMode
    }

    private func attemptDismiss() {
        pendingProfileID = nil
        pendingNewProfile = false
        pendingGlobalSettings = false
        if hasUnsavedChanges {
            showDiscardConfirmation = true
        } else {
            closeSettingsWindow()
        }
    }

    private func closeSettingsWindow() {
        if let onCloseWindow {
            onCloseWindow()
        } else {
            dismiss()
        }
    }

    private func requestNewProfile() {
        guard hasUnsavedChanges else {
            beginNewProfile()
            return
        }
        pendingProfileID = nil
        pendingNewProfile = true
        pendingGlobalSettings = false
        showDiscardConfirmation = true
    }

    private func requestProfileSelection(_ profile: ProviderProfile) {
        guard settingsScope != .connection || profile.id != profileID else { return }
        guard hasUnsavedChanges else {
            loadProfile(profile)
            return
        }
        pendingProfileID = profile.id
        pendingNewProfile = false
        pendingGlobalSettings = false
        showDiscardConfirmation = true
    }

    private func requestGlobalSettings() {
        guard settingsScope != .global else { return }
        guard hasUnsavedChanges else {
            settingsScope = .global
            return
        }
        pendingProfileID = nil
        pendingNewProfile = false
        pendingGlobalSettings = true
        showDiscardConfirmation = true
    }
}

private struct CodexMark: View {
    @Environment(\.usageVisualStyle) private var visualStyle
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                .fill(visualStyle.accent)
            CodexMarkShape()
                .stroke(
                    .white,
                    style: StrokeStyle(
                        lineWidth: size * 0.105,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            CodexPulseShape()
                .stroke(
                    .white.opacity(0.94),
                    style: StrokeStyle(
                        lineWidth: size * 0.075,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
        }
        .frame(width: size, height: size)
    }
}

private struct CodexMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let left = rect.minX + rect.width * 0.25
        let right = rect.minX + rect.width * 0.75
        let top = rect.minY + rect.height * 0.27
        let bottom = rect.minY + rect.height * 0.73
        let middle = rect.midY
        var path = Path()
        path.move(to: CGPoint(x: right, y: top))
        path.addLine(to: CGPoint(x: left + rect.width * 0.10, y: top))
        path.addCurve(
            to: CGPoint(x: left, y: middle),
            control1: CGPoint(x: left, y: top),
            control2: CGPoint(x: left, y: middle - rect.height * 0.12)
        )
        path.addCurve(
            to: CGPoint(x: left + rect.width * 0.10, y: bottom),
            control1: CGPoint(x: left, y: middle + rect.height * 0.12),
            control2: CGPoint(x: left, y: bottom)
        )
        path.addLine(to: CGPoint(x: right, y: bottom))
        return path
    }
}

private struct CodexPulseShape: Shape {
    func path(in rect: CGRect) -> Path {
        let y = rect.midY
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.35, y: y))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.46, y: y))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.54, y: rect.minY + rect.height * 0.34))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.62, y: rect.minY + rect.height * 0.66))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.70, y: y))
        return path
    }
}

private struct IconButton: View {
    let systemImage: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(help)
        .help(help)
    }
}

private struct TokenDisplayControl: View {
    @Environment(\.usageVisualStyle) private var visualStyle
    let selection: TokenDisplayMode
    let action: (TokenDisplayMode) -> Void

    var body: some View {
        HStack(spacing: 2) {
            ForEach(TokenDisplayMode.allCases) { item in
                Button {
                    action(item)
                } label: {
                    Text(item.title)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .frame(minWidth: 28)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(
                                cornerRadius: visualStyle.theme == .graphite ? 3 : 5,
                                style: .continuous
                            )
                                .fill(item == selection ? visualStyle.accent.opacity(0.16) : .clear)
                        )
                        .foregroundStyle(item == selection ? visualStyle.accent : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(visualStyle.mutedSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: visualStyle.theme == .graphite ? 4 : 7,
                style: .continuous
            )
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Token 数字显示方式")
        .accessibilityValue(selection.title)
        .help("Token 数字显示方式")
    }
}

private struct DashboardThemeControl: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.usageVisualStyle) private var visualStyle
    let selection: DashboardTheme
    let action: (DashboardTheme) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(DashboardTheme.allCases) { item in
                let preview = UsageVisualStyle(theme: item, colorScheme: colorScheme)
                Button {
                    action(item)
                } label: {
                    VStack(alignment: .leading, spacing: 7) {
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(preview.heroSurface)
                            if item == .pulse {
                                HStack(alignment: .bottom, spacing: 4) {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(preview.accent)
                                        .frame(width: 14, height: 18)
                                    VStack(alignment: .leading, spacing: 4) {
                                        RoundedRectangle(cornerRadius: 1.5)
                                            .fill(preview.tertiaryAccent)
                                            .frame(width: 27, height: 3)
                                        HStack(spacing: 3) {
                                            RoundedRectangle(cornerRadius: 1.5)
                                                .fill(preview.secondaryAccent)
                                            RoundedRectangle(cornerRadius: 1.5)
                                                .fill(preview.quaternaryAccent)
                                                .frame(width: 10)
                                        }
                                        .frame(height: 3)
                                    }
                                }
                                .padding(6)
                            } else {
                                VStack(alignment: .leading, spacing: 4) {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(preview.accent)
                                        .frame(width: 28, height: 3)
                                    HStack(spacing: 3) {
                                        RoundedRectangle(cornerRadius: 1.5)
                                            .fill(preview.secondaryAccent)
                                        RoundedRectangle(cornerRadius: 1.5)
                                            .fill(preview.tertiaryAccent)
                                            .frame(width: 17)
                                    }
                                    .frame(height: 4)
                                }
                                .padding(6)
                            }
                        }
                        .frame(height: 31)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .stroke(preview.outline, lineWidth: 1)
                        }

                        HStack(spacing: 5) {
                            Text(item.title)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                            Spacer()
                            Image(systemName: item == selection ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(item == selection ? preview.accent : .secondary)
                    }
                    }
                    .frame(maxWidth: .infinity, minHeight: 51, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(item == selection ? preview.accent.opacity(0.07) : visualStyle.mutedSurface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(item == selection ? preview.accent.opacity(0.38) : visualStyle.outline, lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
                .accessibilityValue(item == selection ? "已选择" : "")
            }
        }
    }
}

private struct MetricDivider: View {
    var body: some View {
        Divider().frame(height: 32).padding(.horizontal, 7)
    }
}

private struct TokenBreakdownMetric: View {
    let title: String
    let value: String
    let fullValue: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(title)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .help("\(fullValue) tokens")
    }
}

private struct ColorMetricTile: View {
    let title: String
    let value: String
    let caption: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                Spacer(minLength: 0)
            }
            .foregroundStyle(.white.opacity(0.88))

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .foregroundStyle(.white)

            Text(caption)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct NightMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Rectangle()
                .fill(color)
                .frame(width: 16, height: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
    }
}

private struct PulseLabIndex: View {
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("01")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Rectangle()
                .fill(color)
                .frame(width: 4, height: 56)
            Text("LIVE")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .frame(width: 24, alignment: .leading)
        .accessibilityHidden(true)
    }
}

private struct PulseGridMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(title)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PulseDonut: View {
    @Environment(\.usageVisualStyle) private var visualStyle
    let value: String
    let input: Int
    let output: Int
    let cache: Int
    let colors: [Color]

    var body: some View {
        let total = max(input + output + cache, 1)
        let inputEnd = CGFloat(input) / CGFloat(total)
        let outputEnd = inputEnd + CGFloat(output) / CGFloat(total)

        return ZStack {
            Circle()
                .stroke(visualStyle.separator.opacity(0.18), lineWidth: 10)
            if input + output + cache > 0 {
                Circle()
                    .trim(from: 0, to: inputEnd)
                    .stroke(colors[0], style: StrokeStyle(lineWidth: 10, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
                Circle()
                    .trim(from: inputEnd, to: outputEnd)
                    .stroke(colors[1], style: StrokeStyle(lineWidth: 10, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
                Circle()
                    .trim(from: outputEnd, to: 1)
                    .stroke(colors[2], style: StrokeStyle(lineWidth: 10, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text("TOKENS")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 108, height: 108)
        .accessibilityLabel("今日使用 \(value) tokens")
        .accessibilityValue("输入 \(formatCount(input))，输出 \(formatCount(output))，缓存读取 \(formatCount(cache))")
    }
}

private struct PulseReadout: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Rectangle()
                    .fill(color)
                    .frame(width: 9, height: 2)
                Text(title)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PulseTokenReadout: View {
    let title: String
    let value: String
    let color: Color
    var inverted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(title)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(inverted ? Color.white.opacity(0.68) : Color.secondary)
            }
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .foregroundStyle(inverted ? Color.white : Color.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PulseActivityStrip: View {
    @Environment(\.usageVisualStyle) private var visualStyle
    let items: [DailyUsage]
    let maximum: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: PulseLayout.sectionGap) {
            HStack(alignment: .firstTextBaseline) {
                Text("使用趋势")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                Spacer()
                Text("最近 7 天")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            GeometryReader { proxy in
                let chartHeight = max(proxy.size.height, 1)
                let chartWidth = max(proxy.size.width, 1)
                let step = items.count > 1 ? chartWidth / CGFloat(items.count - 1) : chartWidth

                ZStack {
                    VStack(spacing: 0) {
                        Divider()
                        Spacer()
                        Divider()
                        Spacer()
                        Divider()
                    }
                    Path { path in
                        for (index, item) in items.enumerated() {
                            let x = items.count > 1 ? CGFloat(index) * step : chartWidth / 2
                            let ratio = CGFloat(item.totalTokens) / CGFloat(maximum)
                            let y = chartHeight - max(4, chartHeight * ratio)
                            let point = CGPoint(x: x, y: y)
                            if index == 0 {
                                path.move(to: point)
                            } else {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        let x = items.count > 1 ? CGFloat(index) * step : chartWidth / 2
                        let ratio = CGFloat(item.totalTokens) / CGFloat(maximum)
                        let y = chartHeight - max(4, chartHeight * ratio)
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                            .help("\(displayDate(item.date)) · \(formatCount(item.totalTokens)) tokens")
                    }
                }
            }
            .frame(height: 40)
            HStack(spacing: 0) {
                ForEach(items) { item in
                    Text(displayDate(item.date))
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, PulseLayout.sectionGap)
        .overlay(alignment: .top) {
            Divider()
        }
        .padding(.bottom, PulseLayout.sectionGap)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("最近 7 天使用趋势")
        .accessibilityValue(trendSummary)
    }

    private var trendSummary: String {
        items.map { "\(displayDate($0.date)) \(formatCount($0.totalTokens)) tokens" }.joined(separator: "，")
    }
}

private struct NightTokenMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
                Text(title)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InlinePerformanceMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StackedMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct OfficialMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.system(size: 10)).foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct QuotaWindowCard: View {
    @Environment(\.usageVisualStyle) private var visualStyle
    let window: OfficialRateLimitWindow
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(window.label)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    if let duration = window.durationMinutes {
                        Text(formatWindowDuration(duration))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(String(format: "%.0f%%", window.usedPercent))
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
            SegmentBar(ratio: window.usedPercent / 100, color: color)
                .frame(height: 7)
            HStack {
                Text("重置 " + formatResetDate(window.resetsAt))
                Spacer()
                Text(window.usedPercent >= 80 ? "接近上限" : "使用正常")
                    .foregroundStyle(window.usedPercent >= 80 ? visualStyle.warning : .secondary)
            }
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(visualStyle.mutedSurface)
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(visualStyle.outline, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct SegmentBar: View {
    @Environment(\.usageVisualStyle) private var visualStyle
    let ratio: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(visualStyle.mutedSurface)
                Capsule()
                    .fill(color)
                    .frame(width: max(2, proxy.size.width * min(max(ratio, 0), 1)))
            }
        }
    }
}

private struct TokenCompositionBar: View {
    @Environment(\.usageVisualStyle) private var visualStyle
    let input: Int
    let output: Int
    let cache: Int
    var isOnAccent = false

    var body: some View {
        GeometryReader { proxy in
            let total = input + output + cache
            if total > 0 {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(isOnAccent ? visualStyle.positive : visualStyle.accent)
                        .frame(width: segmentWidth(input, total: total, available: proxy.size.width))
                    Rectangle()
                        .fill(visualStyle.secondaryToken)
                        .frame(width: segmentWidth(output, total: total, available: proxy.size.width))
                    Rectangle()
                        .fill(visualStyle.tertiaryToken)
                        .frame(width: segmentWidth(cache, total: total, available: proxy.size.width))
                }
                .clipShape(Capsule())
            } else {
                Capsule().fill(isOnAccent ? Color.white.opacity(0.18) : visualStyle.separator.opacity(0.35))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Token 构成")
        .accessibilityValue("输入 \(formatCount(input))，输出 \(formatCount(output))，缓存读取 \(formatCount(cache))")
    }

    private func segmentWidth(_ value: Int, total: Int, available: CGFloat) -> CGFloat {
        available * CGFloat(value) / CGFloat(total)
    }
}

private struct StatePanel: View {
    @Environment(\.usageVisualStyle) private var visualStyle
    let mark: Bool
    let icon: String?
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if mark {
                CodexMark(size: 46)
            } else if let icon {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(visualStyle.accent)
            }
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button(buttonTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(visualStyle.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.vertical, 38)
    }
}

private struct SettingsSectionHeader: View {
    let title: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.semibold))
            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct FieldLabel: View {
    let title: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(caption).font(.caption).foregroundStyle(.secondary)
        }
    }
}

private func formatCount(_ value: Int) -> String {
    value.formatted(.number)
}

private func formatTokenCount(_ value: Int, mode: TokenDisplayMode = .compact) -> String {
    if mode == .full {
        return formatCount(value)
    }

    let magnitude = abs(value)
    let sign = value < 0 ? "-" : ""

    switch magnitude {
    case 100_000_000...:
        return sign + compactDecimal(Double(magnitude) / 100_000_000) + "亿"
    case 10_000...:
        return sign + compactDecimal(Double(magnitude) / 10_000) + "万"
    case 1_000...:
        return sign + compactDecimal(Double(magnitude) / 1_000) + "k"
    default:
        return sign + formatCount(magnitude)
    }
}

private func compactDecimal(_ value: Double) -> String {
    let format: String
    if value >= 100 {
        format = "%.0f"
    } else if value >= 10 {
        format = "%.1f"
    } else {
        format = "%.2f"
    }
    return String(format: format, value)
        .replacingOccurrences(of: "\\.00$", with: "", options: .regularExpression)
        .replacingOccurrences(of: "(\\.\\d)0$", with: "$1", options: .regularExpression)
}

private func formatBilling(_ value: Double, mode: BillingMode) -> String {
    switch mode {
    case .currency:
        return String(format: "$%.4f", value)
    case .quota:
        if value >= 1_000_000 {
            return String(format: "%.2fm", value / 1_000_000)
        }
        if value >= 1_000 {
            return String(format: "%.1fk", value / 1_000)
        }
        return String(format: "%.0f", value)
    }
}

private func formatAccountBalance(_ balance: AccountBalance) -> String {
    if let rawValue = balance.rawValue, balance.unit == .credits {
        return rawValue
    }
    guard let value = balance.value else { return "-" }
    switch balance.unit {
    case .currency:
        return String(format: "$%.2f", value)
    case .quota:
        return formatBilling(value, mode: .quota)
    case .credits:
        return String(format: "%.0f", value)
    }
}

private func formatLatency(_ value: Double) -> String {
    guard value > 0 else { return "-" }
    if value >= 1_000 { return String(format: "%.1fs", value / 1_000) }
    return String(format: "%.0fms", value)
}

private func formatRate(_ value: Double) -> String {
    guard value > 0 else { return "-" }
    if value >= 1_000 { return String(format: "%.1fk", value / 1_000) }
    return String(format: "%.0f", value)
}

private func formatOptionalCount(_ value: Int?) -> String {
    guard let value else { return "-" }
    return formatCount(value)
}

private func formatOptionalTokenCount(_ value: Int?) -> String {
    guard let value else { return "-" }
    return formatTokenCount(value)
}

private func displayDate(_ value: String) -> String {
    let parts = value.split(separator: "-")
    guard parts.count >= 3 else { return value }
    return String(parts[1]) + "/" + String(parts[2])
}

private func recentDailyUsage(_ items: [DailyUsage], limit: Int, ascending: Bool) -> [DailyUsage] {
    let recent = Array(items.sorted { $0.date > $1.date }.prefix(limit))
    return ascending ? recent.reversed() : recent
}

private func planTitle(_ value: String?) -> String {
    guard let value else { return "官方账户" }
    switch value.lowercased() {
    case "plus": return "Plus"
    case "pro": return "Pro"
    case "team": return "Team"
    case "business", "self_serve_business_usage_based": return "Business"
    case "enterprise", "enterprise_cbp_usage_based": return "Enterprise"
    case "go": return "Go"
    case "free": return "Free"
    default: return value.capitalized
    }
}

private func formatWindowDuration(_ minutes: Int) -> String {
    if minutes % (24 * 60) == 0 { return "\(minutes / (24 * 60)) 日窗口" }
    if minutes % 60 == 0 { return "\(minutes / 60) 小时窗口" }
    return "\(minutes) 分钟窗口"
}

private func formatResetDate(_ date: Date?) -> String {
    guard let date else { return "未知" }
    return date.formatted(date: .omitted, time: .shortened)
}

private func themeColorScheme(for theme: ThemeMode) -> ColorScheme? {
    switch theme {
    case .system: return nil
    case .light: return .light
    case .dark: return .dark
    }
}

private func resolvedColorScheme(theme: ThemeMode, system: ColorScheme) -> ColorScheme {
    switch theme {
    case .system: return system
    case .light: return .light
    case .dark: return .dark
    }
}
