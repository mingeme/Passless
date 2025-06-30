import SwiftUI

struct FooterView: View {
    @ObservedObject private var appState = AppState.shared
    @State private var hoveredItem: String? = nil
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                FooterMenuItem(
                    title: "设置",
                    shortcut: "⌘,",
                    isHovered: hoveredItem == "settings"
                ) {
                    openSettings()
                    DispatchQueue.main.async {
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
                .onHover { isHovered in
                    hoveredItem = isHovered ? "settings" : nil
                }
                
                FooterMenuItem(
                    title: "退出",
                    shortcut: "⌘Q",
                    isHovered: hoveredItem == "quit"
                ) {
                    NSApplication.shared.terminate(nil)
                }
                .onHover { isHovered in
                    hoveredItem = isHovered ? "quit" : nil
                }
            }
        }
    }
    
    private func showAboutDialog() {
        let alert = NSAlert()
        alert.messageText = "Passless"
        alert.informativeText = "一个简洁的密码管理器\n版本 1.0"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}

struct FooterMenuItem: View {
    let title: String
    let shortcut: String
    let isHovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)

                Spacer()

                if !shortcut.isEmpty {
                    Text(shortcut)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            Rectangle()
                .fill(isHovered ? Color.accentColor.opacity(0.8) : Color.clear)
        )
    }
}
