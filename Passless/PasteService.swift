import Foundation
import AppKit

@MainActor
class PasteService: ObservableObject {
    static let shared = PasteService()

    private init() {}

    func pasteCredentials(username: String, password: String) {
        // 检查辅助功能权限
        guard checkAccessibilityPermissions() else {
            showAccessibilityAlert()
            return
        }

        // 关闭浮动面板
        NotificationCenter.default.post(name: NSNotification.Name("CloseMenuBar"), object: nil)

        // 等待面板关闭，然后执行粘贴操作
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.performClipboardPasteSequence(username: username, password: password)
        }
    }

    // 检查辅助功能权限
    private func checkAccessibilityPermissions() -> Bool {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    // 显示权限提示
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "Passless 需要辅助功能权限才能自动输入用户名和密码。请在系统偏好设置 > 安全性与隐私 > 隐私 > 辅助功能中添加 Passless。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开系统偏好设置")
        alert.addButton(withTitle: "取消")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }

    private func pressTab() {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        let tabDown = CGEvent(keyboardEventSource: source, virtualKey: 0x30, keyDown: true)
        let tabUp = CGEvent(keyboardEventSource: source, virtualKey: 0x30, keyDown: false)

        tabDown?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 0.05)
        tabUp?.post(tap: .cghidEventTap)
    }

    // 使用剪贴板粘贴文本
    private func pasteText(_ text: String) {
        let pasteboard = NSPasteboard.general
        let originalContents = pasteboard.string(forType: .string) // 保存原始剪贴板内容

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        // 模拟 Cmd+V
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

        cmdDown?.flags = .maskCommand
        vDown?.flags = .maskCommand

        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 0.05)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)

        // 延迟后恢复原始剪贴板内容
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let originalContents = originalContents {
                pasteboard.clearContents()
                pasteboard.setString(originalContents, forType: .string)
            }
        }
    }

    private func performClipboardPasteSequence(username: String, password: String) {
        let pasteDelay = UserDefaults.standard.double(forKey: "pasteDelay")
        let delay = pasteDelay > 0 ? pasteDelay : 0.2

        // 1. 粘贴用户名
        self.pasteText(username)

        // 2. 等待后按Tab键
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.pressTab()

            // 3. 再等待后粘贴密码
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.pasteText(password)
            }
        }
    }
}
