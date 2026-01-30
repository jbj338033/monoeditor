import Foundation

enum SwiftLang: KeywordBasedLanguage {
    static let id: Language = .swift
    static let extensions: Set<String> = ["swift"]

    static let keywords = LanguageKeywords(
        declaration: [
            "func", "var", "let", "class", "struct", "enum", "protocol", "extension",
            "typealias", "associatedtype", "init", "deinit", "subscript", "operator",
            "precedencegroup", "import", "actor", "macro"
        ],
        control: [
            "if", "else", "guard", "switch", "case", "default", "for", "while",
            "repeat", "do", "return", "throw", "throws", "rethrows", "try", "catch",
            "break", "continue", "fallthrough", "defer", "where"
        ],
        modifier: [
            "public", "private", "internal", "fileprivate", "open",
            "static", "final", "override", "mutating", "nonmutating",
            "lazy", "weak", "unowned", "required", "optional", "convenience",
            "dynamic", "indirect", "nonisolated", "isolated", "consuming", "borrowing"
        ],
        operator: ["is", "as", "in", "inout"],
        other: [
            "self", "Self", "super", "async", "await", "some", "any", "get", "set",
            "willSet", "didSet", "_", "Type", "Protocol"
        ],
        boolean: ["true", "false"],
        null: ["nil"],
        types: [
            "Int", "Int8", "Int16", "Int32", "Int64",
            "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
            "Float", "Double", "Bool", "String", "Character",
            "Array", "Dictionary", "Set", "Optional", "Result",
            "Any", "AnyObject", "Void", "Never"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        multilineStrings: true,
        attributes: true,
        preprocessor: true
    )
}
