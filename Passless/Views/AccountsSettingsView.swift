import SwiftUI
import SwiftData

struct AccountsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [PasswordEntry]
    @State private var editingAccounts: [EditableAccount] = []
    @State private var isAddingNew = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 表格
            EditableAccountTableView(
                editingAccounts: $editingAccounts,
                onDelete: deleteAccount,
                onAdd: addNewAccount,
                onSave: saveAccount
            )
            .padding()
        }
        .onAppear {
            loadEditingAccounts()
        }
        .onChange(of: accounts) { _, _ in
            loadEditingAccounts()
        }
    }
    
    private var hasUnsavedChanges: Bool {
        editingAccounts.contains { $0.hasChanges }
    }
    
    private func loadEditingAccounts() {
        editingAccounts = accounts.enumerated().map { index, account in
            EditableAccount(
                id: UUID(),
                index: index + 1,
                name: account.name,
                username: account.username,
                password: account.password,
                originalAccount: account
            )
        }
    }
    
    private func addNewAccount() {
        let newAccount = EditableAccount(
            id: UUID(),
            index: editingAccounts.count + 1,
            name: "新账号",
            username: "",
            password: "",
            originalAccount: nil
        )
        editingAccounts.insert(newAccount, at: 0)

        // 重新编号
        for i in 0..<editingAccounts.count {
            editingAccounts[i].index = i + 1
        }

        // 立即保存新账号到数据库
        saveAccount(newAccount)
    }
    
    private func deleteAccount(_ account: EditableAccount) {
        if let originalAccount = account.originalAccount {
            modelContext.delete(originalAccount)
            try? modelContext.save()
        }
        
        if let index = editingAccounts.firstIndex(where: { $0.id == account.id }) {
            editingAccounts.remove(at: index)
            
            // 重新编号
            for i in 0..<editingAccounts.count {
                editingAccounts[i].index = i + 1
            }
        }
    }
    
    private func saveAccount(_ account: EditableAccount) {
        // 只有当账号有基本信息时才保存
        guard !account.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        if let originalAccount = account.originalAccount {
            // 更新现有账号
            originalAccount.name = account.name
            originalAccount.username = account.username
            originalAccount.password = account.password
        } else {
            // 创建新账号
            let newEntry = PasswordEntry(
                name: account.name,
                username: account.username,
                password: account.password
            )
            modelContext.insert(newEntry)
            account.originalAccount = newEntry
        }

        account.markAsSaved()
        try? modelContext.save()
    }
    
    private func saveAllChanges() {
        for account in editingAccounts where account.hasChanges {
            saveAccount(account)
        }
    }
}

#Preview {
    AccountsSettingsView()
        .modelContainer(for: PasswordEntry.self, inMemory: true)
}
