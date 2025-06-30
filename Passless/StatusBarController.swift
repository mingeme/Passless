import SwiftUI
import AppKit
import SwiftData

class StatusBarController: NSObject {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var floatingPanel: FloatingPanel<ContentView>?

    init(modelContainer: ModelContainer) {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        super.init()

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: "Passless")
            statusBarButton.action = #selector(togglePanel(_:))
            statusBarButton.target = self
        }

        // 创建浮动面板
        self.floatingPanel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 400),
            statusBarButton: statusItem.button,
            modelContainer: modelContainer
        ) {
            ContentView()
        }

        // 监听关闭通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(closePanel),
            name: NSNotification.Name("CloseMenuBar"),
            object: nil
        )
    }

    @objc func togglePanel(_ sender: AnyObject?) {
        floatingPanel?.toggle()
    }

    @objc func closePanel() {
        floatingPanel?.close()
    }

    func showPanelAtLocation(_ location: NSPoint) {
        floatingPanel?.showAtLocation(location)
    }
}
