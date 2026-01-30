import Foundation

enum GoLang: KeywordBasedLanguage {
    static let id: Language = .go
    static let extensions: Set<String> = ["go"]

    static let keywords = LanguageKeywords(
        declaration: [
            "func", "var", "const", "type", "struct", "interface", "package", "import"
        ],
        control: [
            "if", "else", "switch", "case", "default", "for", "range",
            "return", "break", "continue", "goto", "fallthrough", "select"
        ],
        modifier: ["defer", "go"],
        operator: [],
        other: [
            "chan", "map", "make", "new", "len", "cap", "append", "copy",
            "delete", "close", "panic", "recover", "print", "println"
        ],
        boolean: ["true", "false"],
        null: ["nil"],
        types: [
            "int", "int8", "int16", "int32", "int64",
            "uint", "uint8", "uint16", "uint32", "uint64", "uintptr",
            "float32", "float64", "complex64", "complex128",
            "bool", "byte", "rune", "string", "error", "any"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~:"),
        singleQuoteStrings: true,
        backtickStrings: true,
        multilineStrings: true
    )
}
