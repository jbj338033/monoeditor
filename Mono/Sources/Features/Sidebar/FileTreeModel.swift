import Foundation
import Observation

@MainActor
@Observable
final class FileTreeModel {
    let rootURL: URL
    var rootItems: [FileItem] = []

    init(rootURL: URL) {
        self.rootURL = rootURL
    }

    func loadRoot() async {
        rootItems = await loadContents(of: rootURL)
    }

    func toggleExpansion(_ item: FileItem) async {
        guard item.isDirectory else { return }

        if item.isExpanded {
            item.isExpanded = false
            item.children = nil
        } else {
            item.children = await loadContents(of: item.url)
            item.isExpanded = true
        }
    }

    private func loadContents(of url: URL) async -> [FileItem] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        let items = contents.compactMap { fileURL -> FileItem? in
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey]),
                  let isDirectory = resourceValues.isDirectory else {
                return nil
            }
            return FileItem(url: fileURL, isDirectory: isDirectory)
        }

        return items.sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return lhs.isDirectory
            }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }
}
