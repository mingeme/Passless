import SwiftUI
import AppKit
import SwiftData

// 浮动面板实现，参考您提供的代码结构
class FloatingPanel<Content: View>: NSPanel, NSWindowDelegate {
    var isPresented: Bool = false
    var statusBarButton: NSStatusBarButton?
    private var modelContainer: ModelContainer

    override var isMovable: Bool {
        get { true }
        set {}
    }

    init(
        contentRect: NSRect,
        identifier: String = "PasslessFloatingPanel",
        statusBarButton: NSStatusBarButton? = nil,
        modelContainer: ModelContainer,
        view: () -> Content
    ) {
        self.modelContainer = modelContainer

        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .titled, .resizable, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.statusBarButton = statusBarButton
        self.identifier = NSUserInterfaceItemIdentifier(identifier)

        delegate = self

        // 面板配置
        animationBehavior = .none
        isFloatingPanel = true
        level = .statusBar
        collectionBehavior = [.auxiliary, .stationary, .moveToActiveSpace, .fullScreenAuxiliary]
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false

        // 隐藏所有交通灯按钮
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        // 设置内容视图
        contentView = NSHostingView(
            rootView: view()
                .modelContainer(modelContainer)
                .ignoresSafeArea()
        )
    }

    func toggle(height: CGFloat = 400) {
        if isPresented {
            close()
        } else {
            open(height: height)
        }
    }

    func open(height: CGFloat = 400) {
        // 设置面板大小
        setContentSize(NSSize(width: 280, height: height))

        // 计算位置 - 在状态栏按钮下方居中
        if let button = statusBarButton,
           let buttonWindow = button.window {

            let buttonFrame = button.convert(button.bounds, to: nil)
            let buttonScreenFrame = buttonWindow.convertToScreen(buttonFrame)

            let panelX = buttonScreenFrame.midX - frame.width / 2
            let panelY = buttonScreenFrame.minY - frame.height - 5

            setFrameOrigin(NSPoint(x: panelX, y: panelY))
        }

        // 显示面板
        orderFrontRegardless()
        makeKey()
        isPresented = true

        // 高亮状态栏按钮
        DispatchQueue.main.async {
            self.statusBarButton?.isHighlighted = true
        }
    }

    func showAtLocation(_ location: NSPoint, height: CGFloat = 400) {
        // 设置面板大小
        setContentSize(NSSize(width: 280, height: height))

        // 计算位置 - 在鼠标位置附近，但确保不超出屏幕边界
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect.zero

        var panelX = location.x - frame.width / 2
        var panelY = location.y - frame.height - 10

        // 确保面板不超出屏幕左右边界
        if panelX < screenFrame.minX {
            panelX = screenFrame.minX + 10
        } else if panelX + frame.width > screenFrame.maxX {
            panelX = screenFrame.maxX - frame.width - 10
        }

        // 确保面板不超出屏幕上下边界
        if panelY < screenFrame.minY {
            panelY = location.y + 10 // 如果下方空间不够，显示在鼠标上方
        } else if panelY + frame.height > screenFrame.maxY {
            panelY = screenFrame.maxY - frame.height - 10
        }

        setFrameOrigin(NSPoint(x: panelX, y: panelY))

        // 显示面板
        orderFrontRegardless()
        makeKey()
        isPresented = true

        // 不高亮状态栏按钮（因为这是通过快捷键触发的）
    }

    // 当失去焦点时自动关闭，例如点击外部区域
    override func resignKey() {
        super.resignKey()
        // 关闭面板
        close()
    }

    override func close() {
        super.close()
        isPresented = false
        statusBarButton?.isHighlighted = false
    }

    // 允许面板内的文本输入获得焦点
    override var canBecomeKey: Bool {
        return true
    }
}
