import AppKit

@MainActor
final class MonoTextView: NSView {
    private let gutterView: GutterView
    private let scrollView: NSScrollView
    private let textView: NSTextView
    private let highlighter: SyntaxHighlighter

    private nonisolated(unsafe) var boundsObserver: NSObjectProtocol?

    var text: String {
        get { textView.string }
        set {
            textView.string = newValue
            gutterView.needsDisplay = true
            highlighter.textDidChange()
        }
    }

    var onTextChange: ((String) -> Void)?
    var onCursorChange: ((Int, Int) -> Void)?

    override init(frame frameRect: NSRect) {
        gutterView = GutterView()
        scrollView = NSScrollView()
        textView = NSTextView()
        highlighter = SyntaxHighlighter()

        super.init(frame: frameRect)
        setupGutter()
        setupScrollView()
        setupTextView()
        setupObservers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGutter() {
        gutterView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gutterView)

        NSLayoutConstraint.activate([
            gutterView.topAnchor.constraint(equalTo: topAnchor),
            gutterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gutterView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gutterView.widthAnchor.constraint(equalToConstant: Dimensions.lineNumberGutterWidth),
        ])
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.documentView = textView

        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: gutterView.trailingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func setupTextView() {
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.usesFindBar = true

        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false

        textView.textContainer?.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.textContainer?.widthTracksTextView = true

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false

        textView.backgroundColor = ThemeColors.NS.backgroundPrimary
        textView.textColor = ThemeColors.NS.textPrimary
        textView.insertionPointColor = ThemeColors.NS.accent
        textView.selectedTextAttributes = [
            .backgroundColor: ThemeColors.NS.selection
        ]
        textView.font = MonoFonts.NS.editor()

        textView.delegate = self
    }

    private func setupObservers() {
        gutterView.textView = textView
        gutterView.scrollView = scrollView

        scrollView.contentView.postsBoundsChangedNotifications = true
        boundsObserver = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.gutterView.needsDisplay = true
            }
        }
    }

    deinit {
        if let observer = boundsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func configure(for language: Language?) {
        highlighter.configure(textView: textView, language: language)
    }

    func showFindBar() {
        textView.performTextFinderAction(NSTextFinder.Action.showFindInterface)
    }

    override func layout() {
        super.layout()
        textView.textContainer?.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
    }
}

extension MonoTextView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        onTextChange?(textView.string)
        gutterView.needsDisplay = true
        highlighter.textDidChange()
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        let (line, column) = calculateCursorPosition()
        onCursorChange?(line, column)
    }

    private func calculateCursorPosition() -> (line: Int, column: Int) {
        let selectedRange = textView.selectedRange()
        let text = textView.string as NSString

        guard text.length > 0,
              selectedRange.location >= 0,
              selectedRange.location <= text.length else {
            return (1, 1)
        }

        let safeLocation = min(selectedRange.location, text.length)
        let lineRange = text.lineRange(for: NSRange(location: safeLocation, length: 0))

        guard lineRange.location <= text.length else {
            return (1, 1)
        }

        let line = text.substring(to: lineRange.location).components(separatedBy: "\n").count
        let column = safeLocation - lineRange.location + 1

        return (max(1, line), max(1, column))
    }
}

private final class GutterView: NSView {
    weak var textView: NSTextView?
    weak var scrollView: NSScrollView?

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        ThemeColors.NS.backgroundSecondary.setFill()
        dirtyRect.fill()

        guard let textView = textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer,
              let scrollView = scrollView else {
            return
        }

        let font = MonoFonts.NS.lineNumber
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: ThemeColors.NS.textMuted,
        ]

        let visibleRect = scrollView.documentVisibleRect
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        let text = textView.string as NSString
        guard text.length > 0 else { return }

        guard charRange.location >= 0,
              charRange.location <= text.length,
              NSMaxRange(charRange) <= text.length else {
            return
        }

        var lineNumber = 1
        if charRange.location > 0 && charRange.location <= text.length {
            lineNumber = text.substring(to: charRange.location).components(separatedBy: "\n").count
        }

        var index = charRange.location
        let maxIndex = min(NSMaxRange(charRange), text.length)

        while index < maxIndex {
            let lineRange = text.lineRange(for: NSRange(location: index, length: 0))

            guard NSMaxRange(lineRange) > index else { break }

            let glyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
            var lineRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            lineRect.origin.y -= visibleRect.origin.y

            let lineString = "\(lineNumber)"
            let size = lineString.size(withAttributes: attrs)
            let x = bounds.width - size.width - Spacing.sm
            let y = lineRect.origin.y + (lineRect.height - size.height) / 2

            lineString.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)

            lineNumber += 1
            index = NSMaxRange(lineRange)
        }
    }
}
