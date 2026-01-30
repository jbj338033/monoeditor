import Foundation

enum JavaLang: KeywordBasedLanguage {
    static let id: Language = .java
    static let extensions: Set<String> = ["java"]

    static let keywords = LanguageKeywords(
        declaration: ["class", "interface", "enum", "record", "void", "package", "import"],
        control: [
            "if", "else", "switch", "case", "default", "for", "while", "do",
            "return", "throw", "throws", "try", "catch", "finally",
            "break", "continue", "assert"
        ],
        modifier: [
            "public", "private", "protected", "static", "final", "abstract",
            "synchronized", "volatile", "transient", "native", "strictfp",
            "sealed", "non-sealed", "permits"
        ],
        operator: ["instanceof", "new"],
        other: ["this", "super", "extends", "implements"],
        boolean: ["true", "false"],
        null: ["null"],
        types: [
            "int", "long", "short", "byte", "float", "double", "boolean", "char",
            "Integer", "Long", "Short", "Byte", "Float", "Double", "Boolean", "Character",
            "String", "Object", "Class", "System", "Exception", "Throwable",
            "List", "ArrayList", "Map", "HashMap", "Set", "HashSet"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:"),
        singleQuoteStrings: true,
        multilineStrings: true,
        attributes: true
    )
}

enum KotlinLang: KeywordBasedLanguage {
    static let id: Language = .kotlin
    static let extensions: Set<String> = ["kt", "kts"]

    static let keywords = LanguageKeywords(
        declaration: [
            "fun", "val", "var", "class", "interface", "object", "enum", "sealed",
            "data", "annotation", "typealias", "package", "import"
        ],
        control: [
            "if", "else", "when", "for", "while", "do",
            "return", "throw", "try", "catch", "finally", "break", "continue"
        ],
        modifier: [
            "public", "private", "protected", "internal", "open", "final",
            "abstract", "override", "lateinit", "lazy", "inline", "noinline",
            "crossinline", "reified", "suspend", "tailrec", "operator", "infix",
            "external", "const", "companion"
        ],
        operator: ["is", "as", "in", "!in"],
        other: [
            "this", "super", "constructor", "init", "get", "set", "field",
            "by", "where", "out", "vararg"
        ],
        boolean: ["true", "false"],
        null: ["null"],
        types: [
            "Int", "Long", "Short", "Byte", "Float", "Double", "Boolean", "Char",
            "String", "Any", "Unit", "Nothing",
            "List", "MutableList", "Map", "MutableMap", "Set", "MutableSet",
            "Array", "Pair", "Triple"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        singleQuoteStrings: true,
        multilineStrings: true,
        attributes: true
    )
}

enum CLang: KeywordBasedLanguage {
    static let id: Language = .c
    static let extensions: Set<String> = ["c", "h"]

    static let keywords = LanguageKeywords(
        declaration: ["void", "struct", "union", "enum", "typedef"],
        control: [
            "if", "else", "switch", "case", "default", "for", "while", "do",
            "return", "break", "continue", "goto"
        ],
        modifier: [
            "static", "extern", "const", "volatile", "register", "inline",
            "restrict", "auto", "signed", "unsigned"
        ],
        operator: ["sizeof"],
        other: [],
        boolean: ["true", "false"],
        null: ["NULL"],
        types: ["int", "long", "short", "char", "float", "double", "void", "size_t", "ptrdiff_t", "FILE"]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        singleQuoteStrings: true,
        preprocessor: true
    )
}

enum CppLang: KeywordBasedLanguage {
    static let id: Language = .cpp
    static let extensions: Set<String> = ["cpp", "cc", "cxx", "hpp", "hxx"]

    static var keywords: LanguageKeywords {
        var kw = CLang.keywords
        kw.declaration.formUnion(["class", "namespace", "template", "using", "concept", "requires"])
        kw.control.formUnion(["try", "catch", "throw"])
        kw.modifier.formUnion([
            "virtual", "override", "final", "explicit", "friend", "mutable",
            "constexpr", "consteval", "constinit", "thread_local"
        ])
        kw.operator.formUnion(["new", "delete", "typeid", "decltype", "noexcept", "co_await", "co_yield", "co_return"])
        kw.other.formUnion(["this", "public", "private", "protected"])
        kw.null.formUnion(["nullptr"])
        kw.types.formUnion(["bool", "wchar_t", "string", "vector", "map", "set", "unique_ptr", "shared_ptr", "auto"])
        return kw
    }

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        singleQuoteStrings: true,
        multilineStrings: true,
        attributes: true,
        preprocessor: true
    )
}

enum CSharpLang: KeywordBasedLanguage {
    static let id: Language = .csharp
    static let extensions: Set<String> = ["cs"]

    static let keywords = LanguageKeywords(
        declaration: [
            "class", "struct", "interface", "enum", "record", "delegate",
            "namespace", "using", "void", "event"
        ],
        control: [
            "if", "else", "switch", "case", "default", "for", "foreach",
            "while", "do", "return", "throw", "try", "catch", "finally",
            "break", "continue", "goto", "yield", "lock", "checked", "unchecked"
        ],
        modifier: [
            "public", "private", "protected", "internal", "static", "readonly",
            "const", "volatile", "virtual", "override", "abstract", "sealed",
            "extern", "unsafe", "partial", "async", "ref", "out", "in", "params"
        ],
        operator: ["is", "as", "new", "typeof", "sizeof", "nameof", "stackalloc", "await"],
        other: [
            "this", "base", "get", "set", "init", "add", "remove", "value",
            "where", "when", "var", "dynamic"
        ],
        boolean: ["true", "false"],
        null: ["null"],
        types: [
            "int", "long", "short", "byte", "sbyte", "uint", "ulong", "ushort",
            "float", "double", "decimal", "bool", "char", "string", "object",
            "void", "nint", "nuint",
            "String", "Object", "List", "Dictionary", "Task", "Action", "Func"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        singleQuoteStrings: true,
        multilineStrings: true,
        attributes: true,
        preprocessor: true
    )
}
