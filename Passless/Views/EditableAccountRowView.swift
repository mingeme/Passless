import SwiftUI
import SwiftData

struct EditableAccountRowView: View {
    @ObservedObject var account: EditableAccount
    let isSelected: Bool
    let onSave: (EditableAccount) -> Void

    var body: some View {
        HStack(spacing: 0) {
            // 序号
            Text("\(account.index)")
                .font(.system(size: 13))
                .foregroundColor(Color.secondary)
                .frame(width: 50, alignment: .center)
                .padding(.vertical, 8)

            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)

            // 名称
            TextField("名称", text: $account.name)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onChange(of: account.name) { _, _ in
                    onSave(account)
                }

            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)

            // 用户名
            TextField("用户名", text: $account.username)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onChange(of: account.username) { _, _ in
                    onSave(account)
                }

            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)

            // 密码 (纯文本显示)
            TextField("密码", text: $account.password)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onChange(of: account.password) { _, _ in
                    onSave(account)
                }
        }
        .background(
            Rectangle()
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        )
    }
}

#Preview {
    let account = EditableAccount(
        id: UUID(),
        index: 1,
        name: "测试账号",
        username: "test@example.com",
        password: "password123",
        originalAccount: nil
    )

    EditableAccountRowView(account: account, isSelected: true, onSave: { _ in })
        .frame(width: 800, height: 50)
}
