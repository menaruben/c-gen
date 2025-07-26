#include "linalg.h"

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