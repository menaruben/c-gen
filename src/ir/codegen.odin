package ir

import "core:strings"
import "core:os"
import "core:fmt"
import tk "../tokenizer"

GeneratedProgram :: struct {
    generated_source_builder: strings.Builder,
    comptime_ids: [dynamic]string,
    comptime_aliases: map[string]string,
    comptime_id_values: map[string]string
}

generate_program :: proc(
    tokens: []tk.Token,
    comptime_id_values: map[string]string
) -> GeneratedProgram {
    alias_map := make(map[string]string)
    program := GeneratedProgram{
        comptime_aliases = alias_map,
        comptime_ids = [dynamic]string{},
        generated_source_builder = strings.Builder{},
        comptime_id_values = comptime_id_values,
    }

    for i := 0; i < len(tokens); i += 1 {
        token := tokens[i]
        enum_name, ok := fmt.enum_value_to_string(token.kind)
        if !ok {
            enum_name = "Unknown"
        }

        #partial switch token.kind {
            case .Builtin:
                i = handle_builtin(&program, tokens, i)

            case .Keyword:
                i = handle_keyword(&program, tokens, i)

            case:
                fmt.printfln("Unhandled token kind: %s", enum_name)
                show_next_n_tokens(tokens, i, 5)
                os.exit(1)
        }

        i -= 1 // Adjust for the loop increment
    }

    return program
}

handle_builtin :: proc(program: ^GeneratedProgram, tokens: []tk.Token, index: int) -> (new_index: int) {
    new_index = index
    token := tokens[new_index]
    new_index += 1

    token_value: string
    ok: bool
    err_msg: string

    switch token.value {
        case tk.BUILTIN_COMPTIME:
            expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, "(")
            new_index += 1

            expects_id := true
            for expects_id {
                token_value = get_value_of_expected_token_kind(tokens, new_index, tk.TokenKind.Identifier)
                new_index += 1
                append(&program.comptime_ids, token_value)

                token_value = get_value_of_expected_token_kind(tokens, new_index, tk.TokenKind.Punctuation)
                new_index += 1
                switch token_value {
                    case tk.PUNCT_RPAREN:
                        expects_id = false
                    
                    case tk.PUNCT_COMMA:
                        expects_id = true

                    case:
                        err_msg = fmt.aprintfln("Expected ')' or ',', got '%s' at index %d", token_value, new_index)
                        fmt.printfln("IR Gen Error: %s", err_msg)
                        os.exit(1)
                }
            }

        case:
            fmt.printfln("IR Gen Error: Unhandled builtin %s", token.value)
            os.exit(1)
    }

    return new_index
}

handle_keyword :: proc(program: ^GeneratedProgram, tokens: []tk.Token, index: int) -> (new_index: int) {
    new_index = index
    token := tokens[new_index]
    new_index += 1

    switch token.value {
        case tk.KW_struct:
            new_index = parse_struct(program, tokens, new_index)

        case:
            fmt.printfln("Unhandled keyword: %s at index %d", token.value, index)
            show_next_n_tokens(tokens, index, 5)
            os.exit(1)
    }

    return new_index
}

