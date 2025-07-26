package codegen

import "core:strings"
import tk "../tokenizer"
import "core:fmt"
import "core:os"

handle_keyword :: proc(program: ^GeneratedProgram, tokens: []tk.Token, index: int) -> (new_index: int) {
    new_index = index
    token := tokens[new_index]
    new_index += 1

    switch token.value {
        case tk.KW_struct:
            new_index = parse_struct(program, tokens, new_index)

        case tk.KW_RETURN:
            append(&program.generated_source_builder, "return")
            append(&program.generated_source_builder, " ")

            return_value_sb := strings.Builder{}
            for new_index < len(tokens) && tokens[new_index].value != ";" {
                t := tokens[new_index]
                new_index += 1
                append(&return_value_sb.buf, t.value)
            }            
            return_value := strings.to_string(return_value_sb)
            resolved_return_value := resolve_identifier(return_value, program.comptime_id_values, program.comptime_aliases)
            append(&program.generated_source_builder, resolved_return_value)

            expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, tk.PUNCT_SEMICOLON)
            append(&program.generated_source_builder, ";")
            new_index += 1

        case:
            // TODO: handle other keywords
            fmt.printfln("Unhandled keyword: %s at index %d", token.value, index)
            show_next_n_tokens(tokens, index, 10)
            os.exit(1)
    }

    return new_index
}