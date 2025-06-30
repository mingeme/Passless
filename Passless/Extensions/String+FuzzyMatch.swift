import Foundation

extension String {
    func fuzzyMatch(_ searchTerm: String) -> Bool {
        if searchTerm.isEmpty { return true }
        var searchIndex = searchTerm.startIndex
        let selfLowercased = self.lowercased()
        let searchTermLowercased = searchTerm.lowercased()

        for char in selfLowercased {
            if searchIndex == searchTermLowercased.endIndex {
                return true
            }
            if char == searchTermLowercased[searchIndex] {
                searchIndex = searchTermLowercased.index(after: searchIndex)
            }
        }

        return searchIndex == searchTermLowercased.endIndex
    }
}
