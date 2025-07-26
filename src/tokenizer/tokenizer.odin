package tokenizer

import "core:os"
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
    ch: rune

    for t.position < len(t.input) {
        current_char := t.input[t.position]
        char_as_str := strings.to_string(strings.builder_from_bytes({current_char}))

        if unicode.is_space(rune(current_char)) {
            t.position += 1
            continue
        }

        if (current_char == '@') {
            handle_builtins(t, &current_token_bytes)
            continue
        }

        if (current_char == '$') {
            handle_interpolation(t, &current_token_bytes)
            continue
        }

        if (is_punctuation(current_char)) {
            handle_punctuation(t, current_char, &current_token_bytes)
            continue
        }

        if (unicode.is_digit(rune(current_char))) {
            handle_numbers(t, &current_token_bytes)
            continue
        }

        if (current_char == '"') {
            handle_strings(t, &current_token_bytes)
            continue
        }

        if (current_char == '\'') {
            handle_characters(t, &current_token_bytes)
            continue
        }

        if (is_operator(current_char)) {
            handle_operator(t, current_char, &current_token_bytes)
            continue
        }

        if unicode.is_alpha(rune(current_char)) || current_char == '_' {
            handle_identifier_and_keywords(t, &current_token_bytes)
            continue
        }

        // append(&current_token_bytes.buf, current_char)
        t.position += 1
    }

    return true
}

handle_interpolation :: proc(t: ^Tokenizer, current_token_bytes: ^strings.Builder) {
    id_sb := strings.Builder{}
    append(&id_sb.buf, '$')

    t.position += 1 // skip '$'
    if t.position >= len(t.input) || t.input[t.position] != '{' {
        fmt.printfln("Error: Expected '{' after '$' at position %d", t.position)
        os.exit(1)
    }

    append(&id_sb.buf, '{')
    t.position += 1 // skip '{'

    for t.position < len(t.input) && t.input[t.position] != '}' {
        ch := t.input[t.position]
        append(&id_sb.buf, ch)
        t.position += 1
    }

    if len(id_sb.buf) == 0 {
        fmt.printfln("Error: Empty interpolation %d", t.position)
        os.exit(1)
    }

    if t.position >= len(t.input) || t.input[t.position] != '}' {
        fmt.printfln("Error: Unclosed interpolation at position %d", t.position)
        os.exit(1)
    }

    append(&id_sb.buf, '}')
    t.position += 1 // skip '}'

    append(&t.tokens, Token{
        kind = .Interpolation,
        value = strings.to_string(id_sb),
    })
}

handle_builtins :: proc(t: ^Tokenizer, current_token_bytes: ^strings.Builder) {
    builtin_sb := strings.Builder{}
    append(&builtin_sb.buf, "@")
    t.position += 1 // skip '@'

    b := t.input[t.position]
    ch := rune(b)
    for !unicode.is_space(ch) && !unicode.is_punct(ch) && t.position < len(t.input) {
        append(&builtin_sb.buf, b)
        t.position += 1

        if t.position >= len(t.input) {
            break
        }

        b = t.input[t.position]
        ch = rune(b)
    }

    if len(builtin_sb.buf) == 1 {
        append(&t.tokens, Token{kind = .Punctuation, value = "@"})
        return
    }

    append(&t.tokens, Token{ kind = .Builtin, value = strings.to_string(builtin_sb)})
}

handle_punctuation :: proc(t: ^Tokenizer, current_char: byte, current_token_bytes: ^strings.Builder) {
    punct_sb := strings.Builder{}
    append(&punct_sb.buf, current_char)
    t.position += 1

    switch current_char {
        case '(', ')',
             '{', '}', 
             '[', ']',
             ',', ';',
             '.', ':',
             '?', '$',
             '@':
            // These are all single-character punctuation tokens
            append(&t.tokens, Token{ kind = .Punctuation, value = strings.to_string(punct_sb)})
            return
    }

    // handle multi-character punctuation
    ch := t.input[t.position]
    append(&current_token_bytes.buf, ch)
    punct_str := strings.to_string(punct_sb)
    t.position += 1

    switch punct_str {
        case PUNCT_ARROW:
            append(&t.tokens, Token{ kind = .Punctuation, value = "->" })

        case:
            fmt.printfln("Unknown punctuation: %s", punct_str)
            os.exit(1)
    }
}

handle_numbers :: proc(t: ^Tokenizer, current_token_bytes: ^strings.Builder) {
    num_sb := strings.Builder{}
    append(&num_sb.buf, t.input[t.position])
    t.position += 1

    ch := t.input[t.position]
    is_float := false

    for t.position < len(t.input) && (unicode.is_digit(rune(ch)) || ch == '.') {
        if ch == '.' {
            if is_float {
                fmt.printfln("Error: Multiple decimal points in number at position %d", t.position)
                os.exit(1)
            }
            is_float = true
        }
        append(&num_sb.buf, ch)
        t.position += 1

        if t.position >= len(t.input) {
            break
        }

        ch = t.input[t.position]
    }

    num_str := strings.to_string(num_sb)
    if is_float && string_is_float(num_str) {
        append(&t.tokens, Token{ kind = .FloatLiteral, value = num_str })
        return 
    }
    
    if string_is_digit(num_str) {
        append(&t.tokens, Token{ kind = .IntegerLiteral, value = num_str })
        return
    }

    fmt.printfln("Error: Invalid number format at position %d", t.position)
    os.exit(1)
}

