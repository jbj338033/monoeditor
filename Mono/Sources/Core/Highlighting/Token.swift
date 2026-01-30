import AppKit

enum TokenType: Sendable {
    case comment
    case commentDoc
    case string
    case stringEscape
    case stringInterpolation
    case number
    case boolean
    case `nil`
    case keyword
    case keywordDeclaration
    case keywordControl
    case keywordOperator
    case keywordModifier
    case type
    case function
    case property
    case variable
    case parameter
    case `operator`
    case punctuation
    case delimiter

    case attribute
    case preprocessor

    case tag
    case tagAttribute

    case plain
    case whitespace
    case newline
}

struct Token: Sendable {
    let type: TokenType
    let range: Range<String.Index>

    func nsRange(in string: String) -> NSRange {
        NSRange(range, in: string)
    }
}

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
