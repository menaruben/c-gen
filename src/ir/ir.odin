package ir

/* 
    The Intermediate Representation (IR)  is a stack based language that is used to interpret the meta and code blocks 
    in the .cgen files at `compile time`.
*/

IrProgram :: struct {
    functions: map[string]IrFunction,
    stack: [dynamic]StackValue,
    comptime_ids: [dynamic]string,
    comptime_aliases: map[string]string,
}

IrFunction :: struct {
    name: string,
    instructions: []Instruction,
    instruction_pointer: int,
    stack: [dynamic]StackValue,
    labels: map[string]int,
    local_vars: map[string]StackValue,
}
