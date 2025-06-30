import SwiftUI
import SwiftData
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 运行在菜单栏模式
        NSApp.setActivationPolicy(.accessory) // 这会设置应用为菜单栏附件模式

        // 防止应用在关闭所有窗口后退出
        NSApp.activate(ignoringOtherApps: true)

        // 初始化状态栏
        setupStatusBar()
    }

    private func setupStatusBar() {
        guard statusBarController == nil else { return }

        // 获取共享的 ModelContainer
        let schema = Schema([PasswordEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let sharedModelContainer: ModelContainer
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Could not create ModelContainer: \(error)")
            return
        }

        // 创建状态栏控制器，使用浮动面板
        self.statusBarController = StatusBarController(
            modelContainer: sharedModelContainer
        )

        // 添加通知监听器来关闭状态菜单
        NotificationCenter.default.addObserver(forName: .closeStatusMenu, object: nil, queue: nil) { _ in
            self.statusBarController?.closePanel()
        }
    }


    
    // 当所有窗口都关闭时，防止应用退出
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
}
