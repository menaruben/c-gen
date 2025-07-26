package codegen

import tk "../tokenizer"
import "core:strings"
import "core:os"
import "core:fmt"

resolve_all_interpolations_and_identifiers :: proc(
    tokens: []tk.Token, 
    comptime_id_values: map[string]string,
    comptime_aliases: map[string][]tk.Token
) -> (resolved_tokens: []tk.Token) {
    resolved_tokens = tokens
    
    for i in 0..<len(tokens) {
        token := tokens[i]

        if token.kind == tk.TokenKind.Interpolation || token.kind == tk.TokenKind.Identifier {
            resolved_value := resolve_identifier(token.value, comptime_id_values, comptime_aliases)
            resolved_tokens[i] = tk.Token{kind = tk.TokenKind.Identifier, value = resolved_value}
        }
    }

    return resolved_tokens
}

@(private)
resolve_identifier :: proc(
    value: string, 
    comptime_id_values: map[string]string, 
    comptime_aliases:  map[string][]tk.Token
) -> string {
    id_sb := strings.Builder{}
    interpolation_id_sb := strings.Builder{}

    for i := 0; i < len(value); i += 1 {
        char := value[i]
        
        if char == '\\' {
            i += 1 // Skip the next character (escape sequence)
            if i < len(value) {
                append(&id_sb.buf, value[i])
            }
            continue
        } 

        if char == '$' && i + 1 < len(value) && value[i + 1] == '{' {
            i += 2 // Skip past the '${'

            for i < len(value) && value[i] != '}' {
                char = value[i]
                append(&interpolation_id_sb.buf, char)
                i += 1
            }
            i += 1 // Skip past the '}'
            value := resolve_comptime_id_value(strings.to_string(interpolation_id_sb), comptime_id_values, comptime_aliases)
            strings.builder_reset(&interpolation_id_sb)
            append(&id_sb.buf, value)
        } else {
            append(&id_sb.buf, char) // Regular character
        }
    }

    return strings.to_string(id_sb)
}

extract_comptime_id_from_interpolation_string :: proc(interpolation: string) -> string {
    // interpolation is in the form of ${id}
    if len(interpolation) < 3 || interpolation[0] != '$' || interpolation[1] != '{' || interpolation[len(interpolation)-1] != '}' {
        fmt.printfln("Invalid interpolation format: %s", interpolation)
        os.exit(1)
    }
    return interpolation[2:len(interpolation)-1] // Extract the ID between ${ and }
}

@(private)
resolve_comptime_id_value :: proc(
    comptime_id: string,
    comptime_id_values: map[string]string, 
    comptime_aliases: map[string][]tk.Token
) -> string {
    value: string
    ok: bool
    tokens: []tk.Token
    
    value, ok = comptime_id_values[comptime_id]
    if !ok {
        tokens, ok = comptime_aliases[comptime_id]
        if !ok {
            fmt.printfln("Comptime identifier '%s' not found in values or aliases.", comptime_id)
            os.exit(1)
        }
        value = get_literal_alias_value(tokens)
    }

    return value
}
