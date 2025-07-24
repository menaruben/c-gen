#include "linalg.h"

struct Vec_2D_int
{
    int dim_0;
    int dim_1;
};


struct Vec_2D_int vec_add_2d_int(
    struct Vec_2D_int a, 
    struct Vec_2D_int b)
{
    struct Vec_2D_int result;
    result.dim_0 = a.dim_0 + b.dim_0;
    result.dim_1 = a.dim_1 + b.dim_1;
    return result;
}

struct Vec_3D_float
{
    float dim_0;
    float dim_1;
    float dim_2;
};

struct Vec_3D_float vec_add_3d_float(
    struct Vec_3D_float a, 
    struct Vec_3D_float b)
{
    struct Vec_3D_float result;
    result.dim_0 = a.dim_0 + b.dim_0;
    result.dim_1 = a.dim_1 + b.dim_1;
    result.dim_2 = a.dim_2 + b.dim_2;
    return result;
}
