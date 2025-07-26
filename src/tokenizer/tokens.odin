package tokenizer

import "core:fmt"
Token :: struct {
    kind: TokenKind,
    value: string,
}

token_to_string :: proc(token: Token) -> string {
    kind_name, ok := fmt.enum_value_to_string(token.kind)
    if !ok {
        kind_name = "Unknown"
    }
    return fmt.aprintf("<%s,`%s`>", kind_name, token.value)
}

TokenKind :: enum {
    Builtin,
    Interpolation,
    Identifier,
    Keyword,
    StringLiteral,
    CharacterLiteral,
    IntegerLiteral,
    FloatLiteral,
    BooleanLiteral,
    NullLiteral,
    Operator,
    Punctuation,
}

BUILTIN_COMPTIME :: "@comptime"
BUILTIN_ALIAS :: "@alias"
BUILTIN_EMIT :: "@emit"
BUILTIN_EMITLN :: "@emitln"
BUILTIN_FOR :: "@for"
BUILTIN_IF :: "@if"

BUILTINS :: []string{
    BUILTIN_COMPTIME,
    BUILTIN_ALIAS,
    BUILTIN_EMIT,
    BUILTIN_EMITLN,
    BUILTIN_FOR,
    BUILTIN_IF,
}

KW_struct :: "struct"
KW_UNION :: "union"
KW_for :: "for"
KW_RETURN :: "return"
KW_INT :: "int"
KW_FLOAT :: "float"
KW_CHAR :: "char"
KW_BOOL :: "bool"
KW_VOID :: "void"
KW_SHORT :: "short"
KW_LONG :: "long"
KW_DOUBLE :: "double"
KW_UNSIGNED :: "unsigned"
KW_SIGNED :: "signed"
KW_CONST :: "const"
KW_STATIC :: "static"
KW_ENUM :: "enum"
KW_TYPEDEF :: "typedef"
KW_EXTERN :: "extern"
KW_IF :: "if"
KW_ELSE :: "else"
KW_WHILE :: "while"
KW_SWITCH :: "switch"
KW_CASE :: "case"
KW_DEFAULT :: "default"
KW_BREAK :: "break"
KW_CONTINUE :: "continue"

KEYWORDS :: []string{
    KW_struct,
    KW_for,
    KW_RETURN,
    KW_INT,
    KW_FLOAT,
    KW_CHAR,
    KW_BOOL,
    KW_VOID,
    KW_SHORT,
    KW_LONG,
    KW_DOUBLE,
    KW_UNSIGNED,
    KW_SIGNED,
    KW_CONST,
    KW_STATIC,
    KW_ENUM,
    KW_TYPEDEF,
    KW_EXTERN,
    KW_IF,
    KW_ELSE,
    KW_WHILE,
    KW_SWITCH,
    KW_CASE,
    KW_DEFAULT,
    KW_BREAK,
    KW_CONTINUE,
}

PUNCT_LPAREN :: "("
PUNCT_RPAREN :: ")"
PUNCT_LBRACE :: "{"
PUNCT_RBRACE :: "}"
PUNCT_LBRACKET :: "["
PUNCT_RBRACKET :: "]"
PUNCT_COMMA :: ","
PUNCT_SEMICOLON :: ";"
PUNCT_DOT   :: "."
PUNCT_COLON :: ":"
PUNCT_ARROW :: "->"
PUNCT_DOLLAR :: "$"
PUNCT_AT :: "@"

PUNCTS :: []string{  
    PUNCT_LPAREN,
    PUNCT_RPAREN,
    PUNCT_LBRACE,
    PUNCT_RBRACE,
    PUNCT_LBRACKET,
    PUNCT_RBRACKET,
    PUNCT_COMMA,
    PUNCT_SEMICOLON,
    PUNCT_DOT,
    PUNCT_COLON,
    PUNCT_ARROW,
    PUNCT_DOLLAR,
}

OP_ASSIGN  :: "="
OP_ADD     :: "+"
OP_SUB     :: "-"
OP_MUL     :: "*"
OP_DIV     :: "/"
OP_MOD     :: "%"
OP_EQ      :: "=="
OP_NEQ     :: "!="
OP_LT      :: "<"
OP_GT      :: ">"
OP_LTE     :: "<="
OP_GTE     :: ">="
OP_AND     :: "&&"
OP_OR      :: "||"
OP_NOT     :: "!"
OP_BIT_AND :: "&"
OP_BIT_OR  :: "|"
OP_BIT_XOR :: "^"
OP_BIT_NOT :: "~"
OP_BIT_LSHIFT :: "<<"
OP_BIT_RSHIFT :: ">>"
OP_INC     :: "++"
OP_DEC     :: "--"
OP_QUESTION :: "?"

OPERATORS :: []string{
    OP_ASSIGN,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_MOD,
    OP_EQ,
    OP_NEQ,
    OP_LT,
    OP_GT,
    OP_LTE,
    OP_GTE,
    OP_AND,
    OP_OR,
    OP_NOT,
    OP_BIT_AND,
    OP_BIT_OR,
    OP_BIT_XOR,
    OP_BIT_NOT,
    OP_BIT_LSHIFT,
    OP_BIT_RSHIFT,
    OP_INC,
    OP_DEC,
    OP_QUESTION,
}