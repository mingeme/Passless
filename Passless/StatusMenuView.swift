import SwiftUI
import SwiftData

// 带悬停效果的按钮组件
struct HoverButton<Trailing: View>: View {
    let title: String
    let action: () -> Void
    let trailing: (() -> Trailing)?
    
    @State private var isHovered = false
    
    init(title: String, action: @escaping () -> Void, trailing: (() -> Trailing)? = nil) {
        self.title = title
        self.action = action
        self.trailing = trailing
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let trailing = trailing {
                    trailing()
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
        }
        .buttonStyle(.plain)
        .background(isHovered ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(4)
        .onHover { hover in
            isHovered = hover
        }
    }
}

// 当 trailing 为空时的特化
extension HoverButton where Trailing == EmptyView {
    init(title: String, action: @escaping () -> Void) {
        self.init(title: title, action: action, trailing: nil)
    }
}

struct StatusMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [PasswordEntry]
    @State private var searchText = ""
    @State private var hoveredEntryId: PersistentIdentifier? = nil
    
    var filteredEntries: [PasswordEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.name.localizedCaseInsensitiveContains(searchText) ||
                entry.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索框
            HStack(spacing: 6) {
                // 左侧搜索图标
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .frame(width: 16, height: 16)
                
                // 输入框
                TextField("搜索", text: $searchText)
                    .textFieldStyle(.plain)
                
                // 右侧清除按钮
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
            )
            .padding(8)
            
            Divider()
            
            // 账号列表
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredEntries) { entry in
                        EntryRow(entry: entry, hoveredEntryId: $hoveredEntryId)
                    }
                    
                    if filteredEntries.isEmpty {
                        Text("没有找到匹配的账号")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(width: 280, height: 300)
            
            Divider()
            
            // 底部按钮
            VStack(spacing: 4) {
                // 打开主程序按钮
                HoverButton(title: "打开主程序", action: {
                    NSApp.activate(ignoringOtherApps: true)
                    if let window = NSApplication.shared.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                })
                
                // 退出按钮
                HoverButton(title: "退出", action: {
                    NSApplication.shared.terminate(nil)
                }, trailing: {
                    // Command+Q 快捷键指示
                    HStack(spacing: 2) {
                        Image(systemName: "command")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Text("Q")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                })
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .frame(width: 280)
    }
}

struct EntryRow: View {
    let entry: PasswordEntry
    @Binding var hoveredEntryId: PersistentIdentifier?
    @State private var isHovered = false
    
    var body: some View {
        Button {
            autofillCredentials(username: entry.username, password: entry.password)
        } label: {
            // 账号信息
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(entry.username)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(8)
        .contentShape(Rectangle())
        .background(isHovered ? Color(NSColor.selectedTextBackgroundColor).opacity(0.3) : Color.clear)
        .onHover { isHovered in
            self.isHovered = isHovered
            if isHovered {
                hoveredEntryId = entry.id
            } else if hoveredEntryId == entry.id {
                hoveredEntryId = nil
            }
        }
    }
    
    // 复用之前的自动填充功能
    func autofillCredentials(username: String, password: String) {
        // 先关闭状态栏菜单
        NotificationCenter.default.post(name: .closeStatusMenu, object: nil)
        
        // 使用 NSPasteboard 实现自动填充，更可靠
        let pasteboard = NSPasteboard.general
        
        // 保存当前剪贴板内容，以便后续恢复
        let oldPasteboardContent = pasteboard.string(forType: .string)
        
        // 获取前台应用
        let frontmostApp = NSWorkspace.shared.frontmostApplication
        
        // 等待状态栏菜单关闭，然后切换回前台应用
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 切换到目标应用
            if let frontApp = frontmostApp {
                frontApp.activate(options: .activateIgnoringOtherApps)
            }
            
            // 等待应用激活后再进行自动填充
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // 创建事件源
                let eventSource = CGEventSource(stateID: .combinedSessionState)
                
                // 复制用户名到剪贴板
                pasteboard.clearContents()
                pasteboard.setString(username, forType: .string)
                
                // 模拟 Command+V 粘贴用户名
                let cmdDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x37, keyDown: true)
                let vDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: true) // 0x09 is 'v'
                let vUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: false)
                let cmdUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x37, keyDown: false)
                
                vDown?.flags = .maskCommand
                vUp?.flags = .maskCommand
                
                cmdDown?.post(tap: .cghidEventTap)
                vDown?.post(tap: .cghidEventTap)
                vUp?.post(tap: .cghidEventTap)
                cmdUp?.post(tap: .cghidEventTap)
                
                // 模拟 Tab 键
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let tabDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x30, keyDown: true)
                    let tabUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x30, keyDown: false)
                    tabDown?.post(tap: .cghidEventTap)
                    tabUp?.post(tap: .cghidEventTap)
                    
                    // 复制密码到剪贴板
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        pasteboard.clearContents()
                        pasteboard.setString(password, forType: .string)
                        
                        // 模拟 Command+V 粘贴密码
                        cmdDown?.post(tap: .cghidEventTap)
                        vDown?.post(tap: .cghidEventTap)
                        vUp?.post(tap: .cghidEventTap)
                        cmdUp?.post(tap: .cghidEventTap)
                        
                        // 恢复剪贴板原有内容
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            pasteboard.clearContents()
                            if let oldContent = oldPasteboardContent {
                                pasteboard.setString(oldContent, forType: .string)
                            }
                        }
                    }
                }
            }
        }
    }
}

// 关闭状态菜单的通知
extension Notification.Name {
    static let closeStatusMenu = Notification.Name("closeStatusMenu")
}

#Preview {
    StatusMenuView()
        .modelContainer(for: PasswordEntry.self, inMemory: true)
}
