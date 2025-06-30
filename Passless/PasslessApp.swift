import SwiftUI
import SwiftData
import AppKit

@main
struct PasslessApp: App {
    @State private var statusBarController: StatusBarController?
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var appState = AppState.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PasswordEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()



    var body: some Scene {
        // 纯菜单栏应用 - 完全通过 StatusBarController 管理，无需任何 Scene
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
    }
    

}

// 扩展通知名称
extension Notification.Name {
    static let closeStatusMenu = Notification.Name("closeStatusMenu")
}
