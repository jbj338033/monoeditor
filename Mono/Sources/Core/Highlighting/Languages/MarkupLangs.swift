import Foundation

enum HTMLLang: KeywordBasedLanguage {
    static let id: Language = .html
    static let extensions: Set<String> = ["html", "htm"]

    static let keywords = LanguageKeywords(
        declaration: [],
        control: [],
        modifier: [],
        operator: [],
        other: [],
        boolean: ["true", "false"],
        null: [],
        types: []
    )

    static let options = LanguageOptions(
        operatorChars: Set("="),
        singleQuoteStrings: true,
        htmlComments: true
    )
}

enum XMLLang: KeywordBasedLanguage {
    static let id: Language = .xml
    static let extensions: Set<String> = ["xml", "plist"]

    static let keywords = LanguageKeywords(
        declaration: [],
        control: [],
        modifier: [],
        operator: [],
        other: [],
        boolean: ["true", "false"],
        null: [],
        types: []
    )

    static let options = LanguageOptions(
        operatorChars: Set("="),
        singleQuoteStrings: true,
        preprocessor: true,
        htmlComments: true
    )
}

enum CSSLang: KeywordBasedLanguage {
    static let id: Language = .css
    static let extensions: Set<String> = ["css", "scss", "sass"]

    static let keywords = LanguageKeywords(
        declaration: [],
        control: [
            "@import", "@media", "@keyframes", "@font-face", "@supports",
            "@charset", "@namespace", "@page", "@layer"
        ],
        modifier: ["!important"],
        operator: [],
        other: [
            "inherit", "initial", "unset", "revert", "none", "auto",
            "flex", "grid", "block", "inline", "inline-block", "hidden", "visible"
        ],
        boolean: [],
        null: [],
        types: []
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%:;,>~"),
        singleQuoteStrings: true
    )
}

enum JSONLang: KeywordBasedLanguage {
    static let id: Language = .json
    static let extensions: Set<String> = ["json"]

    static let keywords = LanguageKeywords(
        declaration: [],
        control: [],
        modifier: [],
        operator: [],
        other: [],
        boolean: ["true", "false"],
        null: ["null"],
        types: []
    )

    static let options = LanguageOptions(
        operatorChars: Set(":,")
    )
}

enum YAMLLang: KeywordBasedLanguage {
    static let id: Language = .yaml
    static let extensions: Set<String> = ["yaml", "yml"]

    static let keywords = LanguageKeywords(
        declaration: [],
        control: [],
        modifier: [],
        operator: [],
        other: [],
        boolean: ["true", "false", "yes", "no", "on", "off"],
        null: ["null", "~"],
        types: []
    )

    static let options = LanguageOptions(
        operatorChars: Set(":-|>"),
        singleQuoteStrings: true,
        multilineStrings: true,
        hashComments: true
    )
}
