import Foundation

final class KeywordLexer: @unchecked Sendable {
    private let source: String
    private let keywords: LanguageKeywords
    private let options: LanguageOptions
    private var index: String.Index
    private var tokens: [Token] = []

    init(source: String, keywords: LanguageKeywords, options: LanguageOptions) {
        self.source = source
        self.keywords = keywords
        self.options = options
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

        if char == "/" && peek() == "/" {
            return consumeLineComment(from: start)
        }

        if char == "/" && peek() == "*" {
            return consumeBlockComment(from: start)
        }

        if options.hashComments && char == "#" && !isPreprocessorDirective() {
            return consumeLineComment(from: start)
        }

        if options.htmlComments && char == "<" && isLookingAt("<!--") {
            return consumeHTMLComment(from: start)
        }

        if char == "\"" {
            if options.multilineStrings && isLookingAt("\"\"\"") {
                return consumeMultilineString(from: start)
            }
            return consumeString(from: start, quote: "\"")
        }

        if char == "'" && options.singleQuoteStrings {
            return consumeString(from: start, quote: "'")
        }

        if char == "`" && options.backtickStrings {
            return consumeString(from: start, quote: "`")
        }

        if char.isNumber || (char == "." && peek()?.isNumber == true) {
            return consumeNumber(from: start)
        }

        if char == "@" && options.attributes {
            return consumeAttribute(from: start)
        }

        if char == "#" && options.preprocessor {
            return consumePreprocessor(from: start)
        }

        if char.isLetter || char == "_" {
            return consumeIdentifier(from: start)
        }

        if options.operatorChars.contains(char) {
            return consumeOperator(from: start)
        }

        if "()[]{}".contains(char) {
            advance()
            return Token(type: .delimiter, range: start..<index)
        }

        if ",.;:".contains(char) {
            advance()
            return Token(type: .punctuation, range: start..<index)
        }

        advance()
        return Token(type: .plain, range: start..<index)
    }

    private func consumeWhitespace(from start: String.Index) -> Token {
        while index < source.endIndex && source[index].isWhitespace && !source[index].isNewline {
            advance()
        }
        return Token(type: .whitespace, range: start..<index)
    }

    private func consumeLineComment(from start: String.Index) -> Token {
        while index < source.endIndex && !source[index].isNewline {
            advance()
        }
        return Token(type: .comment, range: start..<index)
    }

    private func consumeBlockComment(from start: String.Index) -> Token {
        advance(); advance()
        while index < source.endIndex {
            if source[index] == "*" && peek() == "/" {
                advance(); advance()
                break
            }
            advance()
        }
        return Token(type: .comment, range: start..<index)
    }

    private func consumeHTMLComment(from start: String.Index) -> Token {
        advance(); advance(); advance(); advance()
        while index < source.endIndex {
            if source[index] == "-" && isLookingAt("-->") {
                advance(); advance(); advance()
                break
            }
            advance()
        }
        return Token(type: .comment, range: start..<index)
    }

    private func consumeString(from start: String.Index, quote: Character) -> Token {
        advance()
        while index < source.endIndex {
            let char = source[index]
            if char == "\\" {
                advance()
                if index < source.endIndex { advance() }
                continue
            }
            if char == quote {
                advance()
                break
            }
            if char.isNewline { break }
            advance()
        }
        return Token(type: .string, range: start..<index)
    }

    private func consumeMultilineString(from start: String.Index) -> Token {
        advance(); advance(); advance()
        while index < source.endIndex {
            if source[index] == "\\" {
                advance()
                if index < source.endIndex { advance() }
                continue
            }
            if source[index] == "\"" && isLookingAt("\"\"\"") {
                advance(); advance(); advance()
                break
            }
            advance()
        }
        return Token(type: .string, range: start..<index)
    }

    private func consumeNumber(from start: String.Index) -> Token {
        if source[index] == "0" {
            advance()
            if index < source.endIndex {
                let next = source[index]
                if next == "x" || next == "X" {
                    advance()
                    while index < source.endIndex && (source[index].isHexDigit || source[index] == "_") {
                        advance()
                    }
                    return Token(type: .number, range: start..<index)
                }
                if next == "b" || next == "B" {
                    advance()
                    while index < source.endIndex && "01_".contains(source[index]) {
                        advance()
                    }
                    return Token(type: .number, range: start..<index)
                }
            }
        }

        var hasDecimal = false
        while index < source.endIndex {
            let c = source[index]
            if c.isNumber || c == "_" {
                advance()
            } else if c == "." && !hasDecimal && peek()?.isNumber == true {
                hasDecimal = true
                advance()
            } else if c == "e" || c == "E" {
                advance()
                if index < source.endIndex && "+-".contains(source[index]) {
                    advance()
                }
            } else {
                break
            }
        }
        return Token(type: .number, range: start..<index)
    }

    private func consumeIdentifier(from start: String.Index) -> Token {
        while index < source.endIndex {
            let char = source[index]
            if char.isLetter || char.isNumber || char == "_" {
                advance()
            } else {
                break
            }
        }

        let word = String(source[start..<index])
        let type = classifyWord(word)
        return Token(type: type, range: start..<index)
    }

    private func classifyWord(_ word: String) -> TokenType {
        if keywords.declaration.contains(word) { return .keywordDeclaration }
        if keywords.control.contains(word) { return .keywordControl }
        if keywords.modifier.contains(word) { return .keywordModifier }
        if keywords.operator.contains(word) { return .keywordOperator }
        if keywords.other.contains(word) { return .keyword }
        if keywords.boolean.contains(word) { return .boolean }
        if keywords.null.contains(word) { return .nil }
        if keywords.types.contains(word) { return .type }

        if let first = word.first, first.isUppercase {
            return .type
        }

        let saved = index
        while index < source.endIndex && source[index] == " " { advance() }
        let isFunction = index < source.endIndex && source[index] == "("
        index = saved

        return isFunction ? .function : .variable
    }

    private func consumeAttribute(from start: String.Index) -> Token {
        advance()
        while index < source.endIndex && (source[index].isLetter || source[index].isNumber || source[index] == "_") {
            advance()
        }
        return Token(type: .attribute, range: start..<index)
    }

    private func consumePreprocessor(from start: String.Index) -> Token {
        advance()
        while index < source.endIndex && (source[index].isLetter || source[index].isNumber || source[index] == "_") {
            advance()
        }
        return Token(type: .preprocessor, range: start..<index)
    }

    private func consumeOperator(from start: String.Index) -> Token {
        while index < source.endIndex && options.operatorChars.contains(source[index]) {
            advance()
        }
        return Token(type: .operator, range: start..<index)
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

    private func isPreprocessorDirective() -> Bool {
        options.preprocessor && (isLookingAt("#if") || isLookingAt("#else") || isLookingAt("#endif") || isLookingAt("#include"))
    }
}

private extension Character {
    var isHexDigit: Bool {
        isNumber || ("a"..."f").contains(self) || ("A"..."F").contains(self)
    }
}
