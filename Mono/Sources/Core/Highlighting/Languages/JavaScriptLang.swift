import Foundation

enum JavaScriptLang: KeywordBasedLanguage {
    static let id: Language = .javascript
    static let extensions: Set<String> = ["js", "mjs", "cjs", "jsx"]

    static let keywords = LanguageKeywords(
        declaration: ["function", "class", "const", "let", "var"],
        control: [
            "if", "else", "switch", "case", "default", "for", "while", "do",
            "return", "throw", "try", "catch", "finally", "break", "continue", "with"
        ],
        modifier: ["async", "await", "static", "get", "set"],
        operator: ["typeof", "instanceof", "void", "delete", "in", "of", "new"],
        other: [
            "this", "super", "import", "export", "from", "default", "as",
            "extends", "yield", "debugger"
        ],
        boolean: ["true", "false"],
        null: ["null", "undefined", "NaN", "Infinity"],
        types: [
            "Object", "Array", "String", "Number", "Boolean", "Function",
            "Symbol", "BigInt", "Map", "Set", "WeakMap", "WeakSet",
            "Promise", "Proxy", "Reflect", "Date", "RegExp", "Error",
            "JSON", "Math", "console"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        singleQuoteStrings: true,
        backtickStrings: true,
        multilineStrings: true
    )
}

enum TypeScriptLang: KeywordBasedLanguage {
    static let id: Language = .typescript
    static let extensions: Set<String> = ["ts", "tsx"]

    static var keywords: LanguageKeywords {
        var kw = JavaScriptLang.keywords
        kw.declaration.formUnion(["interface", "type", "enum", "namespace", "module", "declare"])
        kw.modifier.formUnion(["public", "private", "protected", "readonly", "abstract", "override"])
        kw.operator.formUnion(["is", "as", "keyof", "infer"])
        kw.other.formUnion(["implements"])
        kw.types.formUnion([
            "any", "unknown", "never", "void", "string", "number", "boolean",
            "object", "symbol", "bigint", "Partial", "Required", "Readonly",
            "Record", "Pick", "Omit", "Exclude", "Extract", "NonNullable"
        ])
        return kw
    }

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        singleQuoteStrings: true,
        backtickStrings: true,
        multilineStrings: true,
        attributes: true
    )
}
