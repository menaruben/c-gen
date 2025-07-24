package tokenizer

import "core:unicode"
import "core:strings"
/*
The C template lexer is responsible for parsing C template files.
This means it is a superset of a simple C lexer, with additional capabilities
to handle template syntax (like `${TValue}`).
*/

import "core:fmt"

Tokenizer :: struct {
    input: []byte,
    position: int,
    tokens: [dynamic]Token,
}

tokenize :: proc(t: ^Tokenizer) -> bool {
    current_token_bytes := strings.Builder{}
    current_byte: byte
    ch: rune

    for t.position < len(t.input) {
        current_char := t.input[t.position]

        if (strings.is_space(rune(current_char))) {
            append_if_builder_not_empty(t, &current_token_bytes)
            t.position += 1
            continue
        }

        switch current_char {
            case '{':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = "{",
                })
                t.position += 1

            case '}':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = "}",
                })
                t.position += 1
            
            case '(':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = "(",
                })
                t.position += 1

            case ')':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = ")",
                })
                t.position += 1

            case '[':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = "[",
                })
                t.position += 1

            case ']':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = "]",
                })
                t.position += 1

            case ',':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = ",",
                })
                t.position += 1

            case ';':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = ";",
                })
                t.position += 1
            
            case '.':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = ".",
                })
                t.position += 1

            case ':':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = ":",
                })
                t.position += 1 

            case '?':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = "?",
                })
                t.position += 1

            case '$':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Punctuation,
                    value = "$",
                })
                t.position += 1

            case '=':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "=",
                })
                t.position += 1

            case '+':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "+",
                })
                t.position += 1

            case '-':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "-",
                })
                t.position += 1

            case '*':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "*",
                })
                t.position += 1

            case '/':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "/",
                })
                t.position += 1

            case '%':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "%",
                })
                t.position += 1

            case '&':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "&",
                })

            case '|':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "|",
                })
                t.position += 1

            case '^':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "^",
                })
                t.position += 1
            
            case '~':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "~",
                })
                t.position += 1

            case '<':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "<",
                })
                t.position += 1

            case '>':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = ">",
                })
                t.position += 1

            case '!':
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Operator,
                    value = "!",
                })
                t.position += 1

            case '"':
                panic("String literals are not yet supported in this tokenizer.")

            case '\'':
                panic("Character literals are not yet supported in this tokenizer.")

            case '@':
                // keep reading until we find a space or newline
                append_if_builder_not_empty(t, &current_token_bytes)
                append(&t.tokens, Token{
                    kind = .Keyword,
                    value = "@",
                })
                t.position += 1

            case:
                append(&current_token_bytes.buf, current_char)
                t.position += 1
        }
    }

    return true
}

append_if_builder_not_empty :: proc(t: ^Tokenizer, current_token_bytes: ^strings.Builder) {
    if len(current_token_bytes.buf) > 0 {
        stripped := strings.trim(strings.to_string(current_token_bytes^), " \t\n\r")
        if len(stripped) > 0 {
            temp_sb := strings.Builder{}
            append(&temp_sb.buf, stripped)
            token_kind := determine_token_kind(temp_sb)
            append(&t.tokens, Token{
                kind = token_kind,
                value = stripped,
            })
        }
        strings.builder_reset(current_token_bytes)
    }
}

