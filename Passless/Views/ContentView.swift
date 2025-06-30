import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject private var appState = AppState.shared

    var body: some View {
        VStack(spacing: 0) {
            // 主视图
            MainMenuView()
        }
        .frame(width: 300)
        .background(Color.clear)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PasswordEntry.self, inMemory: true)
}
