package codegen

import tk "../tokenizer"
import "core:fmt"
import "core:os"
import "core:strings"

parse_struct :: proc(program: ^GeneratedProgram, tokens: []tk.Token, index: int) -> (new_index: int) {
    new_index = index
    token := tokens[new_index]

    append(&program.generated_source_builder, "struct")
    append(&program.generated_source_builder, " ")

    struct_name := get_value_of_expected_token_kind(tokens, new_index, tk.TokenKind.Identifier)

    append(&program.generated_source_builder, struct_name)
    new_index += 1

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, "{")
    append(&program.generated_source_builder, "{")
    new_index += 1

    t := tokens[new_index]
    if (t.kind != tk.TokenKind.Keyword && 
        t.kind != tk.TokenKind.Identifier && 
        t.kind != tk.TokenKind.Operator && 
        t.kind != tk.TokenKind.Punctuation &&
        t.kind != tk.TokenKind.Builtin
    ) {
        fmt.printfln("Expected field definition, got %s token at index %d", tk.token_to_string(t), new_index)
        show_next_n_tokens(tokens, new_index, 5)
        os.exit(1)
    }

    emitted := []string{}
    // handle fields
    for new_index < len(tokens) {
        t = tokens[new_index];
        if t.kind == tk.TokenKind.Punctuation && t.value == "}" {
            break;
        }

        // Collect tokens for a field
        field_tokens := [dynamic]string{};
        if t.kind == tk.TokenKind.Builtin {
            new_index, emitted = eval_builtin(program, tokens, new_index)
            for emitted_token in emitted {
                append(&field_tokens, emitted_token)
            }
            append(&program.generated_source_builder, strings.join(field_tokens[:], " "));
        } else {
            for new_index < len(tokens) {
                t = tokens[new_index];
                if t.kind == tk.TokenKind.Punctuation && (t.value == ";" || t.value == "}") {
                    break;
                }

                append(&field_tokens, t.value)
                new_index += 1;
            }

            // Append the field line
            append(&program.generated_source_builder, strings.join(field_tokens[:], " "));
            if new_index < len(tokens) && tokens[new_index].value == ";" {
                append(&program.generated_source_builder, ";");
                new_index += 1;
            } else {
                append(&program.generated_source_builder, "\n");
            }
        }
    }

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, "}")
    append(&program.generated_source_builder, "}")
    new_index += 1

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, ";")
    append(&program.generated_source_builder, ";")
    new_index += 1

    return new_index
}