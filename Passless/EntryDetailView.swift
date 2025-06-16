import SwiftUI
import SwiftData

struct EntryDetailView: View {
    var entry: PasswordEntry
    @Environment(\.modelContext) private var modelContext
    @State private var isPasswordVisible = false
    @State private var isEditing = false
    @State private var editedEntry: PasswordEntry? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // 编辑按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if isEditing {
                            saveChanges()
                        } else {
                            startEditing()
                        }
                    }) {
                        Text(isEditing ? "完成" : "编辑")
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                Spacer()
            }
            .zIndex(1)
            // 背景颜色
            (colorScheme == .dark ? Color.black : Color(white: 0.95))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部图标和标题区域
                VStack(spacing: 16) {
                    // 图标
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(16)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 2)
                    
                    // 网站/应用名称
                    if isEditing, let editedEntry = editedEntry {
                        TextField("名称", text: Binding(get: { editedEntry.name }, set: { self.editedEntry?.name = $0 }))
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .background(Color.clear)
                    } else {
                        Text(entry.name)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    // 上次修改时间
                    Text("上次修改时间：\(entry.dateAdded.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(colorScheme == .dark ? Color.black : Color.white)
                
                // 详细信息区域
                VStack(spacing: 0) {
                    // 用户名行
                    HStack {
                        Text("用户名")
                            .foregroundColor(.secondary)
                        Spacer()
                        if isEditing, let editedEntry = editedEntry {
                            TextField("用户名", text: Binding(get: { editedEntry.username }, set: { self.editedEntry?.username = $0 }))
                                .multilineTextAlignment(.trailing)
                                .fontWeight(.medium)
                                .textFieldStyle(.plain)
                                .background(Color.clear)
                        } else {
                            Text(entry.username)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.1) : Color.white)
                    Divider()
                    
                    // 密码行
                    HStack {
                        Text("密码")
                            .foregroundColor(.secondary)
                        Spacer()
                        if isEditing, let editedEntry = editedEntry {
                            TextField("密码", text: Binding(get: { editedEntry.password }, set: { self.editedEntry?.password = $0 }))
                                .multilineTextAlignment(.trailing)
                                .fontWeight(.medium)
                                .textFieldStyle(.plain)
                                .background(Color.clear)
                        } else {
                            Text(isPasswordVisible ? entry.password : "••••••••")
                                .fontWeight(.medium)
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.1) : Color.white)
                    Divider()
                    
                    // 网站行
                    HStack {
                        Text("网站")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(entry.name.lowercased().contains(".com") ? entry.name : "\(entry.name.lowercased()).com")
                            .fontWeight(.medium)
                    }
                    .opacity(isEditing ? 0.5 : 1) // 编辑时稍微淡化网站行
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.1) : Color.white)
                }
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
        }
    }
    
    // 开始编辑
    private func startEditing() {
        // 创建一个副本用于编辑
        editedEntry = PasswordEntry(name: entry.name, username: entry.username, password: entry.password)
        isEditing = true
    }
    
    // 保存更改
    private func saveChanges() {
        // 将编辑的数据应用到原始实体
        if let editedEntry = editedEntry {
            entry.name = editedEntry.name
            entry.username = editedEntry.username
            entry.password = editedEntry.password
            
            // 通知 SwiftData 数据已更改
            try? modelContext.save()
        }
        
        // 退出编辑模式
        editedEntry = nil
        isEditing = false
    }
}

#Preview {
    EntryDetailView(entry: PasswordEntry(name: "alipay", username: "10007901020", password: "alipay123"))
        .modelContainer(for: PasswordEntry.self, inMemory: true)
}
