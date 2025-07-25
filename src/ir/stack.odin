package ir

Stack :: struct {
    values: [dynamic]StackValue,
    size: StackValue,
}

StackFrame :: struct {
    stack: Stack,
    instructions: []Instruction,
    instruction_pointer: int,
    variables: map[string]StackValue,
}

StackValue :: union {
    i64,
    u64,
    f64,
    string,
    rune,
    bool,
    // TODO: think about how to handle structs and arrays
}