import Foundation

enum PythonLang: KeywordBasedLanguage {
    static let id: Language = .python
    static let extensions: Set<String> = ["py", "pyw"]

    static let keywords = LanguageKeywords(
        declaration: ["def", "class", "lambda"],
        control: [
            "if", "elif", "else", "for", "while", "with", "try", "except",
            "finally", "raise", "return", "yield", "break", "continue", "pass",
            "match", "case"
        ],
        modifier: ["global", "nonlocal", "async", "await"],
        operator: ["and", "or", "not", "is", "in"],
        other: ["import", "from", "as", "assert", "del", "self", "cls"],
        boolean: ["True", "False"],
        null: ["None"],
        types: [
            "int", "float", "str", "bool", "list", "dict", "set", "tuple",
            "bytes", "bytearray", "complex", "frozenset", "range", "type",
            "object", "Exception", "BaseException"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~@:"),
        singleQuoteStrings: true,
        multilineStrings: true,
        attributes: true,
        hashComments: true
    )
}
