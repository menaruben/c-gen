package ir

Instruction :: union {
    Push,
    Pop,
    Add,
    Sub,
    Mul,
    Div,
    Mod,
    And,
    Or,
    Xor,
    Not,
    Equal,
    NotEqual,
    LessThan,
    GreaterThan,
    LessThanOrEqual,
    GreaterThanOrEqual,
    Label,
    Jump,
    JumpIfTrue,
    JumpIfFalse,
    Return,
}

Push :: struct {
    value: StackValue,
}

Pop :: struct {
    into_var: string,
}

Add :: struct {
    left: StackValue,
    right: StackValue,
}

Sub :: struct {
    left: StackValue,
    right: StackValue,
}

Mul :: struct {
    left: StackValue,
    right: StackValue,
}

Div :: struct {
    left: StackValue,
    right: StackValue,
}

Mod :: struct {
    left: StackValue,
    right: StackValue,
}

And :: struct {
    left: StackValue,
    right: StackValue,
}

Or :: struct {
    left: StackValue,
    right: StackValue,
}

Xor :: struct {
    left: StackValue,
    right: StackValue,
}

Not :: struct {
    value: StackValue,
}

Equal :: struct {
    left: StackValue,
    right: StackValue,
}

NotEqual :: struct {
    left: StackValue,
    right: StackValue,
}


LessThan :: struct {
    left: StackValue,
    right: StackValue,
}

GreaterThan :: struct {
    left: StackValue,
    right: StackValue,
}

LessThanOrEqual :: struct {
    left: StackValue,
    right: StackValue,
}

GreaterThanOrEqual :: struct {
    left: StackValue,
    right: StackValue,
}

Label :: struct {
    name: string,
}

Jump :: struct {
    target: string,
}

JumpIfTrue :: struct {
    truthy_condition: StackValue,
    target: string,
}

JumpIfFalse :: struct {
    falsy_condition: StackValue,
    target: string,
}

Return :: struct {
    value: StackValue,
    return_stack: Stack,
}

Call :: struct {
    function_name: string,
    arguments: []StackValue,
}