handle_strings :: proc(t: ^Tokenizer, current_token_bytes: ^strings.Builder) {
    str_sb := strings.Builder{}
    append(&str_sb.buf, '"')
    t.position += 1

    for t.position < len(t.input) && t.input[t.position] != '"' {
        ch := t.input[t.position]
        append(&str_sb.buf, ch)
        t.position += 1
    }

    if t.position >= len(t.input) {
        fmt.printfln("Error: Unclosed string literal at position %d", t.position)
        os.exit(1)
    }

    append(&str_sb.buf, '"')
    t.position += 1
    append(&t.tokens, Token{ kind = .StringLiteral, value = strings.to_string(str_sb) })
}

handle_characters :: proc(t: ^Tokenizer, current_token_bytes: ^strings.Builder) {
    char_sb := strings.Builder{}
    append(&char_sb.buf, '\'')
    t.position += 1

    if t.position >= len(t.input) {
        fmt.printfln("Error: Unclosed character literal at position %d", t.position)
        os.exit(1)
    }

    ch := t.input[t.position]
    append(&char_sb.buf, ch)
    t.position += 1

    if t.position >= len(t.input) || t.input[t.position] != '\'' {
        fmt.printfln("Error: Unclosed character literal at position %d", t.position)
        os.exit(1)
    }

    append(&char_sb.buf, '\'')
    t.position += 1
    if len(char_sb.buf) != 3 {
        fmt.printfln("Error: Invalid character literal at position %d", t.position)
        os.exit(1)
    }

    append(&t.tokens, Token{ kind = .CharacterLiteral, value = strings.to_string(char_sb) })
}

handle_operator :: proc(t: ^Tokenizer, current_char: byte, current_token_bytes: ^strings.Builder) {
    op_sb := strings.Builder{}
    append(&op_sb.buf, current_char)
    t.position += 1

    next_ch := t.input[t.position]
    
    switch current_char {
        case '=':
            if next_ch == '=' {
                append(&op_sb.buf, next_ch)
                t.position += 1
            }
            append(&t.tokens, Token{ kind = .Operator, value = strings.to_string(op_sb) })
            return

        case '+', '-', '&', '|', '<', '>':
            if next_ch == '=' || next_ch == current_char {
                append(&op_sb.buf, next_ch)
                t.position += 1
            }
            append(&t.tokens, Token{ kind = .Operator, value = strings.to_string(op_sb) })
            return

        case '*', '/', '%', '^', '~', '!':
            if next_ch == '=' {
                append(&op_sb.buf, next_ch)
                t.position += 1
            }
            append(&t.tokens, Token{ kind = .Operator, value = strings.to_string(op_sb) })
            return

        case '?', '.', ':':
            append(&t.tokens, Token{ kind = .Operator, value = "?" })
            return
        
        case:
            fmt.printfln("Unknown operator: %s", strings.to_string(op_sb))
            os.exit(1)
    }
}

handle_identifier_and_keywords :: proc(t: ^Tokenizer, current_token_bytes: ^strings.Builder) {
    id_sb := strings.Builder{}
    append(&id_sb.buf, t.input[t.position])
    t.position += 1

    ch := t.input[t.position]
    for t.position < len(t.input) && (
        unicode.is_alpha(rune(ch)) || 
        unicode.is_digit(rune(ch)) || 
        ch == '_' || 
        ch == '$' || 
        ch == '{' || ch == '}'
    ) {    
        append(&id_sb.buf, ch)
        t.position += 1

        if t.position >= len(t.input) {
            break
        }

        ch = t.input[t.position]
    }

    if len(id_sb.buf) == 0 {
        fmt.printfln("Error: Identifier is empty at position %d", t.position)
        os.exit(1)
    }
    id_str := strings.to_string(id_sb)

    if is_keyword(id_str) {
        append(&t.tokens, Token{
            kind = .Keyword,
            value = id_str,
        })
        return
    }

    append(&t.tokens, Token{
        kind = .Identifier,
        value = id_str,
    })
}

is_keyword :: proc(s: string) -> bool {
    switch s {
        case KW_struct,
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
            KW_CONTINUE:
            return true
        case:
            return false
    }
}

is_punctuation :: proc(start_ch: byte) -> bool {
    switch start_ch {
        case '(', ')',
             '{', '}', 
             '[', ']',
             ',', ';',
             '.', ':',
             '$':
            return true
        case:
            return false
    }
}

is_operator :: proc(start_ch: byte) -> bool {
    switch start_ch {
        case '+', '-', '*', '/', '%', '&', '|', '^', '~', '!', '=', '<', '>', '?':
            return true
        case:
            return false
    }
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
