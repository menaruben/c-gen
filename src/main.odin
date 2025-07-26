package main

import "core:bytes"
import "core:strings"
import "core:path/filepath"
import "core:fmt"
import "core:os"
import t "tokenizer"
import "ir"

main :: proc() {
    if len(os.args) < 2 {
        fmt.println("Usage: main <template_file>")
        return
    }

    tmpl_file_path := os.args[1]
    tmpl_file, tmpl_ok := filepath.abs(tmpl_file_path)
    if !tmpl_ok {
        fmt.println("Error getting absolute path for template file.")
        return
    }

    tmpl_content, err := os.read_entire_file_or_err(tmpl_file)
    if err != nil {
        fmt.println("Error reading template file: ", err)
        return
    }

    tmpl_file_fields := strings.split(tmpl_file, ".")
    tmpl_without_ext := strings.join(tmpl_file_fields[:len(tmpl_file_fields)-1], ".")
    header_for_template := strings.concatenate({tmpl_without_ext, ".h"})
    
    header_content, header_err := os.read_entire_file_or_err(header_for_template)
    if header_err != nil {
        fmt.println("Error reading header file: ", header_err)
        return
    }
    
    tokens := [dynamic]t.Token{}
    tokenizer := t.Tokenizer{
        input = tmpl_content,
        position = 0,
        tokens = tokens,
    }

    success := t.tokenize(&tokenizer)
    if !success {
        fmt.println("Tokenization failed.")
        return
    }

    comptime_id_values := make(map[string]string)
    defer delete(comptime_id_values)

    comptime_id_values["T"] = "int"

    program := ir.generate_program(tokenizer.tokens[:], comptime_id_values)
    fmt.println("Generated Source:\n", strings.to_string(program.generated_source_builder))
}
