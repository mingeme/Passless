import SwiftUI

struct SearchBarView: View {
    @ObservedObject private var appState = AppState.shared
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))

            TextField("搜索账号...", text: $appState.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))

            if !appState.searchText.isEmpty {
                Button(action: {
                    appState.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .opacity(0.7)
                .onHover { isHovered in
                    // 可以添加悬停效果
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                .background(Color.secondary)
                .opacity(0.1)
        )
        .cornerRadius(5)
    }
}
