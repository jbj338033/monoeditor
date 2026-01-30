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

    var displayName: String {
        switch self {
        case .swift: "Swift"
        case .javascript: "JavaScript"
        case .typescript: "TypeScript"
        case .python: "Python"
        case .rust: "Rust"
        case .go: "Go"
        case .java: "Java"
        case .kotlin: "Kotlin"
        case .c: "C"
        case .cpp: "C++"
        case .csharp: "C#"
        case .ruby: "Ruby"
        case .php: "PHP"
        case .html: "HTML"
        case .css: "CSS"
        case .scss: "SCSS"
        case .json: "JSON"
        case .yaml: "YAML"
        case .xml: "XML"
        case .markdown: "Markdown"
        case .sql: "SQL"
        case .shell: "Shell"
        case .dockerfile: "Dockerfile"
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
