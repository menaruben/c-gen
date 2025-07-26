package codegen

import "core:strings"
import "core:fmt"
import tk "../tokenizer"

show_next_n_tokens :: proc(tokens: []tk.Token, index: int, n: int) {
    until := min(index + n, len(tokens) - 1)

    fmt.print("[    ")
    for t, ti in tokens[index:until] {
        t_enum_name, ok := fmt.enum_value_to_string(t.kind)
        if !ok {
            t_enum_name = "Unknown"
        }
        fmt.printf("<%s, `%s`>    ", t_enum_name, t.value)
    }
    fmt.printfln("...    ]")
}

get_literal_alias_value :: proc(alias_value: []tk.Token) -> string {
    sb := strings.Builder{}
    for t in alias_value {
        append(&sb.buf, t.value)
        append(&sb.buf, " ")
    }
    return strings.to_string(sb)
}