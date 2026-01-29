import Foundation

// MARK: - Lexer State

/// 렉서의 현재 상태 - 여러 줄에 걸친 컨텍스트 추적
enum LexerState: Equatable, Sendable {
    case normal
    case inString(quote: Character, multiline: Bool)
    case inComment(multiline: Bool)
    case inInterpolation(depth: Int)
}

// MARK: - Lexer

/// 상태 기반 렉서 - 컨텍스트를 인식하며 토큰화
final class Lexer: @unchecked Sendable {
    private let source: String
    private let grammar: LanguageGrammar
    private var index: String.Index
    private var state: LexerState = .normal

    private var tokens: [Token] = []

    init(source: String, grammar: LanguageGrammar) {
        self.source = source
        self.grammar = grammar
        self.index = source.startIndex
    }

    /// 전체 소스를 토큰화
    func tokenize() -> [Token] {
        tokens = []
        index = source.startIndex
        state = .normal

        while index < source.endIndex {
            let token = nextToken()
            tokens.append(token)
        }

        return tokens
    }

    /// 특정 상태에서 시작하여 토큰화 (증분 파싱용)
    func tokenize(startingWith initialState: LexerState) -> ([Token], LexerState) {
        tokens = []
        index = source.startIndex
        state = initialState

        while index < source.endIndex {
            let token = nextToken()
            tokens.append(token)
        }

        return (tokens, state)
    }

    // MARK: - Token Recognition

    private func nextToken() -> Token {
        let startIndex = index

        switch state {
        case .normal:
            return tokenizeNormal(from: startIndex)
        case .inString(let quote, let multiline):
            return tokenizeString(from: startIndex, quote: quote, multiline: multiline)
        case .inComment(let multiline):
            return tokenizeComment(from: startIndex, multiline: multiline)
        case .inInterpolation(let depth):
            return tokenizeInterpolation(from: startIndex, depth: depth)
        }
    }

    // MARK: - Normal State

    private func tokenizeNormal(from start: String.Index) -> Token {
        let char = source[index]

        // Whitespace
        if char.isWhitespace && !char.isNewline {
            return consumeWhitespace(from: start)
        }

        // Newline
        if char.isNewline {
            advance()
            return Token(type: .newline, range: start..<index)
        }

        // Comments
        if char == "/" && peek() == "/" {
            return consumeLineComment(from: start)
        }
        if char == "/" && peek() == "*" {
            return consumeBlockComment(from: start)
        }
        // Python/Shell comments
        if (grammar.language == .python || grammar.language == .shell || grammar.language == .yaml)
            && char == "#" && !isLookingAt("#if") && !isLookingAt("#else") && !isLookingAt("#endif") {
            return consumeLineComment(from: start)
        }
        // HTML comments
        if char == "<" && isLookingAt("<!--") {
            return consumeHTMLComment(from: start)
        }

        // Strings
        if char == "\"" {
            // Check for multiline string """
            if isLookingAt("\"\"\"") {
                return consumeMultilineString(from: start, quote: "\"")
            }
            return consumeString(from: start, quote: "\"")
        }
        if char == "'" {
            if grammar.supportsSingleQuoteStrings {
                return consumeString(from: start, quote: "'")
            }
        }
        if char == "`" {
            if grammar.supportsBacktickStrings {
                return consumeString(from: start, quote: "`")
            }
        }

        // Numbers
        if char.isNumber || (char == "." && peek()?.isNumber == true) {
            return consumeNumber(from: start)
        }
        // Hex numbers
        if char == "0" && (peek() == "x" || peek() == "X" || peek() == "b" || peek() == "o") {
            return consumeNumber(from: start)
        }

        // Attributes (@MainActor, @Observable)
        if char == "@" && grammar.supportsAttributes {
            return consumeAttribute(from: start)
        }

        // Preprocessor directives (#if, #endif)
        if char == "#" && grammar.supportsPreprocessor {
            return consumePreprocessor(from: start)
        }

        // Identifiers and keywords
        if char.isLetter || char == "_" {
            return consumeIdentifier(from: start)
        }

        // Operators
        if grammar.operatorChars.contains(char) {
            return consumeOperator(from: start)
        }

        // Delimiters
        if "()[]{}".contains(char) {
            advance()
            return Token(type: .delimiter, range: start..<index)
        }

        // Punctuation
        if ",.;:".contains(char) {
            advance()
            return Token(type: .punctuation, range: start..<index)
        }

        // Tags (HTML/XML)
        if char == "<" && (grammar.language == .html || grammar.language == .xml) {
            return consumeTag(from: start)
        }

        // Unknown - consume as plain
        advance()
        return Token(type: .plain, range: start..<index)
    }

