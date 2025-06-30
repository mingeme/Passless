import SwiftUI
import SwiftData

struct AccountRowView: View {
    let entry: PasswordEntry
    @State private var isHovered = false
    @State private var showingInputOptions = false
    @ObservedObject private var pasteService = PasteService.shared

    var body: some View {
        Button(action: {
            pasteService.pasteCredentials(username: entry.username, password: entry.password)
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.name)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(entry.username)
                        .font(.system(size: 11))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
        .background(
            Rectangle()
                .fill(isHovered ? Color.accentColor.opacity(0.8) : Color.clear)
        )
        .onHover { hover in
            isHovered = hover
        }
        .contextMenu {
            Button("仅复制用户名") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(entry.username, forType: .string)
                NotificationCenter.default.post(name: .closeStatusMenu, object: nil)
            }

            Button("仅复制密码") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(entry.password, forType: .string)
                NotificationCenter.default.post(name: .closeStatusMenu, object: nil)
            }
        }
    }
}

#Preview {
    AccountRowView(entry: PasswordEntry(name: "示例账号", username: "user@example.com", password: "password123"))
        .padding()
}
