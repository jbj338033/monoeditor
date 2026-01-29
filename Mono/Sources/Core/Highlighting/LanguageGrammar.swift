import Foundation

// MARK: - Language Grammar

/// 언어별 문법 정의 - 키워드, 연산자, 특수 규칙
struct LanguageGrammar: Sendable {
    let language: Language

    // Keywords by category
    let declarationKeywords: Set<String>
    let controlKeywords: Set<String>
    let operatorKeywords: Set<String>
    let modifierKeywords: Set<String>
    let otherKeywords: Set<String>

    // Literals
    let booleanLiterals: Set<String>
    let nilLiterals: Set<String>

    // Types
    let builtinTypes: Set<String>

    // Operators
    let operatorChars: Set<Character>

    // Language features
    let supportsSingleQuoteStrings: Bool
    let supportsBacktickStrings: Bool
    let supportsMultilineStrings: Bool
    let supportsAttributes: Bool
    let supportsPreprocessor: Bool
}

// MARK: - Grammar Factory

extension LanguageGrammar {
    static func grammar(for language: Language) -> LanguageGrammar {
        switch language {
        case .swift:
            return .swift
        case .javascript:
            return .javascript
        case .typescript:
            return .typescript
        case .python:
            return .python
        case .go:
            return .go
        case .rust:
            return .rust
        case .java:
            return .java
        case .kotlin:
            return .kotlin
        case .c:
            return .c
        case .cpp:
            return .cpp
        case .csharp:
            return .csharp
        case .ruby:
            return .ruby
        case .php:
            return .php
        case .html:
            return .html
        case .css, .scss:
            return .css
        case .json:
            return .json
        case .yaml:
            return .yaml
        case .xml:
            return .xml
        case .markdown:
            return .markdown
        case .sql:
            return .sql
        case .shell:
            return .shell
        case .dockerfile:
            return .dockerfile
        }
    }
}

// MARK: - Swift Grammar