parse_struct :: proc(program: ^GeneratedProgram, tokens: []tk.Token, index: int) -> (new_index: int) {
    new_index = index
    token := tokens[new_index]

    append(&program.generated_source_builder.buf, "struct")
    append(&program.generated_source_builder.buf, " ")

    struct_name := get_value_of_expected_token_kind(tokens, new_index, tk.TokenKind.Identifier)
    struct_name = resolve_identifier(token, program.comptime_id_values)

    append(&program.generated_source_builder.buf, struct_name)
    new_index += 1

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, "{")
    append(&program.generated_source_builder.buf, "{")
    new_index += 1

    t := tokens[new_index]
    if (t.kind != tk.TokenKind.Keyword && 
        t.kind != tk.TokenKind.Identifier && 
        t.kind != tk.TokenKind.Operator && 
        t.kind != tk.TokenKind.Punctuation
    ) {
        fmt.printfln("Expected field definition, got %s token at index %d", tk.token_to_string(t), new_index)
        show_next_n_tokens(tokens, new_index, 5)
        os.exit(1)
    }

    // handle fields
    for new_index < len(tokens) {
        t = tokens[new_index];
        if t.kind == tk.TokenKind.Punctuation && t.value == "}" {
            break;
        }

        // Collect tokens for a field
        field_tokens := [dynamic]string{};
        for new_index < len(tokens) {
            t = tokens[new_index];
            if t.kind == tk.TokenKind.Punctuation && (t.value == ";" || t.value == "}") {
                break;
            }

            #partial switch t.kind {
                case tk.TokenKind.Interpolation:
                    comptime_id := extract_comptime_id_from_interpolation_string(t.value)
                    resolved_value := resolve_comptime_id_value(comptime_id, program.comptime_id_values)
                    append(&field_tokens, resolved_value)
                case tk.TokenKind.Identifier:
                    resolved_id := resolve_identifier(t, program.comptime_id_values)
                    append(&field_tokens, resolved_id)
                case:
                    append(&field_tokens, t.value)
            }

            new_index += 1;
        }

        // Append the field line
        append(&program.generated_source_builder.buf, strings.join(field_tokens[:], " "));
        if new_index < len(tokens) && tokens[new_index].value == ";" {
            append(&program.generated_source_builder.buf, ";");
            new_index += 1;
        } else {
            append(&program.generated_source_builder.buf, "\n");
        }
    }

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, "}")
    append(&program.generated_source_builder.buf, "}")
    new_index += 1

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, ";")
    append(&program.generated_source_builder.buf, ";")
    new_index += 1

    return new_index
}

string_contains_interpolation :: proc(str: string) -> bool {
    return strings.contains(str, "${") && strings.contains(str, "}")
}

resolve_identifier :: proc(token: tk.Token, comptime_id_values: map[string]string) -> string {
    id_sb := strings.Builder{}
    interpolation_id_sb := strings.Builder{}

    for i := 0; i < len(token.value); i += 1 {
        char := token.value[i]
        
        if char == '$' && i + 1 < len(token.value) && token.value[i + 1] == '{' {
            i += 2 // Skip past the '${'

            for i < len(token.value) && token.value[i] != '}' {
                char = token.value[i]
                append(&interpolation_id_sb.buf, char)
                i += 1
            }
            i += 1 // Skip past the '}'
            value := resolve_comptime_id_value(strings.to_string(interpolation_id_sb), comptime_id_values)
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

resolve_comptime_id_value :: proc(comptime_id: string, comptime_id_values: map[string]string) -> string {
    value, ok := comptime_id_values[comptime_id]
    assert(ok, fmt.aprintfln("Comptime ID '%s' not found in values map", comptime_id))
    return value
}

/*-----------------------------------------------------
    helper functions for handling expected tokens
-----------------------------------------------------*/ 

expect_token :: proc(tokens: []tk.Token, index: int, expected_kind: tk.TokenKind) {
    assert(index < len(tokens), "Index out of bounds in expect_token")

    token := tokens[index]
    ok: bool
    expected_kind_name: string
    actual_kind_name: string

    expected_kind_name, ok = fmt.enum_value_to_string(expected_kind)
    assert(ok, "Failed to convert expected token kind to string")

    actual_kind_name, ok = fmt.enum_value_to_string(token.kind)
    assert(ok, "Failed to convert token kind to string")

    assert(token.kind == expected_kind, 
        fmt.aprintfln("Expected token kind %s, got %s at index %d",
            expected_kind_name, actual_kind_name, index))
}

expect_token_with_value :: proc(tokens: []tk.Token, index: int, expected_kind: tk.TokenKind, expected_value: string) {
    expect_token(tokens, index, expected_kind)

    token := tokens[index]
    assert(token.value == expected_value,
        fmt.aprintfln("Expected token value '%s', got '%s' at index %d",
            expected_value, token.value, index))
}

get_value_of_expected_token_kind :: proc(tokens: []tk.Token, index: int, expected_kind: tk.TokenKind) -> (value: string) {
    expect_token(tokens, index, expected_kind)
    token := tokens[index]
    return token.value
}

show_next_n_tokens :: proc(tokens: []tk.Token, index: int, n: int) {
    fmt.print("[    ")
    for t, ti in tokens[index+1:index+n+1] {
        t_enum_name, ok := fmt.enum_value_to_string(t.kind)
        if !ok {
            t_enum_name = "Unknown"
        }
        fmt.printf("<%s, `%s`>    ", t_enum_name, t.value)
    }
    fmt.printfln("...    ]")
}