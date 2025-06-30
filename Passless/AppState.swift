import SwiftUI
import SwiftData
import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var searchText: String = ""

    static let shared = AppState()

    private init() {}

    func clearSearch() {
        searchText = ""
    }
}
