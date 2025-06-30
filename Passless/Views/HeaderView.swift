import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Passless")
                .font(.system(size: 14, weight: .semibold))
            Spacer()

            Text("密码管理器")
                .font(.system(size: 11))
        }
    }
}
