import Foundation

struct EditorTab: Identifiable, Hashable {
    let id: UUID
    let url: URL
    var isModified: Bool
    var content: String

    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.isModified = false
        self.content = ""
    }

    var name: String {
        url.lastPathComponent
    }

    var fileExtension: String {
        url.pathExtension
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: EditorTab, rhs: EditorTab) -> Bool {
        lhs.id == rhs.id
    }
}
