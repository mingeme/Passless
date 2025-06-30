import SwiftUI

struct GeneralSettingsView: View {
    @State private var launchAtLogin = LaunchAtLoginManager.shared.isEnabled

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 启动设置
            VStack(alignment: .leading, spacing: 8) {
                Toggle("登录时启动", isOn: $launchAtLogin)
                    .font(.system(size: 13))
                    .onChange(of: launchAtLogin) { _, newValue in
                        LaunchAtLoginManager.shared.isEnabled = newValue
                    }
            }

            Divider()

            // 关于信息
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("版本:")
                        .font(.system(size: 13))
                        .foregroundColor(Color.primary)
                    Text(appVersion)
                        .font(.system(size: 13))
                        .foregroundColor(Color.secondary)
                    Spacer()
                }
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            launchAtLogin = LaunchAtLoginManager.shared.isEnabled
        }
    }
}

#Preview {
    GeneralSettingsView()
}
