import AppKit

// MARK: - Token Type

enum TokenType: Sendable {
    // Comments
    case comment
    case commentDoc

    // Strings
    case string
    case stringEscape
    case stringInterpolation

    // Literals
    case number
    case boolean
    case `nil`

    // Keywords
    case keyword
    case keywordDeclaration  // func, class, struct, etc.
    case keywordControl      // if, else, for, while, etc.
    case keywordOperator     // is, as, in, etc.
    case keywordModifier     // public, private, static, etc.

    // Identifiers
    case type
    case function
    case property
    case variable
    case parameter

    // Operators & Punctuation
    case `operator`
    case punctuation
    case delimiter           // ( ) [ ] { }

    // Preprocessor / Attributes
    case attribute           // @MainActor, @Observable
    case preprocessor        // #if, #endif

    // Markup (HTML, XML)
    case tag
    case tagAttribute

    // Plain text
    case plain
    case whitespace
    case newline
}

// MARK: - Token

struct Token: Sendable {
    let type: TokenType
    let range: Range<String.Index>

    var nsRange: NSRange {
        NSRange(range, in: "")  // Placeholder, actual string needed
    }

    func nsRange(in string: String) -> NSRange {
        NSRange(range, in: string)
    }
}

// MARK: - Token Type Colors

extension TokenType {
    var color: NSColor {
        switch self {
        case .comment, .commentDoc:
            return SyntaxColors.NS.comment
        case .string, .stringEscape, .stringInterpolation:
            return SyntaxColors.NS.string
        case .number:
            return SyntaxColors.NS.number
        case .boolean, .nil:
            return SyntaxColors.NS.keyword
        case .keyword, .keywordDeclaration, .keywordControl, .keywordOperator, .keywordModifier:
            return SyntaxColors.NS.keyword
        case .type:
            return SyntaxColors.NS.type
        case .function:
            return SyntaxColors.NS.function
        case .property, .variable, .parameter:
            return SyntaxColors.NS.property
        case .operator:
            return SyntaxColors.NS.operator
        case .punctuation, .delimiter:
            return SyntaxColors.NS.punctuation
        case .attribute, .preprocessor:
            return SyntaxColors.NS.keyword
        case .tag:
            return SyntaxColors.NS.keyword
        case .tagAttribute:
            return SyntaxColors.NS.property
        case .plain, .whitespace, .newline:
            return SyntaxColors.NS.plain
        }
    }
}
