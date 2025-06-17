import SwiftUI
import SwiftData
import AppKit

@main
struct PasslessApp: App {
    @State private var statusBarController: StatusBarController?
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PasswordEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // 设置应用程序的外观和行为
        let appearance = NSAppearance(named: .aqua)
        NSApplication.shared.appearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onAppear {
                    setupStatusBar()
                }
        }
    }
    
    private func setupStatusBar() {
        // 创建一个 NSPopover 来容纳我们的 SwiftUI 视图
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 380)
        popover.behavior = .transient
        
        // 将 StatusMenuView 嵌入到 NSHostingController 中
        let statusMenuView = StatusMenuView()
            .modelContainer(sharedModelContainer)
        popover.contentViewController = NSHostingController(rootView: statusMenuView)
        
        // 创建状态栏控制器
        self.statusBarController = StatusBarController(popover: popover)
        
        // 添加通知监听器来关闭状态菜单
        NotificationCenter.default.addObserver(forName: .closeStatusMenu, object: nil, queue: nil) { _ in
            self.statusBarController?.closePopover()
        }
    }
}

// AppDelegate 类，用于处理应用程序级别的事件
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 运行在菜单栏模式
        NSApp.setActivationPolicy(.accessory) // 这会设置应用为菜单栏附件模式
        
        // 防止应用在关闭所有窗口后退出
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // 当所有窗口都关闭时，防止应用退出
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // 允许在 Dock 中点击图标重新打开主窗口
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in NSApplication.shared.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
}
