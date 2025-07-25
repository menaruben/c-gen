package main

import "core:bytes"
import "core:strings"
import "core:path/filepath"
import "core:fmt"
import "core:os"
import t "tokenizer"

main :: proc() {
    tmpl_file, tmpl_ok := filepath.abs("./examples/linalg.cgen")
    if !tmpl_ok {
        fmt.println("Error getting absolute path for template file.")
        return
    }

    fmt.println("Using template file: ", tmpl_file)
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

    sucess := t.tokenize(&tokenizer)
    if !sucess {
        fmt.println("Tokenization failed.")
        return
    }

    for token, _ in tokenizer.tokens {
        enum_name, ok  := fmt.enum_value_to_string(token.kind)
        if !ok {
            enum_name = "Unknown"
        }
        fmt.printfln("Type: %s, Value: `%s`", enum_name, token.value)
    }
    fmt.println()
}
