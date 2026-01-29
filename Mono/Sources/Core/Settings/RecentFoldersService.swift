import Foundation
import Observation

@MainActor
@Observable
final class RecentFoldersService {
    private(set) var folders: [URL] = []

    private let userDefaultsKey = "recentFolders"
    private let maxRecentFolders = 5

    func load() {
        let bookmarks = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Data] ?? []
        folders = bookmarks.compactMap { data in
            var isStale = false
            return try? URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
        }
    }

    func add(_ url: URL) {
        var updatedFolders = folders
        updatedFolders.removeAll { $0 == url }
        updatedFolders.insert(url, at: 0)
        updatedFolders = Array(updatedFolders.prefix(maxRecentFolders))

        let bookmarks = updatedFolders.compactMap { folder in
            try? folder.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        }

        UserDefaults.standard.set(bookmarks, forKey: userDefaultsKey)
        folders = updatedFolders
    }
}
