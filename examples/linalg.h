#ifndef __LINALG_H__
#define __LINALG_H__

// forward declaration of a 2D vector with int type
struct Vec_2D_int;

struct Vec_2D_int vec_add_2d_int(
    struct Vec_2D_int a, 
    struct Vec_2D_int b);

// forward declaration of a 2D vector with float type
struct Vec_3D_float;

struct Vec_3D_float vec_add_3d_float(
    struct Vec_3D_float a, 
    struct Vec_3D_float b);

#endif // __LINALG_H__
