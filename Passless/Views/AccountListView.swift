import SwiftUI
import SwiftData

struct AccountListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [PasswordEntry]
    @ObservedObject private var appState = AppState.shared
    
    private var filteredEntries: [PasswordEntry] {
        if appState.searchText.isEmpty {
            return allEntries.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } else {
            return allEntries.filter { entry in
                entry.name.localizedCaseInsensitiveContains(appState.searchText) ||
                entry.username.localizedCaseInsensitiveContains(appState.searchText)
            }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }
    
    var body: some View {
        if filteredEntries.isEmpty {
            VStack(spacing: 12) {
                if appState.searchText.isEmpty {
                    Image(systemName: "key.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(NSColor.placeholderTextColor))

                    VStack(spacing: 4) {
                        Text("暂无账号")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(NSColor.controlTextColor))

                        Text("点击设置添加第一个账号")
                            .font(.system(size: 12))
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                    }
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(Color(NSColor.placeholderTextColor))

                    VStack(spacing: 4) {
                        Text("未找到匹配的账号")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(NSColor.controlTextColor))

                        Text("尝试使用其他关键词搜索")
                            .font(.system(size: 12))
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredEntries) { entry in
                        AccountRowView(entry: entry)

                        // 添加分隔线，除了最后一个项目
                        if entry.id != filteredEntries.last?.id {
                            Rectangle()
                                .fill(Color(NSColor.separatorColor))
                                .frame(height: 1)
                                .padding(.leading, 16)
                        }
                    }
                }
                .padding(.top, 1)
            }
        }
    }
}



#Preview {
    AccountListView()
        .modelContainer(for: PasswordEntry.self, inMemory: true)
        .frame(width: 280, height: 300)
}
