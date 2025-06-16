import SwiftUI
import SwiftData

struct EntryDetailView: View {
    var entry: PasswordEntry
    @State private var currentEntryId: PersistentIdentifier?
    @Environment(\.modelContext) private var modelContext
    @State private var isPasswordVisible = false
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedUsername: String = ""
    @State private var editedPassword: String = ""
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
                    if isEditing {
                        TextField("名称", text: $editedName)
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
                        if isEditing {
                            TextField("用户名", text: $editedUsername)
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
                        if isEditing {
                            TextField("密码", text: $editedPassword)
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
        .onAppear {
            // 初始化当前项目 ID
            currentEntryId = entry.id
        }
        .onChange(of: entry.id) { oldId, newId in
            // 如果项目变化且处于编辑模式，退出编辑模式
            if isEditing {
                isEditing = false
                // 重置编辑字段
                editedName = entry.name
                editedUsername = entry.username
                editedPassword = entry.password
            }
            // 更新当前项目 ID
            currentEntryId = newId
        }
    }
    
    // 开始编辑
    private func startEditing() {
        // 使用字符串变量而不是创建新实体
        editedName = entry.name
        editedUsername = entry.username
        editedPassword = entry.password
        isEditing = true
    }
    
    // 保存更改
    private func saveChanges() {
        // 将编辑的数据应用到原始实体
        entry.name = editedName
        entry.username = editedUsername
        entry.password = editedPassword
        
        // 通知 SwiftData 数据已更改
        try? modelContext.save()
        
        // 退出编辑模式
        isEditing = false
    }
}

#Preview {
    EntryDetailView(entry: PasswordEntry(name: "alipay", username: "10007901020", password: "alipay123"))
        .modelContainer(for: PasswordEntry.self, inMemory: true)
}
