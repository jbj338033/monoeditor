import Foundation

enum MarkdownLang: LanguageDefinition {
    static let id: Language = .markdown
    static let extensions: Set<String> = ["md", "markdown"]

    static func tokenize(_ source: String) -> [Token] {
        MarkdownLexer(source: source).tokenize()
    }
}

final class MarkdownLexer: @unchecked Sendable {
    private let source: String
    private var index: String.Index
    private var tokens: [Token] = []

    init(source: String) {
        self.source = source
        self.index = source.startIndex
    }

    func tokenize() -> [Token] {
        tokens = []
        index = source.startIndex

        while index < source.endIndex {
            tokens.append(nextToken())
        }

        return tokens
    }

    private func nextToken() -> Token {
        let start = index
        let char = source[index]

        if char.isWhitespace && !char.isNewline {
            return consumeWhitespace(from: start)
        }

        if char.isNewline {
            advance()
            return Token(type: .newline, range: start..<index)
        }

        let isLineStart = start == source.startIndex || source[source.index(before: start)].isNewline

        if char == "#" && isLineStart {
            return consumeHeader(from: start)
        }

        if char == "`" && isLookingAt("```") {
            return consumeCodeBlock(from: start)
        }

        if char == "`" {
            return consumeInlineCode(from: start)
        }

        if (char == "*" && isLookingAt("**")) || (char == "_" && isLookingAt("__")) {
            return consumeBold(from: start, marker: char)
        }

        if char == "*" || char == "_" {
            return consumeItalic(from: start, marker: char)
        }

        if char == "[" || (char == "!" && peek() == "[") {
            return consumeLink(from: start)
        }

        if char == ">" && isLineStart {
            return consumeBlockQuote(from: start)
        }

        if (char == "-" || char == "*" || char == "+") && isLineStart {
            if let next = peek(), next.isWhitespace {
                return consumeListMarker(from: start)
            }
        }

        if char.isNumber && isLineStart {
            return consumeNumberedList(from: start)
        }

        if (char == "-" || char == "*" || char == "_") && isLineStart {
            if isHorizontalRule() {
                return consumeHorizontalRule(from: start)
            }
        }

        return consumePlainText(from: start)
    }

    private func consumeWhitespace(from start: String.Index) -> Token {
        while index < source.endIndex && source[index].isWhitespace && !source[index].isNewline {
            advance()
        }
        return Token(type: .whitespace, range: start..<index)
    }

    private func consumeHeader(from start: String.Index) -> Token {
        while index < source.endIndex && source[index] == "#" {
            advance()
        }
        while index < source.endIndex && !source[index].isNewline {
            advance()
        }
        return Token(type: .keywordDeclaration, range: start..<index)
    }

    private func consumeCodeBlock(from start: String.Index) -> Token {
        advance(); advance(); advance()
        while index < source.endIndex && !source[index].isNewline {
            advance()
        }
        while index < source.endIndex {
            if source[index].isNewline {
                advance()
                if isLookingAt("```") {
                    advance(); advance(); advance()
                    break
                }
            } else {
                advance()
            }
        }
        return Token(type: .string, range: start..<index)
    }

    private func consumeInlineCode(from start: String.Index) -> Token {
        advance()
        while index < source.endIndex && source[index] != "`" && !source[index].isNewline {
            advance()
        }
        if index < source.endIndex && source[index] == "`" {
            advance()
        }
        return Token(type: .string, range: start..<index)
    }

    private func consumeBold(from start: String.Index, marker: Character) -> Token {
        advance(); advance()
        while index < source.endIndex {
            if source[index] == marker && peek() == marker {
                advance(); advance()
                break
            }
            if source[index].isNewline { break }
            advance()
        }
        return Token(type: .keywordModifier, range: start..<index)
    }

    private func consumeItalic(from start: String.Index, marker: Character) -> Token {
        advance()
        while index < source.endIndex {
            if source[index] == marker {
                advance()
                break
            }
            if source[index].isNewline { break }
            advance()
        }
        return Token(type: .keyword, range: start..<index)
    }

    private func consumeLink(from start: String.Index) -> Token {
        if source[index] == "!" { advance() }
        advance()
        while index < source.endIndex && source[index] != "]" && !source[index].isNewline {
            advance()
        }
        if index < source.endIndex && source[index] == "]" { advance() }
        if index < source.endIndex && source[index] == "(" {
            advance()
            while index < source.endIndex && source[index] != ")" && !source[index].isNewline {
                advance()
            }
            if index < source.endIndex && source[index] == ")" { advance() }
        }
        return Token(type: .function, range: start..<index)
    }

    private func consumeBlockQuote(from start: String.Index) -> Token {
        while index < source.endIndex && !source[index].isNewline {
            advance()
        }
        return Token(type: .comment, range: start..<index)
    }

    private func consumeListMarker(from start: String.Index) -> Token {
        advance()
        return Token(type: .keywordControl, range: start..<index)
    }

    private func consumeNumberedList(from start: String.Index) -> Token {
        while index < source.endIndex && source[index].isNumber {
            advance()
        }
        if index < source.endIndex && source[index] == "." {
            advance()
            return Token(type: .keywordControl, range: start..<index)
        }
        index = start
        return consumePlainText(from: start)
    }

    private func isHorizontalRule() -> Bool {
        var count = 0
        var i = index
        while i < source.endIndex && !source[i].isNewline {
            if source[i] == "-" || source[i] == "*" || source[i] == "_" {
                count += 1
            } else if !source[i].isWhitespace {
                return false
            }
            i = source.index(after: i)
        }
        return count >= 3
    }

    private func consumeHorizontalRule(from start: String.Index) -> Token {
        while index < source.endIndex && !source[index].isNewline {
            advance()
        }
        return Token(type: .comment, range: start..<index)
    }

    private func consumePlainText(from start: String.Index) -> Token {
        while index < source.endIndex {
            let char = source[index]
            if char.isNewline || char == "#" || char == "`" || char == "*" ||
               char == "_" || char == "[" || char == "!" || char == ">" {
                break
            }
            advance()
        }
        if start == index { advance() }
        return Token(type: .plain, range: start..<index)
    }

    private func advance() {
        if index < source.endIndex {
            index = source.index(after: index)
        }
    }

    private func peek() -> Character? {
        let next = source.index(after: index)
        return next < source.endIndex ? source[next] : nil
    }

    private func isLookingAt(_ str: String) -> Bool {
        guard let end = source.index(index, offsetBy: str.count, limitedBy: source.endIndex) else {
            return false
        }
        return source[index..<end] == str
    }
}
