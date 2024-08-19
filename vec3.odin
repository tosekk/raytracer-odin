package raytracer

import "core:math"


// Distinct types: https://odin-lang.org/docs/overview/#distinct-types
vec3 :: distinct [3]f64
point3 :: vec3


vec3_length :: proc(v: vec3) -> f64 {
    return math.sqrt_f64(vec3_length_squared(v))
}

vec3_length_squared :: proc(v: vec3) -> f64 {
    return v.x * v.x + v.y * v.y + v.z * v.z
}

vec3_dot :: proc(v, u: vec3) -> f64 {
    return u.x * v.x + u.y * v.y + u.z * v.z
}

vec3_cross :: proc(v, u: vec3) -> vec3 {
    return vec3{
        u.y * v.z - u.z * v.y,
        u.z * v.x - u.x * v.z,
        u.x * v.y - u.y * v.x
    }
}

vec3_unit_vector :: proc(v: vec3) -> vec3 {
    return v / vec3_length(v)
}