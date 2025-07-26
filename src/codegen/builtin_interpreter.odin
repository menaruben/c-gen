package codegen

import "core:strings"
import "core:strconv"
import "core:os"
import "core:fmt"
import tk "../tokenizer"

eval_builtin :: proc(program: ^GeneratedProgram, tokens: []tk.Token, index: int) -> (new_index: int, emitted: []string) {
    new_index = index
    emitted = []string{}
    token := tokens[new_index]
    new_index += 1
    
    switch token.value {
        case tk.BUILTIN_FOR:
            return handle_for_loop(program, tokens, new_index)

        case:
            // TODO: handle other builtins
            fmt.printfln("Unhandled builtin: %s at index %d", token.value, index)
            show_next_n_tokens(tokens, index, 5)
            os.exit(1)
    }

    return
}

@(private)
handle_for_loop :: proc(program: ^GeneratedProgram, tokens: []tk.Token, index: int) -> (new_index: int, emitted: []string) {
    new_index = index
    emitted_builder := [dynamic]string{}
    token := tokens[new_index]
    
    // for loop in form: @for (i : 1 ..= 10) { 
    //      literally anything, just gets copy and pasted (loop varaiable gets resolved if used in the body)
    // }

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, tk.PUNCT_LPAREN)
    new_index += 1

    // get loop variable
    loop_var := get_value_of_expected_token_kind(tokens, new_index, tk.TokenKind.Identifier)
    new_index += 1

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, tk.PUNCT_COLON)
    new_index += 1

    // determine start value of loop
    start_value := tokens[new_index]
    new_index += 1

    if (start_value.kind != tk.TokenKind.IntegerLiteral &&
        start_value.kind != tk.TokenKind.Interpolation
    ) {
        fmt.printfln("Expected start value for loop, got %s at index %d", tk.token_to_string(start_value), new_index)
        show_next_n_tokens(tokens, new_index, 5)
        os.exit(1)
    }

    start_value_number: int
    ok: bool
    #partial switch start_value.kind {
        case tk.TokenKind.IntegerLiteral:
            start_value_number, ok = strconv.parse_int(start_value.value)
            if !ok {
                fmt.printfln("Invalid integer literal: %s at index %d", start_value.value, new_index)
                os.exit(1)
            }

        case tk.TokenKind.Interpolation:
            resolved_id := resolve_identifier(start_value.value, program.comptime_id_values, program.comptime_aliases)
            start_value_number, ok = strconv.parse_int(resolved_id)
            if !ok {
                fmt.printfln("Invalid interpolation value: %s at index %d", resolved_id, new_index)
                os.exit(1)
            }

        case:
            fmt.printfln("Expected integer literal or interpolation, got %s at index %d", tk.token_to_string(start_value), new_index)
            show_next_n_tokens(tokens, new_index, 5)
            os.exit(1)
    }

    // determine inclusive or exclusive range
    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, tk.PUNCT_DOT)
    new_index += 1

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, tk.PUNCT_DOT)
    new_index += 1

    range_op := get_value_of_expected_token_kind(tokens, new_index, tk.TokenKind.Operator)
    new_index += 1

    is_inclusive := false
    switch range_op {
        case "=":
            is_inclusive = true

        case "<":
            is_inclusive = false

        case:
            fmt.printfln("Expected '=' or '<', got %s at index %d", range_op, new_index)
            show_next_n_tokens(tokens, new_index, 5)
            os.exit(1)
    }

    // determine end value of loop
    end_value := tokens[new_index]
    new_index += 1

    if (end_value.kind != tk.TokenKind.IntegerLiteral &&
        end_value.kind != tk.TokenKind.Interpolation
    ) {
        fmt.printfln("Expected end value for loop, got %s at index %d", tk.token_to_string(end_value), new_index)
        os.exit(1)
    }

    end_value_number: int
    #partial switch end_value.kind {
        case tk.TokenKind.IntegerLiteral:
            end_value_number, ok = strconv.parse_int(end_value.value)
            if !ok {
                fmt.printfln("Invalid integer literal: %s at index %d", end_value.value, new_index)
                os.exit(1)
            }

        case tk.TokenKind.Interpolation:
            resolved_id := resolve_identifier(end_value.value, program.comptime_id_values, program.comptime_aliases)
            end_value_number, ok = strconv.parse_int(resolved_id)
            if !ok {
                fmt.printfln("Invalid interpolation value: %s at index %d", resolved_id, new_index)
                os.exit(1)
            }

        case:
            fmt.printfln("Expected integer literal or interpolation, got %s at index %d", tk.token_to_string(end_value), new_index)
            show_next_n_tokens(tokens, new_index, 5)
            os.exit(1)
    }

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, ")")
    new_index += 1

    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, "{")
    new_index += 1

    // get body of the loop
    loop_body := [dynamic]string{}

    for new_index < len(tokens) && tokens[new_index].value != tk.PUNCT_RBRACE {
        t := tokens[new_index]
        if t.kind == tk.TokenKind.Punctuation && t.value == "}" {
            break
        }

        // Collect tokens for the loop body
        append(&loop_body, t.value)
        new_index += 1
    }

    // loop over body
    if is_inclusive {
        for i := start_value_number; i <= end_value_number; i += 1 {
            // resolve loop variable and store in comptime_id_values
            program.comptime_aliases[loop_var] = fmt.tprintf("%d", i)

            // append loop body to emitted code
            for loop_token in loop_body {
                append(&emitted_builder, resolve_identifier(loop_token, program.comptime_id_values, program.comptime_aliases))
            }
        }
    } else {
        for i := start_value_number; i < end_value_number; i += 1 {
            // resolve loop variable and store in comptime_id_values
            program.comptime_aliases[loop_var] = fmt.tprintf("%d", i)

            // append loop body to emitted code
            for loop_token in loop_body {
                append(&emitted_builder, resolve_identifier(loop_token, program.comptime_id_values, program.comptime_aliases))
            }
        }
    }

    // TODO: remove loop_var from comptime_id_values
    expect_token_with_value(tokens, new_index, tk.TokenKind.Punctuation, tk.PUNCT_RBRACE)
    new_index += 1

    return new_index, emitted_builder[:]
}