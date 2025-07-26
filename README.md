# cgen
> ⚠️ This is a work in progress so syntax and features or ideas may change in the future.

## Examples
`cgen`-files are a form of template files to enable generics and other
metaprogramming things for C. Let's say we want to have a vector struct that has a specific number of fields depending on a number `N`.

The vectors field types are of type `T`. We also want to be able
to add two of these vectors with a function that is dynamically generated:

> comments are not yet supported but I have them here for educational purposes
```c
@comptime(T, N)                         // define comtpime constants
@alias(Vec = struct Vec_${N}D_${T})     // create alias that get resolved in identifiers

// create struct of name depending on the comptime constants
struct Vec_${N}D_${T} {
    /*
        dynamically create N fields
        `..=` inclusive range from lhs to rhs, step size 1
        `..<` exclusive range from lhs to rhs, step size 1 
    */
    @for (i : 1 ..= ${N}) { 
        ${T} dim_${i};
    }
};

// use of alias that gets resolved in return value and name of function
${Vec} vec_add_${N}d_${T}
(
    ${Vec} a, // another use of the alias
    ${Vec} b
) {
    ${Vec} result = {0};

    // dynamically emit statements
    @for (i : 1 ..= ${N}) {
        result.dim_${i} = a.dim_${i} + b.dim_${i};
    }

    return result;
}
```

Let's assume `T=int` and `N=3`. This would generate the following C code:
```c
struct Vec_3_int
{
    int dim_1;
    int dim_2;
    int dim_3;
};
struct Vec_3_int vec_add_3_int(struct Vec_3_int a, struct Vec_3_int b)
{
    struct Vec_3_int result = {0};
    result.dim_1 = a.dim_1 + b.dim_1;
    result.dim_2 = a.dim_2 + b.dim_2;
    result.dim_3 = a.dim_3 + b.dim_3;
    return result;
}
```

In the future I would like to read the comptime constants from a header file. 
This allows the user to program with the interfaces given by the header file and the code generator will generate the C code for the user without needing to write the C code by hand for every possible combination of `T` and `N` they want to use. They just need to write the cgen file and the header file. 
