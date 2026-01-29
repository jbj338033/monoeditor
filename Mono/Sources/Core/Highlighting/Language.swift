import Foundation

enum Language: String, CaseIterable, Sendable {
    case swift
    case javascript
    case typescript
    case python
    case rust
    case go
    case java
    case kotlin
    case c
    case cpp
    case csharp
    case ruby
    case php
    case html
    case css
    case scss
    case json
    case yaml
    case xml
    case markdown
    case sql
    case shell
    case dockerfile

    var highlightrName: String {
        switch self {
        case .swift: return "swift"
        case .javascript: return "javascript"
        case .typescript: return "typescript"
        case .python: return "python"
        case .rust: return "rust"
        case .go: return "go"
        case .java: return "java"
        case .kotlin: return "kotlin"
        case .c: return "c"
        case .cpp: return "cpp"
        case .csharp: return "csharp"
        case .ruby: return "ruby"
        case .php: return "php"
        case .html: return "xml"
        case .css: return "css"
        case .scss: return "scss"
        case .json: return "json"
        case .yaml: return "yaml"
        case .xml: return "xml"
        case .markdown: return "markdown"
        case .sql: return "sql"
        case .shell: return "bash"
        case .dockerfile: return "dockerfile"
        }
    }

    static func from(extension ext: String) -> Language? {
        switch ext.lowercased() {
        case "swift": return .swift
        case "js", "mjs", "cjs", "jsx": return .javascript
        case "ts", "tsx": return .typescript
        case "py", "pyw": return .python
        case "rs": return .rust
        case "go": return .go
        case "java": return .java
        case "kt", "kts": return .kotlin
        case "c", "h": return .c
        case "cpp", "cc", "cxx", "hpp", "hxx": return .cpp
        case "cs": return .csharp
        case "rb": return .ruby
        case "php": return .php
        case "html", "htm": return .html
        case "css": return .css
        case "scss", "sass": return .scss
        case "json": return .json
        case "yaml", "yml": return .yaml
        case "xml", "plist": return .xml
        case "md", "markdown": return .markdown
        case "sql": return .sql
        case "sh", "bash", "zsh": return .shell
        case "dockerfile": return .dockerfile
        default: return nil
        }
    }
}
