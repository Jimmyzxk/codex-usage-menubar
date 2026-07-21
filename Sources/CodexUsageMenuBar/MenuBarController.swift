import AppKit
import Combine
import SwiftUI

extension Notification.Name {
    static let codexUsageSettingsCloseRequested = Notification.Name(
        "CodexUsageMenuBar.settingsCloseRequested"
    )
}

private final class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    weak var window: NSWindow?
    var allowClose = false

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if allowClose {
            allowClose = false
            return true
        }
        NotificationCenter.default.post(
            name: .codexUsageSettingsCloseRequested,
            object: sender
        )
        return false
    }

    func closeAfterConfirmation() {
        allowClose = true
        window?.close()
    }
}

@MainActor
final class MenuBarController: NSObject {
    private let appState: AppState
    private let isPreviewMode: Bool
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private var settingsWindowController: NSWindowController?
    private var settingsWindowDelegate: SettingsWindowDelegate?
    private var previewWindowController: NSWindowController?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        let environment = ProcessInfo.processInfo.environment
        isPreviewMode = environment["CODEX_USAGE_PREVIEW"] == "1"
        if isPreviewMode {
            let dashboardTheme = DashboardTheme(rawValue: environment["CODEX_USAGE_DASHBOARD_THEME"] ?? "") ?? .clarity
            let theme = ThemeMode(rawValue: environment["CODEX_USAGE_COLOR_MODE"] ?? "") ?? .light
            let panelSize = PanelSize(rawValue: environment["CODEX_USAGE_PANEL_SIZE"] ?? "") ?? .standard
            let isOfficial = environment["CODEX_USAGE_PREVIEW_SOURCE"] == "official"
            let profile = ProviderProfile(
                id: "preview-profile",
                name: isOfficial ? "官方 Codex" : "工作区 Sub2API",
                provider: isOfficial ? .officialCodex : .sub2api,
                baseURL: isOfficial ? "" : AppSettings.defaultBaseURL
            )
            let settings = AppSettings(
                profiles: [profile],
                selectedProfileID: profile.id,
                refreshInterval: 300,
                theme: theme,
                dashboardTheme: dashboardTheme,
                panelSize: panelSize,
                tokenDisplayMode: .compact
            )
            let defaults = UserDefaults(suiteName: "com.codexusage.menubar.preview") ?? .standard
            appState = AppState(
                settingsStore: SettingsStore(defaults: defaults),
                initialSettings: settings,
                previewSnapshot: isOfficial ? PreviewData.official : PreviewData.proxy
            )
        } else {
            appState = AppState()
        }
        super.init()

        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover(_:))
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        statusItem.button?.image = Self.makeStatusIcon()
        statusItem.button?.imagePosition = .imageLeading
        statusItem.button?.toolTip = "Codex 使用量"
        statusItem.button?.title = "Codex"
        statusItem.isVisible = true

        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = Self.popoverSize(for: appState.settings.panelSize)
        popover.contentViewController = NSHostingController(
            rootView: ContentView(onOpenSettings: { [weak self] in
                self?.openSettings()
            })
            .environmentObject(appState)
        )

        observeState()
    }

    func start() {
        appState.start()
        if isPreviewMode {
            if ProcessInfo.processInfo.environment["CODEX_USAGE_PREVIEW_SETTINGS"] == "1" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                    self?.openSettings()
                }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.openPreviewWindow()
            }
            return
        }
        if !appState.hasConfiguredAPIKey {
            Task { @MainActor [weak self] in
                guard let self, !self.appState.hasConfiguredAPIKey else { return }
                self.openSettings()
            }
        }
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard statusItem.button != nil else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func openPreviewWindow() {
        let rootView = ContentView(onOpenSettings: {})
            .environmentObject(appState)
        let hostingController = NSHostingController(rootView: rootView)
        let window = NSPanel(contentViewController: hostingController)
        window.title = "Codex Usage Preview"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.isFloatingPanel = true
        window.level = .floating
        window.setContentSize(Self.popoverSize(for: appState.settings.panelSize))
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.center()

        let controller = NSWindowController(window: window)
        previewWindowController = controller
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func openSettings() {
        popover.performClose(nil)

        if let settingsWindowController {
            settingsWindowController.showWindow(nil)
            settingsWindowController.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let delegate = SettingsWindowDelegate()
        let rootView = SettingsView(
            onCloseWindow: { [weak delegate] in
                delegate?.closeAfterConfirmation()
            }
        )
        .environmentObject(appState)
        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Codex 使用量设置"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 820, height: 700))
        window.minSize = NSSize(width: 760, height: 560)
        window.isReleasedWhenClosed = false
        window.center()
        delegate.window = window
        window.delegate = delegate

        let controller = NSWindowController(window: window)
        settingsWindowController = controller
        settingsWindowDelegate = delegate
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func observeState() {
        appState.$settings
            .receive(on: RunLoop.main)
            .sink { [weak self] settings in
                self?.popover.contentSize = Self.popoverSize(for: settings.panelSize)
            }
            .store(in: &cancellables)

        appState.$snapshot
            .combineLatest(appState.$isLoading, appState.$lastError)
            .combineLatest(appState.$settings)
            .receive(on: RunLoop.main)
            .sink { [weak self] state, settings in
                guard let self else { return }
                let (snapshot, isLoading, error) = state
                if isLoading {
                    self.statusItem.button?.title = " ..."
                } else if let snapshot {
                    if let window = snapshot.official?.primary ?? snapshot.official?.secondary {
                        self.statusItem.button?.title = String(format: " %.0f%%", window.usedPercent)
                    } else {
                        self.statusItem.button?.title = " \(Self.compact(snapshot.today.totalTokens, mode: settings.tokenDisplayMode))"
                    }
                } else if error != nil {
                    self.statusItem.button?.title = " !"
                } else {
                    self.statusItem.button?.title = "Codex"
                }
            }
            .store(in: &cancellables)
    }

    private static func compact(_ value: Int, mode: TokenDisplayMode) -> String {
        if mode == .full {
            return value.formatted(.number)
        }
        switch value {
        case 100_000_000...:
            return String(format: "%.1f亿", Double(value) / 100_000_000)
        case 10_000...:
            return String(format: "%.1f万", Double(value) / 10_000)
        case 1_000...:
            return String(format: "%.1fk", Double(value) / 1_000)
        default:
            return value.formatted(.number)
        }
    }

    private static func popoverSize(for panelSize: PanelSize) -> NSSize {
        NSSize(width: CGFloat(panelSize.width), height: CGFloat(panelSize.height))
    }

    private static func makeStatusIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        NSColor.black.setStroke()
        let left: CGFloat = 4.0
        let right: CGFloat = 14.0
        let top: CGFloat = 3.5
        let bottom: CGFloat = 14.5
        let middle: CGFloat = 9.0

        let mark = NSBezierPath()
        mark.lineWidth = 2.0
        mark.lineCapStyle = .round
        mark.lineJoinStyle = .round
        mark.move(to: NSPoint(x: right, y: top))
        mark.line(to: NSPoint(x: left + 2.0, y: top))
        mark.curve(
            to: NSPoint(x: left, y: middle),
            controlPoint1: NSPoint(x: left, y: top),
            controlPoint2: NSPoint(x: left, y: middle - 2.0)
        )
        mark.curve(
            to: NSPoint(x: left + 2.0, y: bottom),
            controlPoint1: NSPoint(x: left, y: middle + 2.0),
            controlPoint2: NSPoint(x: left, y: bottom)
        )
        mark.line(to: NSPoint(x: right, y: bottom))
        mark.stroke()

        let pulse = NSBezierPath()
        pulse.lineWidth = 1.45
        pulse.lineCapStyle = .round
        pulse.lineJoinStyle = .round
        pulse.move(to: NSPoint(x: 6.3, y: middle))
        pulse.line(to: NSPoint(x: 8.2, y: middle))
        pulse.line(to: NSPoint(x: 9.4, y: 5.8))
        pulse.line(to: NSPoint(x: 10.6, y: 12.2))
        pulse.line(to: NSPoint(x: 11.8, y: middle))
        pulse.stroke()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