determine_token_kind :: proc(current_token_bytes: strings.Builder) -> TokenKind {
    token_str := strings.to_string(current_token_bytes)

    switch token_str {
        // Keywords
        case KW_comptime, KW_alias,
             KW_struct, KW_for, KW_RETURN,
             KW_INT, KW_FLOAT, KW_CHAR, KW_BOOL, KW_VOID, KW_SHORT, KW_LONG, KW_DOUBLE,
             KW_UNSIGNED, KW_SIGNED, KW_CONST, KW_STATIC, KW_ENUM, KW_TYPEDEF, KW_EXTERN,
             KW_IF, KW_ELSE, KW_WHILE, KW_SWITCH, KW_CASE, KW_DEFAULT, KW_BREAK, KW_CONTINUE:
            return .Keyword

        // Punctuation
        case PUNCT_LPAREN, PUNCT_RPAREN, PUNCT_LBRACE, PUNCT_RBRACE, PUNCT_LBRACKET, PUNCT_RBRACKET,
             PUNCT_COMMA, PUNCT_SEMICOLON, PUNCT_DOT, PUNCT_COLON, PUNCT_ARROW, PUNCT_QUESTION, PUNCT_DOLLAR:
            return .Punctuation

        // Operators
        case OP_ASSIGN, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_MOD,
             OP_EQ, OP_NEQ, OP_LT, OP_GT, OP_LTE, OP_GTE,
             OP_AND, OP_OR, OP_NOT,
             OP_BIT_AND, OP_BIT_OR, OP_BIT_XOR, OP_BIT_NOT, OP_BIT_LSHIFT, OP_BIT_RSHIFT,
             OP_INC, OP_DEC:
            return .Operator

        // Literals
        case "true", "false":
            return .BooleanLiteral

        // String literal
        case:
            if strings.starts_with(token_str, "\"") && strings.ends_with(token_str, "\"") {
                return .StringLiteral
            }

            if strings.starts_with(token_str, "'") && strings.ends_with(token_str, "'") {
                return .CharacterLiteral
            }

            // Integer literal
            if string_is_digit(token_str) {
                return .IntegerLiteral
            }

            // Float literal
            if strings.contains(token_str, ".") {
                parts := strings.split(token_str, ".")
                if len(parts) > 2 {
                    return .Identifier
                }

                for part in parts {
                    if !string_is_digit(part) {
                        return .Identifier
                    }
                }

                return .FloatLiteral
            }

            if token_str == "true" || token_str == "false" {
                return .BooleanLiteral
            }

            return .Identifier
    }

    return .Identifier
}

string_is_digit :: proc(s: string) -> bool {
    for i in 0..<len(s) {
        if !unicode.is_digit(rune(s[i])) {
            return false
        }
    }
    return true
}

string_is_float :: proc(s: string) -> bool {
    has_dot := false
    for i in 0..<len(s) {
        if unicode.is_digit(rune(s[i])) {
            continue
        }
        if s[i] == '.' {
            if has_dot {
                return false
            }
            has_dot = true
            continue
        }
        return false 
    }
    return true
}

string_is_punctuation :: proc(s: string) -> bool {
    for i in 0..<len(s) {
        if !unicode.is_punct(rune(s[i])) {
            return false
        }
    }
    return true
}

string_is_keyword :: proc(s: string) -> bool {
    switch s {
        case KW_comptime, KW_alias, KW_struct, KW_for,
             KW_RETURN, KW_INT, KW_FLOAT, KW_CHAR, KW_BOOL, KW_VOID,
             KW_SHORT, KW_LONG, KW_DOUBLE, KW_UNSIGNED, KW_SIGNED,
             KW_CONST, KW_STATIC, KW_ENUM, KW_TYPEDEF, KW_EXTERN,
             KW_IF, KW_ELSE, KW_WHILE, KW_SWITCH, KW_CASE,
             KW_DEFAULT, KW_BREAK, KW_CONTINUE:
            return true
        case:
            return false
    }
}

string_is_operator :: proc(s: string) -> bool {
    switch s {
        case OP_ASSIGN, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_MOD,
             OP_EQ, OP_NEQ, OP_LT, OP_GT, OP_LTE, OP_GTE,
             OP_AND, OP_OR, OP_NOT,
             OP_BIT_AND, OP_BIT_OR, OP_BIT_XOR, OP_BIT_NOT,
             OP_BIT_LSHIFT, OP_BIT_RSHIFT,
             OP_INC, OP_DEC:
            return true
        case:
            return false
    }
}
