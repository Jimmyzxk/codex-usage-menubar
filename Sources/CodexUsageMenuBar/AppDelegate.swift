import AppKit

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        application.setActivationPolicy(.accessory)
        application.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if !isPreviewMode, anotherInstanceIsRunning {
            NSApp.terminate(nil)
            return
        }
        installEditMenu()
        menuBarController = MenuBarController()
        menuBarController?.start()
    }

    private var isPreviewMode: Bool {
        ProcessInfo.processInfo.environment["CODEX_USAGE_PREVIEW"] == "1"
    }

    private var anotherInstanceIsRunning: Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return false }
        let currentPID = ProcessInfo.processInfo.processIdentifier
        guard let existing = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
            .first(where: { $0.processIdentifier != currentPID }) else {
            return false
        }
        existing.activate(options: [.activateIgnoringOtherApps])
        return true
    }

    private func installEditMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = NSMenu(title: "Codex Usage")
        mainMenu.addItem(appMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "编辑")
        editMenu.addItem(withTitle: "撤销", action: #selector(UndoManager.undo), keyEquivalent: "z")
        editMenu.addItem(withTitle: "重做", action: #selector(UndoManager.redo), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "剪切", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "复制", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "粘贴", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "全选", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)
        NSApp.mainMenu = mainMenu
    }
}
