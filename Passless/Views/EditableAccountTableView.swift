import SwiftUI
import SwiftData

struct EditableAccountTableView: View {
    @Binding var editingAccounts: [EditableAccount]
    let onDelete: (EditableAccount) -> Void
    let onAdd: () -> Void
    let onSave: (EditableAccount) -> Void

    @State private var selectedAccountId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // 表格内容
            if editingAccounts.isEmpty {
                // 空状态
                VStack(spacing: 16) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 48))
                        .foregroundColor(Color.secondary)

                    Text("暂无账号")
                        .font(.title2)
                        .foregroundColor(Color.primary)

                    Text("点击下方 + 按钮添加您的第一个账号")
                        .font(.body)
                        .foregroundColor(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 200)
            } else {
                // 表格列表 - 全边框设计
                VStack(spacing: 0) {
                    // 表头
                    HStack(spacing: 0) {
                        Text("序号")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.secondary)
                            .frame(width: 50, alignment: .center)

                        Rectangle()
                            .fill(Color(NSColor.separatorColor))
                            .frame(width: 1)

                        Text("名称")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.secondary)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Rectangle()
                            .fill(Color(NSColor.separatorColor))
                            .frame(width: 1)

                        Text("用户名")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.secondary)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Rectangle()
                            .fill(Color(NSColor.separatorColor))
                            .frame(width: 1)

                        Text("密码")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.secondary)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 32)
                    .overlay(
                        Rectangle()
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )

                    // 表格内容
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(editingAccounts) { account in
                                EditableAccountRowView(
                                    account: account,
                                    isSelected: selectedAccountId == account.id,
                                    onSave: onSave
                                )
                                .onTapGesture {
                                    if selectedAccountId == account.id {
                                        selectedAccountId = nil
                                    } else {
                                        selectedAccountId = account.id
                                    }
                                }

                                if account.id != editingAccounts.last?.id {
                                    Rectangle()
                                        .fill(Color(NSColor.separatorColor))
                                        .frame(height: 1)
                                        .background(Color(NSColor.textBackgroundColor))
                                }
                            }
                        }
                    }
                }
                .overlay(
                    Rectangle()
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
            }

            // 底部操作栏
            HStack {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 20, height: 20)

                Button(action: {
                    handleMinusButtonTap()
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(editingAccounts.isEmpty ? Color.secondary : Color.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 20, height: 20)
                .disabled(editingAccounts.isEmpty)

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .border(Color(NSColor.separatorColor), width: 1)
        }
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }

    private func handleMinusButtonTap() {
        if let selectedId = selectedAccountId,
           let selectedAccount = editingAccounts.first(where: { $0.id == selectedId }) {
            // 如果已选中，则删除
            onDelete(selectedAccount)
            selectedAccountId = nil
        } else if let firstAccount = editingAccounts.first {
            // 如果没有选中项，选中第一项
            selectedAccountId = firstAccount.id
        }
    }
}

#Preview {
    @Previewable @State var accounts: [EditableAccount] = [
        EditableAccount(id: UUID(), index: 1, name: "测试账号", username: "test@example.com", password: "password123", originalAccount: nil)
    ]

    EditableAccountTableView(
        editingAccounts: $accounts,
        onDelete: { _ in },
        onAdd: { },
        onSave: { _ in }
    )
    .frame(width: 800, height: 400)
}