    // MARK: - String Tokenization

    private func consumeString(from start: String.Index, quote: Character) -> Token {
        advance() // consume opening quote

        while index < source.endIndex {
            let char = source[index]

            if char == "\\" {
                // Escape sequence
                advance()
                if index < source.endIndex {
                    advance()
                }
                continue
            }

            // String interpolation (Swift)
            if char == "\\" && peek() == "(" && grammar.language == .swift {
                // Handle later
            }

            if char == quote {
                advance() // consume closing quote
                return Token(type: .string, range: start..<index)
            }

            if char.isNewline && !grammar.supportsMultilineStrings {
                // Unterminated string
                return Token(type: .string, range: start..<index)
            }

            advance()
        }

        // Unterminated string
        return Token(type: .string, range: start..<index)
    }

    private func consumeMultilineString(from start: String.Index, quote: Character) -> Token {
        // Consume opening """
        advance()
        advance()
        advance()

        while index < source.endIndex {
            let char = source[index]

            if char == "\\" {
                advance()
                if index < source.endIndex {
                    advance()
                }
                continue
            }

            if char == quote && isLookingAt("\"\"\"") {
                advance()
                advance()
                advance()
                return Token(type: .string, range: start..<index)
            }

            advance()
        }

        return Token(type: .string, range: start..<index)
    }

    private func tokenizeString(from start: String.Index, quote: Character, multiline: Bool) -> Token {
        // Continue string from previous line (for state-based parsing)
        while index < source.endIndex {
            let char = source[index]

            if char == "\\" {
                advance()
                if index < source.endIndex {
                    advance()
                }
                continue
            }

            if char == quote {
                if multiline && isLookingAt("\"\"\"") {
                    advance()
                    advance()
                    advance()
                    state = .normal
                    return Token(type: .string, range: start..<index)
                } else if !multiline {
                    advance()
                    state = .normal
                    return Token(type: .string, range: start..<index)
                }
            }

            advance()
        }

        return Token(type: .string, range: start..<index)
    }

    // MARK: - Comment Tokenization

    private func consumeLineComment(from start: String.Index) -> Token {
        while index < source.endIndex && !source[index].isNewline {
            advance()
        }
        return Token(type: .comment, range: start..<index)
    }

    private func consumeBlockComment(from start: String.Index) -> Token {
        advance() // /
        advance() // *

        while index < source.endIndex {
            if source[index] == "*" && peek() == "/" {
                advance()
                advance()
                return Token(type: .comment, range: start..<index)
            }
            advance()
        }

        // Unterminated - set state for next line
        state = .inComment(multiline: true)
        return Token(type: .comment, range: start..<index)
    }

    private func consumeHTMLComment(from start: String.Index) -> Token {
        // Consume <!--
        advance()
        advance()
        advance()
        advance()

        while index < source.endIndex {
            if source[index] == "-" && isLookingAt("-->") {
                advance()
                advance()
                advance()
                return Token(type: .comment, range: start..<index)
            }
            advance()
        }

        state = .inComment(multiline: true)
        return Token(type: .comment, range: start..<index)
    }

    private func tokenizeComment(from start: String.Index, multiline: Bool) -> Token {
        // Continue block comment from previous line
        while index < source.endIndex {
            if source[index] == "*" && peek() == "/" {
                advance()
                advance()
                state = .normal
                return Token(type: .comment, range: start..<index)
            }
            if source[index] == "-" && isLookingAt("-->") {
                advance()
                advance()
                advance()
                state = .normal
                return Token(type: .comment, range: start..<index)
            }
            advance()
        }

        return Token(type: .comment, range: start..<index)
    }

    // MARK: - Interpolation (for future)

    private func tokenizeInterpolation(from start: String.Index, depth: Int) -> Token {
        // Simplified - treat as normal for now
        state = .normal
        return tokenizeNormal(from: start)
    }

    // MARK: - Number Tokenization

