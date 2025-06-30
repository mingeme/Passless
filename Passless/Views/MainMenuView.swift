import SwiftUI

struct MainMenuView: View {
    @ObservedObject private var appState = AppState.shared

    var body: some View {
        VStack(spacing: 0) {
            // 头部区域 - 更紧凑的设计
            HeaderView()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            // 搜索栏 - 原生样式
            SearchBarView()
                .padding(.horizontal, 16)
                .padding(.vertical, 6)

            Divider()

            // 账号列表 - 原生列表样式
            AccountListView()
                .frame(minHeight: 200, maxHeight: 350)

            Divider()

            // 底部操作栏
            FooterView()
        }
    }
}
