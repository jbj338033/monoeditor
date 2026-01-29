import Foundation
import Observation

@Observable
final class FileItem: Identifiable {
    let id: UUID
    let url: URL
    let isDirectory: Bool
    var isExpanded: Bool
    var children: [FileItem]?

    init(url: URL, isDirectory: Bool) {
        self.id = UUID()
        self.url = url
        self.isDirectory = isDirectory
        self.isExpanded = false
        self.children = nil
    }

    var name: String {
        url.lastPathComponent
    }

    var fileExtension: String {
        url.pathExtension
    }

    var icon: String {
        if isDirectory {
            return isExpanded ? Icons.folderOpen : Icons.folder
        }
        return Icons.forFileExtension(fileExtension)
    }
}
