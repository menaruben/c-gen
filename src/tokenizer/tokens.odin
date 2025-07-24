package tokenizer

Token :: struct {
    kind: TokenKind,
    value: string,
}

TokenKind :: enum {
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

KW_comptime :: "@comptime"
KW_alias :: "@alias"

KW_struct :: "struct"
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
PUNCT_QUESTION :: "?"
PUNCT_DOLLAR :: "$"

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
