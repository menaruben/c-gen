package codegen

import "core:strings"
import "core:os"
import "core:fmt"
import tk "../tokenizer"

GeneratedProgram :: struct {
    generated_source_builder: [dynamic]string,
    comptime_ids: [dynamic]string,
    comptime_aliases: map[string][]tk.Token,
    comptime_id_values: map[string]string
}

generate_program :: proc(
    tokens: []tk.Token,
    comptime_id_values: map[string]string
) -> GeneratedProgram {
    alias_map := make(map[string][]tk.Token)
    program := GeneratedProgram{
        comptime_aliases = alias_map,
        comptime_ids = [dynamic]string{},
        generated_source_builder = [dynamic]string{},
        comptime_id_values = comptime_id_values,
    }

    for i := 0; i < len(tokens); i += 1 {
        token := tokens[i]
        enum_name, ok := fmt.enum_value_to_string(token.kind)
        if !ok {
            enum_name = "Unknown"
        }

        fmt.printfln("processing token %s", tk.token_to_string(token))

        #partial switch token.kind {
            case .Builtin:
                i = handle_builtin(&program, tokens, i)

            case .Keyword:
                i = handle_keyword(&program, tokens, i)

            case .Identifier, .Interpolation:
                resolved_value := resolve_identifier(token.value, comptime_id_values, program.comptime_aliases)
                append(&program.generated_source_builder, resolved_value)
                append(&program.generated_source_builder, " ")
                i += 1

            case .Punctuation, .Operator, 
                .BooleanLiteral, .IntegerLiteral, 
                .StringLiteral, .CharacterLiteral, 
                .FloatLiteral, .NullLiteral:
                append(&program.generated_source_builder, token.value)
                append(&program.generated_source_builder, " ")
                i += 1

            case:
                // TODO: implement other kinds
                fmt.printfln("Unhandled token kind: %s", enum_name)
                show_next_n_tokens(tokens, i, 5)
                os.exit(1)
        }

        i -= 1 // Adjust for the loop increment
    }

    // resolve all identifiers and interpolations
    for t, i in program.generated_source_builder {
        program.generated_source_builder[i] = resolve_identifier(t, comptime_id_values, program.comptime_aliases)
    }

    return program
}


