import AppKit

@MainActor
final class MonoTextView: NSView {
    private let gutterView: GutterView
    private let scrollView: NSScrollView
    private let textView: HighlightingTextView
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
    var currentLanguage: Language?

    override init(frame frameRect: NSRect) {
        gutterView = GutterView()
        scrollView = NSScrollView()
        textView = HighlightingTextView()
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
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.usesFindBar = true

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
        currentLanguage = language
        textView.language = language
        highlighter.configure(textView: textView, language: language)
    }

    func showFindBar() {
        textView.performTextFinderAction(NSTextFinder.Action.showFindInterface)
    }

    func goToLine(_ lineNumber: Int) {
        let text = textView.string as NSString
        var currentLine = 1
        var index = 0

        while index < text.length && currentLine < lineNumber {
            let lineRange = text.lineRange(for: NSRange(location: index, length: 0))
            currentLine += 1
            index = NSMaxRange(lineRange)
        }

        let targetRange = NSRange(location: min(index, text.length), length: 0)
        textView.setSelectedRange(targetRange)
        textView.scrollRangeToVisible(targetRange)
        window?.makeFirstResponder(textView)
    }

    func updateFontSize(_ size: EditorFontSize) {
        textView.font = size.font
        gutterView.needsDisplay = true
    }

    // MARK: - Find/Replace

    func findMatches(for query: String) -> Int {
        guard !query.isEmpty else { return 0 }
        let text = textView.string as NSString
        var count = 0
        var searchRange = NSRange(location: 0, length: text.length)

        while searchRange.location < text.length {
            let foundRange = text.range(of: query, options: .caseInsensitive, range: searchRange)
            if foundRange.location != NSNotFound {
                count += 1
                searchRange.location = foundRange.location + foundRange.length
                searchRange.length = text.length - searchRange.location
            } else {
                break
            }
        }
        return count
    }

    func findNext(for query: String) -> Bool {
        guard !query.isEmpty else { return false }
        let text = textView.string as NSString
        let currentLocation = textView.selectedRange().location + textView.selectedRange().length
        var searchRange = NSRange(location: currentLocation, length: text.length - currentLocation)

        var foundRange = text.range(of: query, options: .caseInsensitive, range: searchRange)
        if foundRange.location == NSNotFound {
            searchRange = NSRange(location: 0, length: currentLocation)
            foundRange = text.range(of: query, options: .caseInsensitive, range: searchRange)
        }

        if foundRange.location != NSNotFound {
            textView.setSelectedRange(foundRange)
            textView.scrollRangeToVisible(foundRange)
            return true
        }
        return false
    }

    func replaceCurrent(find: String, replace: String) {
        let selectedRange = textView.selectedRange()
        let selectedText = (textView.string as NSString).substring(with: selectedRange)

        if selectedText.lowercased() == find.lowercased() {
            textView.insertText(replace, replacementRange: selectedRange)
            _ = findNext(for: find)
        } else {
            _ = findNext(for: find)
        }
    }

    func replaceAll(find: String, replace: String) -> Int {
        guard !find.isEmpty else { return 0 }
        var count = 0
        var mutableText = textView.string
        var searchRange = mutableText.startIndex..<mutableText.endIndex

        while let range = mutableText.range(of: find, options: .caseInsensitive, range: searchRange) {
            mutableText.replaceSubrange(range, with: replace)
            count += 1
            let newStart = mutableText.index(range.lowerBound, offsetBy: replace.count, limitedBy: mutableText.endIndex) ?? mutableText.endIndex
            searchRange = newStart..<mutableText.endIndex
        }

        if count > 0 {
            textView.string = mutableText
            onTextChange?(mutableText)
            gutterView.needsDisplay = true
            highlighter.textDidChange()
        }
        return count
    }

    var lineCount: Int {
        let text = textView.string as NSString
        guard text.length > 0 else { return 1 }
        return text.components(separatedBy: "\n").count
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
        textView.needsDisplay = true
    }

    func textView(
        _ textView: NSTextView,
        shouldChangeTextIn range: NSRange,
        replacementString text: String?
    ) -> Bool {
        guard let text = text, text == "\n" else { return true }

        let nsString = textView.string as NSString
        let lineRange = nsString.lineRange(for: NSRange(location: range.location, length: 0))
        let currentLine = nsString.substring(with: lineRange)

        var indent = ""
        for char in currentLine {
            if char == " " || char == "\t" {
                indent.append(char)
            } else {
                break
            }
        }

        let trimmed = currentLine.trimmingCharacters(in: .whitespaces)
        if trimmed.hasSuffix("{") || trimmed.hasSuffix(":") {
            indent += "    "
        }

        textView.insertText("\n" + indent, replacementRange: range)
        return false
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

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(bounds, cursor: .arrow)
    }

    override func draw(_ dirtyRect: NSRect) {
        ThemeColors.NS.backgroundSecondary.setFill()
        dirtyRect.fill()

        guard let textView = textView,
              let textLayoutManager = textView.textLayoutManager,
              let scrollView = scrollView else {
            return
        }

        let font = MonoFonts.NS.lineNumber
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: ThemeColors.NS.textMuted,
        ]

