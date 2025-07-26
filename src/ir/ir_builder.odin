package ir

import "core:os"
import "core:fmt"
import tk "../tokenizer"

build_ir_program :: proc(tokens: []tk.Token) -> IrProgram {
    program := IrProgram{
        functions = map[string]IrFunction{},
        stack = [dynamic]StackValue{},
        comptime_ids = [dynamic]string{},
        comptime_aliases = map[string]string{},
    }

    for i := 0; i < len(tokens); i += 1 {
        token := tokens[i]
        enum_name, ok := fmt.enum_value_to_string(token.kind)
        if !ok {
            enum_name = "Unknown"
        }

        fmt.printfln("Processing token: %s, Value: `%s`", enum_name, token.value)
        fmt.printfln("Parsing %s", enum_name)
        fmt.printfln("tokens from here:")
        for t, ti in tokens[i:min(i+7, len(tokens))] {
            t_enum_name, ok := fmt.enum_value_to_string(t.kind)
            if !ok {
                t_enum_name = "Unknown"
            }
            fmt.printfln("  %s: `%s`", t_enum_name, t.value)
        }

        switch token.kind {
            case .Builtin:
                i = handle_builtin(&program, tokens, i)
            case .Identifier:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .Keyword:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .StringLiteral:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .CharacterLiteral:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .IntegerLiteral:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .FloatLiteral:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .BooleanLiteral:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .NullLiteral:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .Operator:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)
            case .Punctuation:
                fmt.printfln("IR Gen Error: %s kind not implemented yet", enum_name)
                os.exit(1)

            case:
                fmt.printfln("Unhandled token kind: %s", enum_name)
                os.exit(1)
        }

        i -= 1 // Adjust for the loop increment
        fmt.printfln("Parsed %s", enum_name)
        fmt.println("New index: ", i)
    }

    return program
}

handle_builtin :: proc(program: ^IrProgram, tokens: []tk.Token, index: int) -> (new_index: int) {
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