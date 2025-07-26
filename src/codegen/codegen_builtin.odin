package codegen

import tk "../tokenizer"
import "core:fmt"
import "core:os"
import "core:strings"

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
                        fmt.printfln("Error: %s", err_msg)
                        os.exit(1)
                }
            }
            return new_index

        case tk.BUILTIN_ALIAS:
            expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, tk.PUNCT_LPAREN)
            new_index += 1

            alias_name := get_value_of_expected_token_kind(tokens, new_index, tk.TokenKind.Identifier)
            new_index += 1

            expect_token_with_value(tokens, new_index, tk.TokenKind.Operator, tk.OP_ASSIGN)
            new_index += 1

            alias_value := [dynamic]tk.Token{}
            for new_index < len(tokens) && tokens[new_index].value != tk.PUNCT_RPAREN {
                t := tokens[new_index]
                new_index += 1
                append(&alias_value, t)
                // TODO: implement variadic aliases in @alias instead of multiple @alias calls
            }
            expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, tk.PUNCT_RPAREN)
            new_index += 1
            program.comptime_aliases[alias_name] = alias_value[:]
            return new_index

        case tk.BUILTIN_FOR:
            new_index, emitted := eval_builtin(program, tokens, new_index-1)
            for emitted_token in emitted {
                append(&program.generated_source_builder, emitted_token)
            }
            append(&program.generated_source_builder, "\n")
            return new_index

        case:
            // TODO: handle other builtins
            fmt.printfln("Unhandled builtin %s", token.value)
            os.exit(1)
    }

    return new_index
}
