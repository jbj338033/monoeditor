import AppKit

@MainActor
final class SyntaxHighlighter {
    private weak var textView: NSTextView?
    private var currentLanguage: Language?

    private var pendingTask: Task<Void, Never>?
    private let debounceInterval: UInt64 = 10_000_000

    func configure(textView: NSTextView, language: Language?) {
        self.textView = textView
        self.currentLanguage = language
        applyHighlighting()
    }

    func textDidChange() {
        pendingTask?.cancel()
        pendingTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: self?.debounceInterval ?? 0)
            guard !Task.isCancelled else { return }
            self?.applyHighlighting()
        }
    }

    private func applyHighlighting() {
        guard let textView = textView,
              let textStorage = textView.textStorage else {
            return
        }

        let text = textView.string
        guard !text.isEmpty else { return }

        let fullRange = NSRange(location: 0, length: text.utf16.count)
        let selectedRange = textView.selectedRange()

        let tokens = LanguageRegistry.tokenize(text, language: currentLanguage)

        textStorage.beginEditing()

        textStorage.addAttributes([
            .foregroundColor: SyntaxColors.NS.plain,
            .font: MonoFonts.NS.editor()
        ], range: fullRange)

        for token in tokens {
            let nsRange = NSRange(token.range, in: text)
            guard nsRange.location != NSNotFound,
                  nsRange.length > 0,
                  nsRange.location + nsRange.length <= text.utf16.count else {
                continue
            }

            if token.type == .whitespace || token.type == .newline {
                continue
            }

            textStorage.addAttribute(.foregroundColor, value: token.type.color, range: nsRange)
        }

        textStorage.endEditing()

        if selectedRange.location <= text.utf16.count {
            textView.setSelectedRange(selectedRange)
        }
    }
}