    private func consumeNumber(from start: String.Index) -> Token {
        let char = source[index]

        // Hex, binary, octal
        if char == "0" {
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
                    while index < source.endIndex && (source[index] == "0" || source[index] == "1" || source[index] == "_") {
                        advance()
                    }
                    return Token(type: .number, range: start..<index)
                }
                if next == "o" || next == "O" {
                    advance()
                    while index < source.endIndex && (source[index] >= "0" && source[index] <= "7" || source[index] == "_") {
                        advance()
                    }
                    return Token(type: .number, range: start..<index)
                }
            }
        }

        // Decimal number
        var hasDecimal = false
        var hasExponent = false

        while index < source.endIndex {
            let c = source[index]

            if c.isNumber || c == "_" {
                advance()
                continue
            }

            if c == "." && !hasDecimal && !hasExponent {
                if let next = peek(), next.isNumber {
                    hasDecimal = true
                    advance()
                    continue
                }
            }

            if (c == "e" || c == "E") && !hasExponent {
                hasExponent = true
                advance()
                if index < source.endIndex && (source[index] == "+" || source[index] == "-") {
                    advance()
                }
                continue
            }

            break
        }

        return Token(type: .number, range: start..<index)
    }

    // MARK: - Identifier Tokenization

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
        let type = classifyIdentifier(word)

        return Token(type: type, range: start..<index)
    }

    private func classifyIdentifier(_ word: String) -> TokenType {
        // Check keywords
        if grammar.declarationKeywords.contains(word) {
            return .keywordDeclaration
        }
        if grammar.controlKeywords.contains(word) {
            return .keywordControl
        }
        if grammar.operatorKeywords.contains(word) {
            return .keywordOperator
        }
        if grammar.modifierKeywords.contains(word) {
            return .keywordModifier
        }
        if grammar.otherKeywords.contains(word) {
            return .keyword
        }

        // Built-in values
        if grammar.booleanLiterals.contains(word) {
            return .boolean
        }
        if grammar.nilLiterals.contains(word) {
            return .nil
        }

        // Built-in types
        if grammar.builtinTypes.contains(word) {
            return .type
        }

        // Type (starts with uppercase)
        if let first = word.first, first.isUppercase {
            return .type
        }

        // Check if followed by ( -> function call
        skipWhitespaceOnly()
        if index < source.endIndex && source[index] == "(" {
            return .function
        }

        return .variable
    }

    // MARK: - Attribute Tokenization

    private func consumeAttribute(from start: String.Index) -> Token {
        advance() // @

        while index < source.endIndex {
            let char = source[index]
            if char.isLetter || char.isNumber || char == "_" {
                advance()
            } else {
                break
            }
        }

        return Token(type: .attribute, range: start..<index)
    }

    // MARK: - Preprocessor Tokenization

    private func consumePreprocessor(from start: String.Index) -> Token {
        advance() // #

        while index < source.endIndex {
            let char = source[index]
            if char.isLetter || char.isNumber || char == "_" {
                advance()
            } else {
                break
            }
        }

        return Token(type: .preprocessor, range: start..<index)
    }

    // MARK: - Operator Tokenization

    private func consumeOperator(from start: String.Index) -> Token {
        // Consume multi-character operators
        while index < source.endIndex && grammar.operatorChars.contains(source[index]) {
            advance()
        }

        return Token(type: .operator, range: start..<index)
    }

    // MARK: - Tag Tokenization (HTML/XML)

    private func consumeTag(from start: String.Index) -> Token {
        advance() // <

        // Closing tag?
        if index < source.endIndex && source[index] == "/" {
            advance()
        }

        // Tag name
        while index < source.endIndex {
            let char = source[index]
            if char == ">" || char.isWhitespace {
                break
            }
            advance()
        }

        // For now, treat whole tag simply
        while index < source.endIndex && source[index] != ">" {
            advance()
        }

        if index < source.endIndex {
            advance() // >
        }

        return Token(type: .tag, range: start..<index)
    }

    // MARK: - Whitespace

    private func consumeWhitespace(from start: String.Index) -> Token {
        while index < source.endIndex {
            let char = source[index]
            if char.isWhitespace && !char.isNewline {
                advance()
            } else {
                break
            }
        }
        return Token(type: .whitespace, range: start..<index)
    }

    // MARK: - Helpers

    private func advance() {
        if index < source.endIndex {
            index = source.index(after: index)
        }
    }

    private func peek() -> Character? {
        let next = source.index(after: index)
        guard next < source.endIndex else { return nil }
        return source[next]
    }

    private func isLookingAt(_ str: String) -> Bool {
        guard let endIndex = source.index(index, offsetBy: str.count, limitedBy: source.endIndex) else {
            return false
        }
        return source[index..<endIndex] == str
    }

    private func skipWhitespaceOnly() {
        let saved = index
        while index < source.endIndex && source[index] == " " {
            advance()
        }
        // Don't actually advance - just peek
        index = saved
    }
}

// MARK: - Character Extensions

private extension Character {
    var isHexDigit: Bool {
        return isNumber || ("a"..."f").contains(self) || ("A"..."F").contains(self)
    }
}
