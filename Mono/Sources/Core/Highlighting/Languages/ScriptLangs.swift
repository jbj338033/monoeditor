import Foundation

enum RubyLang: KeywordBasedLanguage {
    static let id: Language = .ruby
    static let extensions: Set<String> = ["rb"]

    static let keywords = LanguageKeywords(
        declaration: ["def", "class", "module", "attr_reader", "attr_writer", "attr_accessor"],
        control: [
            "if", "elsif", "else", "unless", "case", "when", "for", "while",
            "until", "do", "begin", "end", "return", "raise", "rescue", "ensure",
            "retry", "break", "next", "redo", "then"
        ],
        modifier: ["public", "private", "protected", "yield", "super", "self"],
        operator: ["and", "or", "not", "defined?"],
        other: [
            "require", "require_relative", "include", "extend", "prepend",
            "alias", "lambda", "proc", "__FILE__", "__LINE__", "__ENCODING__"
        ],
        boolean: ["true", "false"],
        null: ["nil"],
        types: [
            "String", "Integer", "Float", "Array", "Hash", "Symbol", "Range",
            "Regexp", "Time", "File", "IO", "Exception", "Object", "Class", "Module"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:.@"),
        singleQuoteStrings: true,
        backtickStrings: true,
        multilineStrings: true,
        hashComments: true
    )
}

enum PHPLang: KeywordBasedLanguage {
    static let id: Language = .php
    static let extensions: Set<String> = ["php"]

    static let keywords = LanguageKeywords(
        declaration: ["function", "class", "interface", "trait", "enum", "namespace", "use"],
        control: [
            "if", "elseif", "else", "switch", "case", "default", "for", "foreach",
            "while", "do", "return", "throw", "try", "catch", "finally",
            "break", "continue", "yield", "match"
        ],
        modifier: ["public", "private", "protected", "static", "final", "abstract", "const", "readonly", "var"],
        operator: ["instanceof", "new", "clone", "and", "or", "xor"],
        other: [
            "echo", "print", "include", "include_once", "require", "require_once",
            "extends", "implements", "as", "global", "fn"
        ],
        boolean: ["true", "false", "TRUE", "FALSE"],
        null: ["null", "NULL"],
        types: [
            "int", "float", "string", "bool", "array", "object", "callable",
            "iterable", "void", "mixed", "never", "self", "static", "parent"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|^~?:.@$"),
        singleQuoteStrings: true,
        backtickStrings: true,
        multilineStrings: true,
        attributes: true,
        hashComments: true
    )
}

enum ShellLang: KeywordBasedLanguage {
    static let id: Language = .shell
    static let extensions: Set<String> = ["sh", "bash", "zsh"]

    static let keywords = LanguageKeywords(
        declaration: ["function", "local", "declare", "typeset", "readonly", "export"],
        control: [
            "if", "then", "else", "elif", "fi", "case", "esac", "for", "while",
            "until", "do", "done", "in", "select", "break", "continue", "return", "exit"
        ],
        modifier: [],
        operator: [],
        other: [
            "echo", "printf", "read", "source", "alias", "unalias", "set", "unset",
            "shift", "eval", "exec", "trap", "wait", "cd", "pwd", "pushd", "popd",
            "test", "true", "false"
        ],
        boolean: ["true", "false"],
        null: [],
        types: []
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|;"),
        singleQuoteStrings: true,
        backtickStrings: true,
        hashComments: true
    )
}

enum DockerfileLang: KeywordBasedLanguage {
    static let id: Language = .dockerfile
    static let extensions: Set<String> = ["dockerfile"]

    static let keywords = LanguageKeywords(
        declaration: [
            "FROM", "RUN", "CMD", "LABEL", "MAINTAINER", "EXPOSE", "ENV", "ADD",
            "COPY", "ENTRYPOINT", "VOLUME", "USER", "WORKDIR", "ARG", "ONBUILD",
            "STOPSIGNAL", "HEALTHCHECK", "SHELL"
        ],
        control: [],
        modifier: [],
        operator: ["AS"],
        other: [],
        boolean: ["true", "false"],
        null: [],
        types: []
    )

    static let options = LanguageOptions(
        operatorChars: Set("="),
        singleQuoteStrings: true,
        hashComments: true
    )
}

enum SQLLang: KeywordBasedLanguage {
    static let id: Language = .sql
    static let extensions: Set<String> = ["sql"]

    static let keywords = LanguageKeywords(
        declaration: [
            "CREATE", "ALTER", "DROP", "TRUNCATE", "TABLE", "INDEX", "VIEW",
            "DATABASE", "SCHEMA", "PROCEDURE", "FUNCTION", "TRIGGER"
        ],
        control: [
            "SELECT", "FROM", "WHERE", "JOIN", "INNER", "LEFT", "RIGHT", "OUTER",
            "ON", "GROUP", "BY", "HAVING", "ORDER", "ASC", "DESC", "LIMIT", "OFFSET",
            "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE",
            "UNION", "INTERSECT", "EXCEPT", "CASE", "WHEN", "THEN", "ELSE", "END",
            "IF", "BEGIN", "COMMIT", "ROLLBACK", "TRANSACTION"
        ],
        modifier: [
            "PRIMARY", "KEY", "FOREIGN", "REFERENCES", "UNIQUE", "NOT", "NULL",
            "DEFAULT", "AUTO_INCREMENT", "IDENTITY", "CHECK", "CONSTRAINT"
        ],
        operator: ["AND", "OR", "NOT", "IN", "EXISTS", "BETWEEN", "LIKE", "IS", "AS", "DISTINCT", "ALL", "ANY", "SOME"],
        other: [
            "COUNT", "SUM", "AVG", "MIN", "MAX", "COALESCE", "NULLIF", "CAST",
            "CONVERT", "CONCAT", "SUBSTRING", "TRIM", "UPPER", "LOWER"
        ],
        boolean: ["TRUE", "FALSE"],
        null: ["NULL"],
        types: [
            "INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT",
            "DECIMAL", "NUMERIC", "FLOAT", "REAL", "DOUBLE",
            "VARCHAR", "CHAR", "TEXT", "NVARCHAR", "NCHAR",
            "DATE", "TIME", "DATETIME", "TIMESTAMP", "BOOLEAN", "BLOB"
        ]
    )

    static let options = LanguageOptions(
        operatorChars: Set("+-*/%=<>!&|"),
        singleQuoteStrings: true,
        backtickStrings: true
    )
}
