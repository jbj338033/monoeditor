import Foundation

protocol LanguageDefinition: Sendable {
    static var id: Language { get }
    static var extensions: Set<String> { get }

    static func tokenize(_ source: String) -> [Token]
}

extension LanguageDefinition {
    static func matches(extension ext: String) -> Bool {
        extensions.contains(ext.lowercased())
    }
}

protocol KeywordBasedLanguage: LanguageDefinition {
    static var keywords: LanguageKeywords { get }
    static var options: LanguageOptions { get }
}

extension KeywordBasedLanguage {
    static func tokenize(_ source: String) -> [Token] {
        KeywordLexer(source: source, keywords: keywords, options: options).tokenize()
    }
}

struct LanguageKeywords: Sendable {
    var declaration: Set<String> = []
    var control: Set<String> = []
    var modifier: Set<String> = []
    var `operator`: Set<String> = []
    var other: Set<String> = []
    var boolean: Set<String> = []
    var null: Set<String> = []
    var types: Set<String> = []

    var allKeywords: Set<String> {
        declaration.union(control).union(modifier).union(`operator`).union(other)
    }
}

struct LanguageOptions: Sendable {
    var operatorChars: Set<Character> = Set("+-*/%=<>!&|^~?:.")
    var singleQuoteStrings: Bool = false
    var backtickStrings: Bool = false
    var multilineStrings: Bool = false
    var attributes: Bool = false
    var preprocessor: Bool = false
    var hashComments: Bool = false
    var htmlComments: Bool = false
}

enum LanguageRegistry {
    private static let languages: [any LanguageDefinition.Type] = [
        SwiftLang.self,
        JavaScriptLang.self,
        TypeScriptLang.self,
        PythonLang.self,
        GoLang.self,
        RustLang.self,
        JavaLang.self,
        KotlinLang.self,
        CLang.self,
        CppLang.self,
        CSharpLang.self,
        RubyLang.self,
        PHPLang.self,
        HTMLLang.self,
        CSSLang.self,
        JSONLang.self,
        YAMLLang.self,
        XMLLang.self,
        MarkdownLang.self,
        SQLLang.self,
        ShellLang.self,
        DockerfileLang.self,
    ]

    static func language(for ext: String) -> (any LanguageDefinition.Type)? {
        languages.first { $0.matches(extension: ext) }
    }

    static func tokenize(_ source: String, language: Language?) -> [Token] {
        guard let lang = language,
              let definition = languages.first(where: { $0.id == lang }) else {
            return PlainTextLang.tokenize(source)
        }
        return definition.tokenize(source)
    }
}

enum PlainTextLang: LanguageDefinition {
    static let id: Language = .swift
    static let extensions: Set<String> = []

    static func tokenize(_ source: String) -> [Token] {
        guard !source.isEmpty else { return [] }
        let range = source.startIndex..<source.endIndex
        return [Token(type: .plain, range: range)]
    }
}
