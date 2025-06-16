import SwiftUI
import SwiftData
import AppKit
import Cocoa

struct ContentView: View {
    // 用于自动填充的延迟时间（秒）
    private let autofillDelay: TimeInterval = 0.5
    
    // 记录上一个活动窗口
    @State private var previousActiveApp: NSRunningApplication? = nil
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [PasswordEntry]
    
    @State private var selectedEntries = Set<String>()
    @State private var searchText = ""
    @State private var showingAddEntrySheet = false
    @State private var hasCheckedInitialData = false
    @State private var shouldScrollToTop = false
    
    var filteredEntries: [PasswordEntry] {
        if !searchText.isEmpty {
            return entries.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.username.localizedCaseInsensitiveContains(searchText)
            }
        }
        return entries
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                SearchBar(text: $searchText)
                
                ScrollViewReader { proxy in
                    List(selection: $selectedEntries) {
                        ForEach(filteredEntries) { entry in
                            VStack(alignment: .leading) {
                                Text(entry.name)
                                    .font(.headline)
                                
                                Text(entry.username)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .tag(entry.name)
                            .contextMenu {
                                Button(action: {
                                    // 在填充前记录当前窗口
                                    savePreviousActiveApp()
                                    autofillCredentials(username: entry.username, password: entry.password)
                                }) {
                                    Label("填充", systemImage: "keyboard")
                                }
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                    .onChange(of: searchText) { oldValue, newValue in
                        if newValue.isEmpty && !oldValue.isEmpty {
                            withAnimation {
                                if let firstEntry = filteredEntries.first {
                                    proxy.scrollTo(firstEntry.name, anchor: .top)
                                }
                            }
                        }
                    }
                    .onChange(of: shouldScrollToTop) { _, _ in
                        if shouldScrollToTop && !filteredEntries.isEmpty {
                            withAnimation {
                                proxy.scrollTo(filteredEntries[0].name, anchor: .top)
                            }
                            shouldScrollToTop = false
                        }
                    }
                    .onChange(of: entries.count) { _, _ in
                        if !filteredEntries.isEmpty {
                            withAnimation {
                                proxy.scrollTo(filteredEntries[0].name, anchor: .top)
                            }
                        }
                    }
                }
            }
            .navigationTitle("密码管理")
            .frame(minWidth: 300)
            .toolbar {
                ToolbarItem {
                    Button(action: { showingAddEntrySheet = true }) {
                        Label("添加", systemImage: "plus")
                    }
                }
                
                ToolbarItem {
                    Button(action: {
                        for entryName in selectedEntries {
                            if let entryToDelete = filteredEntries.first(where: { $0.name == entryName }) {
                                modelContext.delete(entryToDelete)
                            }
                        }
                        selectedEntries.removeAll()
                    }) {
                        Label("删除", systemImage: "trash")
                    }
                    .disabled(selectedEntries.isEmpty)
                }
            }
        } detail: {
            if let firstSelectedName = selectedEntries.first,
               let selectedEntry = filteredEntries.first(where: { $0.name == firstSelectedName }) {
                EntryDetailView(entry: selectedEntry)
            } else {
                Text("未选择任何项目")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingAddEntrySheet) {
            AddEntryView(onSave: {
                shouldScrollToTop = true
            })
        }
        .onAppear {
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredEntries[index])
            }
        }
    }
    
    // 保存上一个活动窗口
    private func savePreviousActiveApp() {
        // 获取当前活动窗口（在点击菜单前的窗口）
        if let frontmostApp = NSWorkspace.shared.frontmostApplication {
            // 如果不是我们自己的应用，则记录下来
            if frontmostApp.bundleIdentifier != Bundle.main.bundleIdentifier {
                previousActiveApp = frontmostApp
            }
        }
    }
    
    // 自动填充凭据函数
    private func autofillCredentials(username: String, password: String) {
        // 延迟执行，给用户时间准备
        DispatchQueue.main.asyncAfter(deadline: .now() + autofillDelay) {
            // 切换回上一个活动窗口
            self.switchToPreviousApp()
            // 模拟键盘输入用户名
            for char in username {
                simulateKeyPress(String(char))
                // 短暂延迟，模拟真实输入
                Thread.sleep(forTimeInterval: 0.01)
            }
            
            // 模拟 Tab 键
            simulateKeyPress("", keyCode: 0x30) // 0x30 是 Tab 键的键码
            
            // 延迟后输入密码
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                for char in password {
                    simulateKeyPress(String(char))
                    Thread.sleep(forTimeInterval: 0.01)
                }
            }
        }
    }
    
    // 切换到上一个应用
    private func switchToPreviousApp() {
        // 使用 Command+Tab 快捷键模拟切换应用
        let source = CGEventSource(stateID: .hidSystemState)
        
        // 按下 Command 键
        let cmdDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true) // 0x37 是 Command 键的键码
        cmdDownEvent?.post(tap: .cghidEventTap)
        
        // 给系统一点时间识别 Command 键被按下
        Thread.sleep(forTimeInterval: 0.05)
        
        // 在按住 Command 的同时按下并松开 Tab 键
        let tabDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x30, keyDown: true) // 0x30 是 Tab 键的键码
        tabDownEvent?.flags = .maskCommand // 确保 Command 键仍然被按下
        tabDownEvent?.post(tap: .cghidEventTap)
        
        Thread.sleep(forTimeInterval: 0.05)
        
        let tabUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x30, keyDown: false)
        tabUpEvent?.flags = .maskCommand // 确保 Command 键仍然被按下
        tabUpEvent?.post(tap: .cghidEventTap)
        
        Thread.sleep(forTimeInterval: 0.05)
        
        // 松开 Command 键
        let cmdUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        cmdUpEvent?.post(tap: .cghidEventTap)
        
        // 给应用切换一点时间
        Thread.sleep(forTimeInterval: 0.3)
    }
    
    // 模拟键盘按键
    private func simulateKeyPress(_ character: String, keyCode: UInt16? = nil) {
        let source = CGEventSource(stateID: .hidSystemState)
        
        if let keyCode = keyCode {
            // 使用特定键码（如回车键）
            let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
            let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
            
            keyDownEvent?.post(tap: .cghidEventTap)
            keyUpEvent?.post(tap: .cghidEventTap)
        } else {
            // 使用字符输入
            for scalar in character.unicodeScalars {
                let keyChar = scalar.value
                
                // 创建键盘事件
                let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
                let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
                
                // 设置Unicode字符
                keyDownEvent?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [UniChar(keyChar)])
                keyDownEvent?.post(tap: .cghidEventTap)
                
                keyUpEvent?.post(tap: .cghidEventTap)
            }
        }
    }

}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PasswordEntry.self, inMemory: true)
}
