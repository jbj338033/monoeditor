import Foundation

enum Icons {
    static let folder = "folder"
    static let folderOpen = "folder.fill"
    static let file = "doc"
    static let fileCode = "doc.text"

    static let close = "xmark"
    static let modified = "circle.fill"

    static let newFile = "doc.badge.plus"
    static let newFolder = "folder.badge.plus"
    static let delete = "trash"
    static let rename = "pencil"

    static let search = "magnifyingglass"
    static let settings = "gearshape"
    static let chevronRight = "chevron.right"
    static let chevronDown = "chevron.down"

    static let terminal = "terminal"
    static let sidebar = "sidebar.left"

    static func forFileExtension(_ ext: String) -> String {
        switch ext.lowercased() {
        case "swift":
            return "swift"
        case "js", "mjs", "cjs", "jsx":
            return "js.badge.filled"
        case "ts", "tsx":
            return "t.square"
        case "py":
            return "chevron.left.forwardslash.chevron.right"
        case "rs":
            return "gearshape.2"
        case "html", "htm":
            return "chevron.left.slash.chevron.right"
        case "css", "scss", "sass":
            return "paintbrush"
        case "json":
            return "curlybraces"
        case "md", "markdown":
            return "doc.richtext"
        case "yaml", "yml":
            return "list.bullet.indent"
        case "xml":
            return "chevron.left.slash.chevron.right"
        case "sh", "bash", "zsh":
            return "terminal"
        case "txt":
            return "doc.text"
        case "png", "jpg", "jpeg", "gif", "svg", "webp":
            return "photo"
        default:
            return "doc"
        }
    }
}
