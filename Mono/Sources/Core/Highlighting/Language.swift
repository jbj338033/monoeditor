import Foundation

enum Language: String, CaseIterable, Sendable {
    case swift
    case javascript
    case typescript
    case python
    case rust
    case html
    case css
    case json
    case markdown

    static func from(extension ext: String) -> Language? {
        switch ext.lowercased() {
        case "swift": return .swift
        case "js", "mjs", "cjs", "jsx": return .javascript
        case "ts", "tsx": return .typescript
        case "py": return .python
        case "rs": return .rust
        case "html", "htm": return .html
        case "css", "scss": return .css
        case "json": return .json
        case "md", "markdown": return .markdown
        default: return nil
        }
    }
}
