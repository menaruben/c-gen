package codegen

import tk "../tokenizer"
import "core:fmt"

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
