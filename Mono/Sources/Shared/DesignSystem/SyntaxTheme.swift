import SwiftUI
import AppKit

enum SyntaxColors {
    static let keyword = Color(hex: "#C586C0")
    static let string = Color(hex: "#CE9178")
    static let number = Color(hex: "#B5CEA8")
    static let comment = Color(hex: "#6A9955")
    static let function = Color(hex: "#DCDCAA")
    static let type = Color(hex: "#4EC9B0")
    static let variable = Color(hex: "#9CDCFE")
    static let property = Color(hex: "#9CDCFE")
    static let `operator` = Color(hex: "#D4D4D4")
    static let punctuation = Color(hex: "#808080")

    enum NS {
        static let keyword = NSColor(hex: "#C586C0")
        static let string = NSColor(hex: "#CE9178")
        static let number = NSColor(hex: "#B5CEA8")
        static let comment = NSColor(hex: "#6A9955")
        static let function = NSColor(hex: "#DCDCAA")
        static let type = NSColor(hex: "#4EC9B0")
        static let variable = NSColor(hex: "#9CDCFE")
        static let property = NSColor(hex: "#9CDCFE")
        static let `operator` = NSColor(hex: "#D4D4D4")
        static let punctuation = NSColor(hex: "#808080")
        static let plain = NSColor(hex: "#CCCCCC")
    }

    static func nsColor(for tokenName: String) -> NSColor {
        switch tokenName {
        case "keyword", "keyword.control", "keyword.function", "keyword.operator":
            return NS.keyword
        case "string", "string.special":
            return NS.string
        case "number", "constant.numeric":
            return NS.number
        case "comment", "comment.line", "comment.block":
            return NS.comment
        case "function", "function.call", "function.method":
            return NS.function
        case "type", "type.builtin", "class", "struct", "enum":
            return NS.type
        case "variable", "variable.parameter":
            return NS.variable
        case "property", "attribute":
            return NS.property
        case "operator":
            return NS.operator
        case "punctuation", "punctuation.bracket", "punctuation.delimiter":
            return NS.punctuation
        default:
            return NS.plain
        }
    }
}

struct SyntaxTheme {
    static let `default` = SyntaxTheme()

    let defaultColor = SyntaxColors.NS.plain

    func color(for tokenName: String) -> NSColor? {
        // TreeSitter 토큰 이름 매핑
        if tokenName.hasPrefix("keyword") { return SyntaxColors.NS.keyword }
        if tokenName.hasPrefix("string") { return SyntaxColors.NS.string }
        if tokenName.hasPrefix("number") || tokenName.hasPrefix("constant.numeric") { return SyntaxColors.NS.number }
        if tokenName.hasPrefix("comment") { return SyntaxColors.NS.comment }
        if tokenName.hasPrefix("function") || tokenName.hasPrefix("method") { return SyntaxColors.NS.function }
        if tokenName.hasPrefix("type") || tokenName.hasPrefix("class") || tokenName.hasPrefix("struct") { return SyntaxColors.NS.type }
        if tokenName.hasPrefix("variable") || tokenName.hasPrefix("identifier") { return SyntaxColors.NS.variable }
        if tokenName.hasPrefix("property") || tokenName.hasPrefix("attribute") { return SyntaxColors.NS.property }
        if tokenName.hasPrefix("operator") { return SyntaxColors.NS.operator }
        if tokenName.hasPrefix("punctuation") { return SyntaxColors.NS.punctuation }
        return nil
    }
}

enum TerminalColors {
    static let black = Color(hex: "#1E1E1E")
    static let red = Color(hex: "#CD3131")
    static let green = Color(hex: "#0DBC79")
    static let yellow = Color(hex: "#E5E510")
    static let blue = Color(hex: "#2472C8")
    static let magenta = Color(hex: "#BC3FBC")
    static let cyan = Color(hex: "#11A8CD")
    static let white = Color(hex: "#E5E5E5")

    static let brightBlack = Color(hex: "#666666")
    static let brightRed = Color(hex: "#F14C4C")
    static let brightGreen = Color(hex: "#23D18B")
    static let brightYellow = Color(hex: "#F5F543")
    static let brightBlue = Color(hex: "#3B8EEA")
    static let brightMagenta = Color(hex: "#D670D6")
    static let brightCyan = Color(hex: "#29B8DB")
    static let brightWhite = Color(hex: "#FFFFFF")

    enum NS {
        static let black = NSColor(hex: "#1E1E1E")
        static let red = NSColor(hex: "#CD3131")
        static let green = NSColor(hex: "#0DBC79")
        static let yellow = NSColor(hex: "#E5E510")
        static let blue = NSColor(hex: "#2472C8")
        static let magenta = NSColor(hex: "#BC3FBC")
        static let cyan = NSColor(hex: "#11A8CD")
        static let white = NSColor(hex: "#E5E5E5")

        static let brightBlack = NSColor(hex: "#666666")
        static let brightRed = NSColor(hex: "#F14C4C")
        static let brightGreen = NSColor(hex: "#23D18B")
        static let brightYellow = NSColor(hex: "#F5F543")
        static let brightBlue = NSColor(hex: "#3B8EEA")
        static let brightMagenta = NSColor(hex: "#D670D6")
        static let brightCyan = NSColor(hex: "#29B8DB")
        static let brightWhite = NSColor(hex: "#FFFFFF")
    }
}
