import Foundation
import SwiftData
import SwiftUI

@Model
final class PasswordEntry: Identifiable {
    @Attribute(.unique) var name: String
    var username: String
    var password: String
    var dateAdded: Date
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
        self.dateAdded = Date()
    }
}