extension LanguageGrammar {
    static let swift = LanguageGrammar(
        language: .swift,
        declarationKeywords: [
            "func", "var", "let", "class", "struct", "enum", "protocol", "extension",
            "typealias", "associatedtype", "init", "deinit", "subscript", "operator",
            "precedencegroup", "import", "actor", "macro"
        ],
        controlKeywords: [
            "if", "else", "guard", "switch", "case", "default", "for", "while",
            "repeat", "do", "return", "throw", "throws", "rethrows", "try", "catch",
            "break", "continue", "fallthrough", "defer", "where"
        ],
        operatorKeywords: [
            "is", "as", "in", "inout"
        ],
        modifierKeywords: [
            "public", "private", "internal", "fileprivate", "open",
            "static", "final", "override", "mutating", "nonmutating",
            "lazy", "weak", "unowned", "required", "optional", "convenience",
            "dynamic", "indirect", "nonisolated", "isolated", "consuming", "borrowing"
        ],
        otherKeywords: [
            "self", "Self", "super", "async", "await", "some", "any", "get", "set",
            "willSet", "didSet", "_", "Type", "Protocol"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["nil"],
        builtinTypes: [
            "Int", "Int8", "Int16", "Int32", "Int64",
            "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
            "Float", "Double", "Bool", "String", "Character",
            "Array", "Dictionary", "Set", "Optional", "Result",
            "Any", "AnyObject", "Void", "Never"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        supportsSingleQuoteStrings: false,
        supportsBacktickStrings: false,
        supportsMultilineStrings: true,
        supportsAttributes: true,
        supportsPreprocessor: true
    )
}

// MARK: - JavaScript Grammar

extension LanguageGrammar {
    static let javascript = LanguageGrammar(
        language: .javascript,
        declarationKeywords: [
            "function", "class", "const", "let", "var"
        ],
        controlKeywords: [
            "if", "else", "switch", "case", "default", "for", "while", "do",
            "return", "throw", "try", "catch", "finally", "break", "continue",
            "with"
        ],
        operatorKeywords: [
            "typeof", "instanceof", "void", "delete", "in", "of", "new"
        ],
        modifierKeywords: [
            "async", "await", "static", "get", "set"
        ],
        otherKeywords: [
            "this", "super", "import", "export", "from", "default", "as",
            "extends", "yield", "debugger"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["null", "undefined", "NaN", "Infinity"],
        builtinTypes: [
            "Object", "Array", "String", "Number", "Boolean", "Function",
            "Symbol", "BigInt", "Map", "Set", "WeakMap", "WeakSet",
            "Promise", "Proxy", "Reflect", "Date", "RegExp", "Error",
            "JSON", "Math", "console"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: true,
        supportsMultilineStrings: true,
        supportsAttributes: false,
        supportsPreprocessor: false
    )

    static let typescript = LanguageGrammar(
        language: .typescript,
        declarationKeywords: javascript.declarationKeywords.union([
            "interface", "type", "enum", "namespace", "module", "declare"
        ]),
        controlKeywords: javascript.controlKeywords,
        operatorKeywords: javascript.operatorKeywords.union(["is", "as", "keyof", "infer"]),
        modifierKeywords: javascript.modifierKeywords.union([
            "public", "private", "protected", "readonly", "abstract", "override"
        ]),
        otherKeywords: javascript.otherKeywords.union(["implements"]),
        booleanLiterals: javascript.booleanLiterals,
        nilLiterals: javascript.nilLiterals,
        builtinTypes: javascript.builtinTypes.union([
            "any", "unknown", "never", "void", "string", "number", "boolean",
            "object", "symbol", "bigint", "Partial", "Required", "Readonly",
            "Record", "Pick", "Omit", "Exclude", "Extract", "NonNullable",
            "Parameters", "ReturnType", "InstanceType"
        ]),
        operatorChars: javascript.operatorChars,
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: true,
        supportsMultilineStrings: true,
        supportsAttributes: true,  // Decorators
        supportsPreprocessor: false
    )
}

// MARK: - Python Grammar

extension LanguageGrammar {
    static let python = LanguageGrammar(
        language: .python,
        declarationKeywords: [
            "def", "class", "lambda"
        ],
        controlKeywords: [
            "if", "elif", "else", "for", "while", "with", "try", "except",
            "finally", "raise", "return", "yield", "break", "continue", "pass",
            "match", "case"
        ],
        operatorKeywords: [
            "and", "or", "not", "is", "in"
        ],
        modifierKeywords: [
            "global", "nonlocal", "async", "await"
        ],
        otherKeywords: [
            "import", "from", "as", "assert", "del", "self", "cls"
        ],
        booleanLiterals: ["True", "False"],
        nilLiterals: ["None"],
        builtinTypes: [
            "int", "float", "str", "bool", "list", "dict", "set", "tuple",
            "bytes", "bytearray", "complex", "frozenset", "range", "type",
            "object", "Exception", "BaseException"
        ],
        operatorChars: Set("+-*/%=<>!&|^~@:"),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: true,
        supportsAttributes: true,  // Decorators
        supportsPreprocessor: false
    )
}

// MARK: - Go Grammar

extension LanguageGrammar {
    static let go = LanguageGrammar(
        language: .go,
        declarationKeywords: [
            "func", "var", "const", "type", "struct", "interface", "package", "import"
        ],
        controlKeywords: [
            "if", "else", "switch", "case", "default", "for", "range",
            "return", "break", "continue", "goto", "fallthrough", "select"
        ],
        operatorKeywords: [],
        modifierKeywords: [
            "defer", "go"
        ],
        otherKeywords: [
            "chan", "map", "make", "new", "len", "cap", "append", "copy",
            "delete", "close", "panic", "recover", "print", "println"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["nil"],
        builtinTypes: [
            "int", "int8", "int16", "int32", "int64",
            "uint", "uint8", "uint16", "uint32", "uint64", "uintptr",
            "float32", "float64", "complex64", "complex128",
            "bool", "byte", "rune", "string", "error", "any"
        ],
        operatorChars: Set("+-*/%=<>!&|^~:"),
        supportsSingleQuoteStrings: true,  // rune literals
        supportsBacktickStrings: true,     // raw strings
        supportsMultilineStrings: true,
        supportsAttributes: false,
        supportsPreprocessor: false
    )
}

// MARK: - Rust Grammar

extension LanguageGrammar {
    static let rust = LanguageGrammar(
        language: .rust,
        declarationKeywords: [
            "fn", "let", "const", "static", "struct", "enum", "trait", "impl",
            "type", "mod", "use", "crate", "extern", "macro_rules"
        ],
        controlKeywords: [
            "if", "else", "match", "loop", "while", "for", "in",
            "return", "break", "continue", "yield"
        ],
        operatorKeywords: [
            "as", "ref"
        ],
        modifierKeywords: [
            "pub", "mut", "unsafe", "async", "await", "move", "dyn", "where"
        ],
        otherKeywords: [
            "self", "Self", "super"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["None"],
        builtinTypes: [
            "i8", "i16", "i32", "i64", "i128", "isize",
            "u8", "u16", "u32", "u64", "u128", "usize",
            "f32", "f64", "bool", "char", "str",
            "String", "Vec", "Box", "Rc", "Arc", "Cell", "RefCell",
            "Option", "Result", "Some", "Ok", "Err"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:.@#"),
        supportsSingleQuoteStrings: true,  // char literals
        supportsBacktickStrings: false,
        supportsMultilineStrings: true,
        supportsAttributes: true,
        supportsPreprocessor: false
    )
}

// MARK: - Java Grammar

extension LanguageGrammar {
    static let java = LanguageGrammar(
        language: .java,
        declarationKeywords: [
            "class", "interface", "enum", "record", "void", "package", "import"
        ],
        controlKeywords: [
            "if", "else", "switch", "case", "default", "for", "while", "do",
            "return", "throw", "throws", "try", "catch", "finally",
            "break", "continue", "assert"
        ],
        operatorKeywords: [
            "instanceof", "new"
        ],
        modifierKeywords: [
            "public", "private", "protected", "static", "final", "abstract",
            "synchronized", "volatile", "transient", "native", "strictfp",
            "sealed", "non-sealed", "permits"
        ],
        otherKeywords: [
            "this", "super", "extends", "implements"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["null"],
        builtinTypes: [
            "int", "long", "short", "byte", "float", "double", "boolean", "char",
            "Integer", "Long", "Short", "Byte", "Float", "Double", "Boolean", "Character",
            "String", "Object", "Class", "System", "Exception", "Throwable",
            "List", "ArrayList", "Map", "HashMap", "Set", "HashSet"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:"),
        supportsSingleQuoteStrings: true,  // char literals
        supportsBacktickStrings: false,
        supportsMultilineStrings: true,  // text blocks
        supportsAttributes: true,  // annotations
        supportsPreprocessor: false
    )

    static let kotlin = LanguageGrammar(
        language: .kotlin,
        declarationKeywords: [
            "fun", "val", "var", "class", "interface", "object", "enum", "sealed",
            "data", "annotation", "typealias", "package", "import"
        ],
        controlKeywords: [
            "if", "else", "when", "for", "while", "do",
            "return", "throw", "try", "catch", "finally",
            "break", "continue"
        ],
        operatorKeywords: [
            "is", "as", "in", "!in"
        ],
        modifierKeywords: [
            "public", "private", "protected", "internal", "open", "final",
            "abstract", "override", "lateinit", "lazy", "inline", "noinline",
            "crossinline", "reified", "suspend", "tailrec", "operator", "infix",
            "external", "const", "companion"
        ],
        otherKeywords: [
            "this", "super", "constructor", "init", "get", "set", "field",
            "by", "where", "out", "vararg"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["null"],
        builtinTypes: [
            "Int", "Long", "Short", "Byte", "Float", "Double", "Boolean", "Char",
            "String", "Any", "Unit", "Nothing",
            "List", "MutableList", "Map", "MutableMap", "Set", "MutableSet",
            "Array", "Pair", "Triple"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: true,
        supportsAttributes: true,
        supportsPreprocessor: false
    )
}

// MARK: - C/C++/C# Grammars

extension LanguageGrammar {
    static let c = LanguageGrammar(
        language: .c,
        declarationKeywords: [
            "void", "struct", "union", "enum", "typedef"
        ],
        controlKeywords: [
            "if", "else", "switch", "case", "default", "for", "while", "do",
            "return", "break", "continue", "goto"
        ],
        operatorKeywords: [
            "sizeof"
        ],
        modifierKeywords: [
            "static", "extern", "const", "volatile", "register", "inline",
            "restrict", "auto", "signed", "unsigned"
        ],
        otherKeywords: [],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["NULL"],
        builtinTypes: [
            "int", "long", "short", "char", "float", "double", "void",
            "size_t", "ptrdiff_t", "FILE"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: false,
        supportsAttributes: false,
        supportsPreprocessor: true
    )

    static let cpp = LanguageGrammar(
        language: .cpp,
        declarationKeywords: c.declarationKeywords.union([
            "class", "namespace", "template", "using", "concept", "requires"
        ]),
        controlKeywords: c.controlKeywords.union([
            "try", "catch", "throw"
        ]),
        operatorKeywords: c.operatorKeywords.union([
            "new", "delete", "typeid", "decltype", "sizeof", "alignof",
            "noexcept", "co_await", "co_yield", "co_return"
        ]),
        modifierKeywords: c.modifierKeywords.union([
            "virtual", "override", "final", "explicit", "friend", "mutable",
            "constexpr", "consteval", "constinit", "thread_local"
        ]),
        otherKeywords: [
            "this", "public", "private", "protected"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["nullptr", "NULL"],
        builtinTypes: c.builtinTypes.union([
            "bool", "wchar_t", "char8_t", "char16_t", "char32_t",
            "string", "vector", "map", "set", "unique_ptr", "shared_ptr",
            "auto"
        ]),
        operatorChars: c.operatorChars,
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: true,
        supportsAttributes: true,
        supportsPreprocessor: true
    )

    static let csharp = LanguageGrammar(
        language: .csharp,
        declarationKeywords: [
            "class", "struct", "interface", "enum", "record", "delegate",
            "namespace", "using", "void", "event"
        ],
        controlKeywords: [
            "if", "else", "switch", "case", "default", "for", "foreach",
            "while", "do", "return", "throw", "try", "catch", "finally",
            "break", "continue", "goto", "yield", "lock", "checked", "unchecked"
        ],
        operatorKeywords: [
            "is", "as", "new", "typeof", "sizeof", "nameof", "stackalloc",
            "await"
        ],
        modifierKeywords: [
            "public", "private", "protected", "internal", "static", "readonly",
            "const", "volatile", "virtual", "override", "abstract", "sealed",
            "extern", "unsafe", "partial", "async", "ref", "out", "in", "params"
        ],
        otherKeywords: [
            "this", "base", "get", "set", "init", "add", "remove", "value",
            "where", "when", "var", "dynamic"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["null"],
        builtinTypes: [
            "int", "long", "short", "byte", "sbyte", "uint", "ulong", "ushort",
            "float", "double", "decimal", "bool", "char", "string", "object",
            "void", "nint", "nuint",
            "String", "Object", "List", "Dictionary", "Task", "Action", "Func"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:."),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: true,
        supportsAttributes: true,
        supportsPreprocessor: true
    )
}

// MARK: - Ruby Grammar

extension LanguageGrammar {
    static let ruby = LanguageGrammar(
        language: .ruby,
        declarationKeywords: [
            "def", "class", "module", "attr_reader", "attr_writer", "attr_accessor"
        ],
        controlKeywords: [
            "if", "elsif", "else", "unless", "case", "when", "for", "while",
            "until", "do", "begin", "end", "return", "raise", "rescue", "ensure",
            "retry", "break", "next", "redo", "then"
        ],
        operatorKeywords: [
            "and", "or", "not", "defined?"
        ],
        modifierKeywords: [
            "public", "private", "protected", "yield", "super", "self"
        ],
        otherKeywords: [
            "require", "require_relative", "include", "extend", "prepend",
            "alias", "lambda", "proc", "__FILE__", "__LINE__", "__ENCODING__"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["nil"],
        builtinTypes: [
            "String", "Integer", "Float", "Array", "Hash", "Symbol", "Range",
            "Regexp", "Time", "File", "IO", "Exception", "Object", "Class", "Module"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:.@"),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: true,
        supportsMultilineStrings: true,
        supportsAttributes: false,
        supportsPreprocessor: false
    )
}

// MARK: - PHP Grammar

extension LanguageGrammar {
    static let php = LanguageGrammar(
        language: .php,
        declarationKeywords: [
            "function", "class", "interface", "trait", "enum", "namespace", "use"
        ],
        controlKeywords: [
            "if", "elseif", "else", "switch", "case", "default", "for", "foreach",
            "while", "do", "return", "throw", "try", "catch", "finally",
            "break", "continue", "yield", "match"
        ],
        operatorKeywords: [
            "instanceof", "new", "clone", "and", "or", "xor"
        ],
        modifierKeywords: [
            "public", "private", "protected", "static", "final", "abstract",
            "const", "readonly", "var"
        ],
        otherKeywords: [
            "echo", "print", "include", "include_once", "require", "require_once",
            "extends", "implements", "as", "global", "fn"
        ],
        booleanLiterals: ["true", "false", "TRUE", "FALSE"],
        nilLiterals: ["null", "NULL"],
        builtinTypes: [
            "int", "float", "string", "bool", "array", "object", "callable",
            "iterable", "void", "mixed", "never", "self", "static", "parent"
        ],
        operatorChars: Set("+-*/%=<>!&|^~?:.@$"),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: true,
        supportsMultilineStrings: true,
        supportsAttributes: true,
        supportsPreprocessor: false
    )
}

// MARK: - Markup & Data Grammars

extension LanguageGrammar {
    static let html = LanguageGrammar(
        language: .html,
        declarationKeywords: [],
        controlKeywords: [],
        operatorKeywords: [],
        modifierKeywords: [],
        otherKeywords: [
            "DOCTYPE", "html", "head", "body", "div", "span", "p", "a", "img",
            "ul", "ol", "li", "table", "tr", "td", "th", "form", "input",
            "button", "script", "style", "link", "meta", "title"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: [],
        builtinTypes: [],
        operatorChars: Set("="),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: false,
        supportsAttributes: false,
        supportsPreprocessor: false
    )

    static let xml = LanguageGrammar(
        language: .xml,
        declarationKeywords: [],
        controlKeywords: [],
        operatorKeywords: [],
        modifierKeywords: [],
        otherKeywords: [],
        booleanLiterals: ["true", "false"],
        nilLiterals: [],
        builtinTypes: [],
        operatorChars: Set("="),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: false,
        supportsAttributes: false,
        supportsPreprocessor: true  // <?xml ... ?>
    )

    static let css = LanguageGrammar(
        language: .css,
        declarationKeywords: [],
        controlKeywords: [
            "@import", "@media", "@keyframes", "@font-face", "@supports",
            "@charset", "@namespace", "@page", "@layer"
        ],
        operatorKeywords: [],
        modifierKeywords: [
            "!important"
        ],
        otherKeywords: [
            "inherit", "initial", "unset", "revert", "none", "auto",
            "flex", "grid", "block", "inline", "inline-block", "hidden", "visible"
        ],
        booleanLiterals: [],
        nilLiterals: [],
        builtinTypes: [],
        operatorChars: Set("+-*/%:;,>~"),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: false,
        supportsAttributes: false,
        supportsPreprocessor: false
    )

    static let json = LanguageGrammar(
        language: .json,
        declarationKeywords: [],
        controlKeywords: [],
        operatorKeywords: [],
        modifierKeywords: [],
        otherKeywords: [],
        booleanLiterals: ["true", "false"],
        nilLiterals: ["null"],
        builtinTypes: [],
        operatorChars: Set(":,"),
        supportsSingleQuoteStrings: false,
        supportsBacktickStrings: false,
        supportsMultilineStrings: false,
        supportsAttributes: false,
        supportsPreprocessor: false
    )

    static let yaml = LanguageGrammar(
        language: .yaml,
        declarationKeywords: [],
        controlKeywords: [],
        operatorKeywords: [],
        modifierKeywords: [],
        otherKeywords: [],
        booleanLiterals: ["true", "false", "yes", "no", "on", "off"],
        nilLiterals: ["null", "~"],
        builtinTypes: [],
        operatorChars: Set(":-|>"),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: true,
        supportsAttributes: false,
        supportsPreprocessor: false
    )

    static let markdown = LanguageGrammar(
        language: .markdown,
        declarationKeywords: [],
        controlKeywords: [],
        operatorKeywords: [],
        modifierKeywords: [],
        otherKeywords: [],
        booleanLiterals: [],
        nilLiterals: [],
        builtinTypes: [],
        operatorChars: Set("#*_`[]()!"),
        supportsSingleQuoteStrings: false,
        supportsBacktickStrings: true,
        supportsMultilineStrings: true,
        supportsAttributes: false,
        supportsPreprocessor: false
    )
}

// MARK: - SQL Grammar

extension LanguageGrammar {
    static let sql = LanguageGrammar(
        language: .sql,
        declarationKeywords: [
            "CREATE", "ALTER", "DROP", "TRUNCATE", "TABLE", "INDEX", "VIEW",
            "DATABASE", "SCHEMA", "PROCEDURE", "FUNCTION", "TRIGGER"
        ],
        controlKeywords: [
            "SELECT", "FROM", "WHERE", "JOIN", "INNER", "LEFT", "RIGHT", "OUTER",
            "ON", "GROUP", "BY", "HAVING", "ORDER", "ASC", "DESC", "LIMIT", "OFFSET",
            "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE",
            "UNION", "INTERSECT", "EXCEPT", "CASE", "WHEN", "THEN", "ELSE", "END",
            "IF", "BEGIN", "COMMIT", "ROLLBACK", "TRANSACTION"
        ],
        operatorKeywords: [
            "AND", "OR", "NOT", "IN", "EXISTS", "BETWEEN", "LIKE", "IS", "AS",
            "DISTINCT", "ALL", "ANY", "SOME"
        ],
        modifierKeywords: [
            "PRIMARY", "KEY", "FOREIGN", "REFERENCES", "UNIQUE", "NOT", "NULL",
            "DEFAULT", "AUTO_INCREMENT", "IDENTITY", "CHECK", "CONSTRAINT"
        ],
        otherKeywords: [
            "COUNT", "SUM", "AVG", "MIN", "MAX", "COALESCE", "NULLIF", "CAST",
            "CONVERT", "CONCAT", "SUBSTRING", "TRIM", "UPPER", "LOWER"
        ],
        booleanLiterals: ["TRUE", "FALSE"],
        nilLiterals: ["NULL"],
        builtinTypes: [
            "INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT",
            "DECIMAL", "NUMERIC", "FLOAT", "REAL", "DOUBLE",
            "VARCHAR", "CHAR", "TEXT", "NVARCHAR", "NCHAR",
            "DATE", "TIME", "DATETIME", "TIMESTAMP", "BOOLEAN", "BLOB"
        ],
        operatorChars: Set("+-*/%=<>!&|"),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: true,
        supportsMultilineStrings: false,
        supportsAttributes: false,
        supportsPreprocessor: false
    )
}

// MARK: - Shell Grammar

extension LanguageGrammar {
    static let shell = LanguageGrammar(
        language: .shell,
        declarationKeywords: [
            "function", "local", "declare", "typeset", "readonly", "export"
        ],
        controlKeywords: [
            "if", "then", "else", "elif", "fi", "case", "esac", "for", "while",
            "until", "do", "done", "in", "select", "break", "continue", "return",
            "exit"
        ],
        operatorKeywords: [],
        modifierKeywords: [],
        otherKeywords: [
            "echo", "printf", "read", "source", "alias", "unalias", "set", "unset",
            "shift", "eval", "exec", "trap", "wait", "cd", "pwd", "pushd", "popd",
            "test", "true", "false"
        ],
        booleanLiterals: ["true", "false"],
        nilLiterals: [],
        builtinTypes: [],
        operatorChars: Set("+-*/%=<>!&|;"),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: true,
        supportsMultilineStrings: false,
        supportsAttributes: false,
        supportsPreprocessor: false
    )

    static let dockerfile = LanguageGrammar(
        language: .dockerfile,
        declarationKeywords: [
            "FROM", "RUN", "CMD", "LABEL", "MAINTAINER", "EXPOSE", "ENV", "ADD",
            "COPY", "ENTRYPOINT", "VOLUME", "USER", "WORKDIR", "ARG", "ONBUILD",
            "STOPSIGNAL", "HEALTHCHECK", "SHELL"
        ],
        controlKeywords: [],
        operatorKeywords: ["AS"],
        modifierKeywords: [],
        otherKeywords: [],
        booleanLiterals: ["true", "false"],
        nilLiterals: [],
        builtinTypes: [],
        operatorChars: Set("="),
        supportsSingleQuoteStrings: true,
        supportsBacktickStrings: false,
        supportsMultilineStrings: false,
        supportsAttributes: false,
        supportsPreprocessor: false
    )
}
