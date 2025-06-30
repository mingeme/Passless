import SwiftUI
import SwiftData

class EditableAccount: ObservableObject, Identifiable {
    let id: UUID
    @Published var index: Int
    @Published var name: String
    @Published var username: String
    @Published var password: String
    
    var originalAccount: PasswordEntry?
    
    private var originalName: String
    private var originalUsername: String
    private var originalPassword: String
    
    init(id: UUID, index: Int, name: String, username: String, password: String, originalAccount: PasswordEntry?) {
        self.id = id
        self.index = index
        self.name = name
        self.username = username
        self.password = password
        self.originalAccount = originalAccount
        
        self.originalName = name
        self.originalUsername = username
        self.originalPassword = password
    }
    
    var hasChanges: Bool {
        return name != originalName || 
               username != originalUsername || 
               password != originalPassword
    }
    
    var isValid: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func markAsSaved() {
        originalName = name
        originalUsername = username
        originalPassword = password
    }
    
    func revert() {
        name = originalName
        username = originalUsername
        password = originalPassword
    }
}
