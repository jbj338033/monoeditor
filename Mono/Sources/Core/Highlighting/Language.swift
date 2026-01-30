import Foundation

enum Language: String, CaseIterable, Sendable {
    case plainText
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

    var lineCommentPrefix: String? {
        switch self {
        case .swift, .javascript, .typescript, .rust, .go, .java, .kotlin,
             .c, .cpp, .csharp, .php, .scss, .sql:
            return "//"
        case .python, .ruby, .shell, .yaml:
            return "#"
        case .plainText, .html, .xml, .markdown, .css, .json, .dockerfile:
            return nil
        }
    }

    var displayName: String {
        switch self {
        case .plainText: "Plain Text"
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
        case "ts", "tsx", "mts", "cts": return .typescript
        case "py", "pyw", "pyi": return .python
        case "rs": return .rust
        case "go": return .go
        case "java": return .java
        case "kt", "kts": return .kotlin
        case "c", "h": return .c
        case "cpp", "cc", "cxx", "hpp", "hxx", "c++", "h++", "hh": return .cpp
        case "cs": return .csharp
        case "rb", "rake", "gemspec": return .ruby
        case "php", "phtml", "php3", "php4", "php5", "php7", "phps": return .php
        case "html", "htm", "xhtml": return .html
        case "css": return .css
        case "scss", "sass", "less": return .scss
        case "json", "jsonc", "json5": return .json
        case "yaml", "yml": return .yaml
        case "xml", "plist", "svg", "xsl", "xslt": return .xml
        case "md", "markdown", "mdown", "mkd": return .markdown
        case "sql", "mysql", "pgsql", "sqlite": return .sql
        case "sh", "bash", "zsh", "fish", "ksh", "csh", "tcsh": return .shell
        case "dockerfile": return .dockerfile
        case "txt", "text", "log": return .plainText
        default: return nil
        }
    }
}