        let visibleRect = scrollView.documentVisibleRect
        let text = textView.string as NSString
        guard text.length > 0 else { return }

        var lineNumber = 1

        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.location,
            options: [.ensuresLayout]
        ) { fragment in
            let fragmentFrame = fragment.layoutFragmentFrame

            if fragmentFrame.maxY < visibleRect.minY {
                lineNumber += 1
                return true
            }

            if fragmentFrame.minY > visibleRect.maxY {
                return false
            }

            let lineString = "\(lineNumber)"
            let size = lineString.size(withAttributes: attrs)
            let x = self.bounds.width - size.width - Spacing.sm
            let y = fragmentFrame.origin.y - visibleRect.origin.y + (fragmentFrame.height - size.height) / 2

            lineString.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)

            lineNumber += 1
            return true
        }
    }
}

private final class HighlightingTextView: NSTextView {
    var language: Language?
    private let autoPairs: [String: String] = [
        "(": ")", "[": "]", "{": "}", "\"": "\"", "'": "'"
    ]

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)
        drawCurrentLineHighlight()
        drawIndentGuides(in: rect)
    }

    private func drawCurrentLineHighlight() {
        guard let textLayoutManager = textLayoutManager else { return }

        let selectedRange = selectedRange()
        let text = string as NSString

        guard text.length > 0, selectedRange.location <= text.length else { return }

        let cursorLocation = selectedRange.location
        var lineRect: NSRect?

        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.location,
            options: [.ensuresLayout]
        ) { fragment in
            let textRange = fragment.rangeInElement

            let startOffset = textLayoutManager.offset(
                from: textLayoutManager.documentRange.location,
                to: textRange.location
            )
            let endOffset = startOffset + (textLayoutManager.offset(
                from: textRange.location,
                to: textRange.endLocation
            ))

            if cursorLocation >= startOffset && cursorLocation <= endOffset {
                lineRect = fragment.layoutFragmentFrame
                return false
            }
            return true
        }

        if var rect = lineRect {
            rect.origin.x = 0
            rect.size.width = bounds.width
            ThemeColors.NS.currentLine.setFill()
            rect.fill()
        }
    }

    private func drawIndentGuides(in rect: NSRect) {
        guard let textLayoutManager = textLayoutManager,
              let font = font else { return }

        let tabWidth: CGFloat = 4
        let charWidth = NSString(" ").size(withAttributes: [.font: font]).width
        let indentWidth = charWidth * tabWidth

        let guideColor = ThemeColors.NS.textMuted.withAlphaComponent(0.2)
        guideColor.setStroke()

        let path = NSBezierPath()
        path.lineWidth = 1

        let text = string as NSString
        guard text.length > 0 else { return }

        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.location,
            options: [.ensuresLayout]
        ) { fragment in
            let fragmentFrame = fragment.layoutFragmentFrame

            guard fragmentFrame.maxY >= rect.minY,
                  fragmentFrame.minY <= rect.maxY else {
                return fragmentFrame.minY <= rect.maxY
            }

            let textRange = fragment.rangeInElement
            let startOffset = textLayoutManager.offset(
                from: textLayoutManager.documentRange.location,
                to: textRange.location
            )
            let safeOffset = max(0, min(startOffset, text.length - 1))
            let lineRange = text.lineRange(for: NSRange(location: safeOffset, length: 0))
            let line = text.substring(with: lineRange)

            var indentLevel = 0
            for char in line {
                if char == " " { indentLevel += 1 }
                else if char == "\t" { indentLevel += Int(tabWidth) }
                else { break }
            }

            let guides = indentLevel / Int(tabWidth)
            if guides >= 1 {
                for i in 1...guides {
                    let x = CGFloat(i) * indentWidth + self.textContainerInset.width
                    path.move(to: NSPoint(x: x, y: fragmentFrame.origin.y))
                    path.line(to: NSPoint(x: x, y: fragmentFrame.origin.y + fragmentFrame.height))
                }
            }

            return true
        }

        path.stroke()
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let key = event.charactersIgnoringModifiers ?? ""

        if flags == .command {
            switch key {
            case "d": duplicateLine(); return true
            case "l": selectLine(); return true
            case "/": toggleComment(); return true
            default: break
            }
        }

        if flags == [.command, .shift] {
            switch key {
            case "k", "K": deleteLine(); return true
            case "\r": insertLineAbove(); return true
            default: break
            }
        }

        if flags == .command && key == "\r" {
            insertLineBelow()
            return true
        }

        if flags == .option {
            switch event.keyCode {
            case 126: moveLineUp(); return true
            case 125: moveLineDown(); return true
            default: break
            }
        }

        return super.performKeyEquivalent(with: event)
    }

    override func insertText(_ string: Any, replacementRange: NSRange) {
        guard let str = string as? String, str.count == 1,
              let closing = autoPairs[str] else {
            super.insertText(string, replacementRange: replacementRange)
            return
        }

        let range = replacementRange.location == NSNotFound ? selectedRange() : replacementRange
        super.insertText(str + closing, replacementRange: range)
        setSelectedRange(NSRange(location: range.location + 1, length: 0))
    }

    private func duplicateLine() {
        let text = string as NSString
        let range = selectedRange()
        let lineRange = text.lineRange(for: range)
        let lineContent = text.substring(with: lineRange)
        let insertion = lineContent.hasSuffix("\n") ? lineContent : lineContent + "\n"
        insertText(insertion, replacementRange: NSRange(location: NSMaxRange(lineRange), length: 0))
        setSelectedRange(NSRange(location: NSMaxRange(lineRange) + range.location - lineRange.location, length: range.length))
    }

    private func deleteLine() {
        let text = string as NSString
        let lineRange = text.lineRange(for: selectedRange())
        insertText("", replacementRange: lineRange)
    }

    private func selectLine() {
        let text = string as NSString
        let lineRange = text.lineRange(for: selectedRange())
        setSelectedRange(lineRange)
    }

    private func insertLineBelow() {
        let text = string as NSString
        let lineRange = text.lineRange(for: selectedRange())
        let endOfLine = NSMaxRange(lineRange) - (text.substring(with: lineRange).hasSuffix("\n") ? 1 : 0)
        setSelectedRange(NSRange(location: endOfLine, length: 0))
        insertText("\n", replacementRange: selectedRange())
    }

    private func insertLineAbove() {
        let text = string as NSString
        let lineRange = text.lineRange(for: selectedRange())
        setSelectedRange(NSRange(location: lineRange.location, length: 0))
        insertText("\n", replacementRange: selectedRange())
        setSelectedRange(NSRange(location: lineRange.location, length: 0))
    }

    private func moveLineUp() {
        let text = string as NSString
        guard text.length > 0 else { return }
        let currentRange = selectedRange()
        let lineRange = text.lineRange(for: currentRange)
        guard lineRange.location > 0 else { return }

        let prevLineRange = text.lineRange(for: NSRange(location: lineRange.location - 1, length: 0))
        let currentLine = text.substring(with: lineRange)
        let prevLine = text.substring(with: prevLineRange)

        let combined = currentLine + (currentLine.hasSuffix("\n") ? "" : "\n") +
                       (prevLine.hasSuffix("\n") ? String(prevLine.dropLast()) : prevLine) +
                       (NSMaxRange(lineRange) < text.length ? "\n" : "")

        let fullRange = NSRange(location: prevLineRange.location, length: NSMaxRange(lineRange) - prevLineRange.location)
        insertText(combined.hasSuffix("\n") && NSMaxRange(lineRange) >= text.length ? String(combined.dropLast()) : combined, replacementRange: fullRange)
        setSelectedRange(NSRange(location: prevLineRange.location + currentRange.location - lineRange.location, length: currentRange.length))
    }

    private func moveLineDown() {
        let text = string as NSString
        guard text.length > 0 else { return }
        let currentRange = selectedRange()
        let lineRange = text.lineRange(for: currentRange)
        guard NSMaxRange(lineRange) < text.length else { return }

        let nextLineRange = text.lineRange(for: NSRange(location: NSMaxRange(lineRange), length: 0))
        let currentLine = text.substring(with: lineRange)
        let nextLine = text.substring(with: nextLineRange)

        let combined = (nextLine.hasSuffix("\n") ? String(nextLine.dropLast()) : nextLine) + "\n" + currentLine

        let fullRange = NSRange(location: lineRange.location, length: NSMaxRange(nextLineRange) - lineRange.location)
        insertText(combined.hasSuffix("\n") ? String(combined.dropLast()) : combined, replacementRange: fullRange)
        let newLocation = lineRange.location + nextLineRange.length
        setSelectedRange(NSRange(location: newLocation + currentRange.location - lineRange.location, length: currentRange.length))
    }

    private func toggleComment() {
        guard let prefix = language?.lineCommentPrefix else { return }
        let text = string as NSString
        let range = selectedRange()
        let lineRange = text.lineRange(for: range)
        let line = text.substring(with: lineRange)
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix(prefix) {
            if let prefixRange = line.range(of: prefix + " ") {
                let nsRange = NSRange(prefixRange, in: line)
                let removeRange = NSRange(location: lineRange.location + nsRange.location, length: nsRange.length)
                insertText("", replacementRange: removeRange)
            } else if let prefixRange = line.range(of: prefix) {
                let nsRange = NSRange(prefixRange, in: line)
                let removeRange = NSRange(location: lineRange.location + nsRange.location, length: nsRange.length)
                insertText("", replacementRange: removeRange)
            }
        } else {
            let indent = line.prefix(while: { $0 == " " || $0 == "\t" })
            let insertLocation = lineRange.location + indent.count
            insertText(prefix + " ", replacementRange: NSRange(location: insertLocation, length: 0))
        }
    }
}
