import SwiftUI
import SwiftData

struct AddEntryView: View {
    var onSave: (() -> Void)? = nil
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    
    
    var body: some View {
        ZStack {
            // 背景颜色
            (colorScheme == .dark ? Color.black : Color(white: 0.95))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部图标和标题区域
                VStack(spacing: 16) {
                    // 图标
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(16)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 2)
                    
                    // 标题
                    Text("新建密码")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(colorScheme == .dark ? Color.black : Color.white)
                
                // 详细信息区域
                VStack(spacing: 0) {
                    // 网站或标签输入区
                    HStack {
                        Text("网站或标签")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("", text: $name)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.plain)
                            .background(Color.clear)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.1) : Color.white)
                    Divider()
                    
                    // 用户名输入区
                    HStack {
                        Text("用户名")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("用户", text: $username)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.plain)
                            .background(Color.clear)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.1) : Color.white)
                    Divider()
                    
                    // 密码输入区
                    HStack {
                        Text("密码")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("密码", text: $password)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.plain)
                            .background(Color.clear)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.1) : Color.white)                    
                }
                .cornerRadius(10)
                .padding()
                
                Divider()
                
                // 底部按钮
                HStack(spacing: 20) {
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("取消").padding(.horizontal)
                    }
                    .cornerRadius(6)
                    
                    Button {
                        saveEntry()
                    } label: {
                        Text("存储").padding(.horizontal)
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .disabled(name.isEmpty || username.isEmpty || password.isEmpty)
                }
                .padding(.vertical, 20)
            }
            .frame(minWidth: 400, minHeight: 300)
        }
    }
    
    private func saveEntry() {
        let newEntry = PasswordEntry(
            name: name,
            username: username,
            password: password
        )
        
        modelContext.insert(newEntry)
        onSave?()
        dismiss()
    }
}

#Preview {
    VStack {
        AddEntryView()
            .modelContainer(for: PasswordEntry.self, inMemory: true)
    }.frame(minHeight: 500)
}
