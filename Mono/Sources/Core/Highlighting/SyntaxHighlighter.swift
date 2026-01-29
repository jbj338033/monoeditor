import AppKit

// MARK: - Syntax Highlighter

@MainActor
final class SyntaxHighlighter {
    private weak var textView: NSTextView?
    private var currentLanguage: Language?
    private var grammar: LanguageGrammar?

    // 라인별 토큰 캐시 (증분 업데이트용)
    private var lineTokens: [[Token]] = []
    private var lineStates: [LexerState] = []

    // 디바운싱
    private var pendingHighlightTask: Task<Void, Never>?
    private let debounceInterval: UInt64 = 10_000_000  // 10ms

    // MARK: - Configuration

    func configure(textView: NSTextView, language: Language?) {
        self.textView = textView
        self.currentLanguage = language
        self.grammar = language.map { LanguageGrammar.grammar(for: $0) }

        // 초기 하이라이팅
        invalidateAll()
    }

    // MARK: - Text Change Handling

    func textDidChange() {
        // 디바운싱으로 빠른 타이핑 시 성능 최적화
        pendingHighlightTask?.cancel()
        pendingHighlightTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: self?.debounceInterval ?? 0)
            guard !Task.isCancelled else { return }
            await self?.applyHighlighting()
        }
    }

    func textDidChange(in editedRange: NSRange, changeInLength delta: Int) {
        // 증분 업데이트: 변경된 라인만 다시 파싱
        pendingHighlightTask?.cancel()
        pendingHighlightTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: self?.debounceInterval ?? 0)
            guard !Task.isCancelled else { return }
            await self?.applyIncrementalHighlighting(editedRange: editedRange, delta: delta)
        }
    }

    // MARK: - Full Highlighting

    private func invalidateAll() {
        lineTokens = []
        lineStates = []
        applyHighlighting()
    }

    private func applyHighlighting() {
        guard let textView = textView,
              let textStorage = textView.textStorage,
              let grammar = grammar else {
            applyPlainStyle()
            return
        }

        let text = textView.string
        guard !text.isEmpty else { return }

        let fullRange = NSRange(location: 0, length: text.utf16.count)
        let selectedRange = textView.selectedRange()

        // Lexer로 전체 토큰화
        let lexer = Lexer(source: text, grammar: grammar)
        let tokens = lexer.tokenize()

        // 속성 적용
        textStorage.beginEditing()

        // 기본 스타일
        textStorage.addAttributes([
            .foregroundColor: SyntaxColors.NS.plain,
            .font: MonoFonts.NS.editor()
        ], range: fullRange)

        // 토큰별 색상 적용
        for token in tokens {
            let nsRange = NSRange(token.range, in: text)
            guard nsRange.location != NSNotFound && nsRange.length > 0 else { continue }
            guard nsRange.location + nsRange.length <= text.utf16.count else { continue }

            // whitespace/newline은 스킵
            if token.type == .whitespace || token.type == .newline {
                continue
            }

            textStorage.addAttribute(.foregroundColor, value: token.type.color, range: nsRange)
        }

        textStorage.endEditing()

        // 커서 위치 복원
        if selectedRange.location <= text.utf16.count {
            textView.setSelectedRange(selectedRange)
        }
    }

    private func applyPlainStyle() {
        guard let textView = textView,
              let textStorage = textView.textStorage else { return }

        let text = textView.string
        guard !text.isEmpty else { return }

        let fullRange = NSRange(location: 0, length: text.utf16.count)

        textStorage.beginEditing()
        textStorage.addAttributes([
            .foregroundColor: SyntaxColors.NS.plain,
            .font: MonoFonts.NS.editor()
        ], range: fullRange)
        textStorage.endEditing()
    }

    // MARK: - Incremental Highlighting

    private func applyIncrementalHighlighting(editedRange: NSRange, delta: Int) {
        guard let textView = textView,
              let textStorage = textView.textStorage,
              let grammar = grammar else {
            applyPlainStyle()
            return
        }

        let text = textView.string
        guard !text.isEmpty else { return }

        // 편집된 라인 범위 계산
        let (startLine, endLine) = affectedLineRange(in: text, editedRange: editedRange)

        // 해당 라인들의 문자 범위 계산
        let lines = text.components(separatedBy: "\n")
        guard startLine < lines.count else {
            applyHighlighting()
            return
        }

        var lineStartOffset = 0
        for i in 0..<startLine {
            lineStartOffset += lines[i].utf16.count + 1  // +1 for newline
        }

        var lineEndOffset = lineStartOffset
        for i in startLine...min(endLine, lines.count - 1) {
            lineEndOffset += lines[i].utf16.count + 1
        }
        lineEndOffset = min(lineEndOffset, text.utf16.count)

        // 해당 범위만 다시 토큰화
        let rangeStart = text.index(text.startIndex, offsetBy: lineStartOffset, limitedBy: text.endIndex) ?? text.startIndex
        let rangeEnd = text.index(text.startIndex, offsetBy: lineEndOffset, limitedBy: text.endIndex) ?? text.endIndex
        let substring = String(text[rangeStart..<rangeEnd])

        // 이전 라인의 상태로 시작
        let initialState: LexerState = startLine > 0 && startLine <= lineStates.count
            ? lineStates[startLine - 1]
            : .normal

        let lexer = Lexer(source: substring, grammar: grammar)
        let (tokens, _) = lexer.tokenize(startingWith: initialState)

        let selectedRange = textView.selectedRange()

        // 해당 범위 속성 적용
        textStorage.beginEditing()

        let highlightRange = NSRange(location: lineStartOffset, length: lineEndOffset - lineStartOffset)
        textStorage.addAttributes([
            .foregroundColor: SyntaxColors.NS.plain,
            .font: MonoFonts.NS.editor()
        ], range: highlightRange)

        for token in tokens {
            let tokenRange = NSRange(token.range, in: substring)
            guard tokenRange.location != NSNotFound && tokenRange.length > 0 else { continue }

            if token.type == .whitespace || token.type == .newline {
                continue
            }

            let adjustedRange = NSRange(
                location: lineStartOffset + tokenRange.location,
                length: tokenRange.length
            )

            guard adjustedRange.location + adjustedRange.length <= text.utf16.count else { continue }

            textStorage.addAttribute(.foregroundColor, value: token.type.color, range: adjustedRange)
        }

        textStorage.endEditing()

        if selectedRange.location <= text.utf16.count {
            textView.setSelectedRange(selectedRange)
        }
    }

    private func affectedLineRange(in text: String, editedRange: NSRange) -> (startLine: Int, endLine: Int) {
        var lineNumber = 0
        var startLine = 0
        var endLine = 0

        for (index, char) in text.enumerated() {
            if index == editedRange.location {
                startLine = lineNumber
            }
            if index == editedRange.location + editedRange.length {
                endLine = lineNumber
                break
            }
            if char == "\n" {
                lineNumber += 1
            }
        }

        // 편집 범위가 텍스트 끝까지인 경우
        if editedRange.location + editedRange.length >= text.count {
            endLine = lineNumber
        }

        // 최소 한 줄은 다시 파싱
        return (startLine, max(startLine, endLine))
    }
}

// MARK: - Convenience Extension for Language Detection

extension Language {
    /// 파일 확장자로 언어 감지 (기존 호환성 유지)
    var highlightPatterns: [HighlightPattern] {
        // Legacy support - 새 시스템에서는 사용하지 않음
        []
    }
}

// MARK: - Legacy Support (for gradual migration)

struct HighlightPattern {
    let regex: String
    let color: NSColor
    let options: NSRegularExpression.Options

    init(_ regex: String, color: NSColor, options: NSRegularExpression.Options = []) {
        self.regex = regex
        self.color = color
        self.options = options
    }
}
