import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var selectedTab = "general"

    // 动画参数
    private var currentWidth: CGFloat {
        selectedTab == "general" ? 350 : 850
    }

    private var currentHeight: CGFloat {
        selectedTab == "general" ? 220 : 650
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("通用", systemImage: "gearshape")
                }
                .tag("general")

            AccountsSettingsView()
                .tabItem {
                    Label("账号", systemImage: "person.circle")
                }
                .tag("accounts")
        }
        .frame(width: currentWidth, height: currentHeight)
        .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.1), value: selectedTab)
        .onAppear {
            // 确保初始状态正确
            selectedTab = "general"
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: PasswordEntry.self, inMemory: true)
}
