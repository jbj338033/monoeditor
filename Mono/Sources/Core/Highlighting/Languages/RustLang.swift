import Foundation

enum RustLang: KeywordBasedLanguage {
    static let id: Language = .rust
    static let extensions: Set<String> = ["rs"]

    static let keywords = LanguageKeywords(
        declaration: [
            "fn", "let", "const", "static", "struct", "enum", "trait", "impl",
            "type", "mod", "use", "crate", "extern", "macro_rules"
        ],
        control: [
            "if", "else", "match", "loop", "while", "for", "in",
            "return", "break", "continue", "yield"
        ],
        modifier: ["pub", "mut", "unsafe", "async", "await", "move", "dyn", "where"],
        operator: ["as", "ref"],
        other: ["self", "Self", "super"],
        boolean: ["true", "false"],
        null: ["None"],
        types: [
            "i8", "i16", "i32", "i64", "i128", "isize",
            "u8", "u16", "u32", "u64", "u128", "usize",
            "f32", "f64", "bool", "char", "str",
            "String", "Vec", "Box", "Rc", "Arc", "Cell", "RefCell",
            "Option", "Result", "Some", "Ok", "Err"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:.@#"),
        singleQuoteStrings: true,
        multilineStrings: true,
        attributes: true
    )
}
