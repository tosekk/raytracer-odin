package raytracer

import "core:math"


// Distinct types: https://odin-lang.org/docs/overview/#distinct-types
Vec3 :: distinct [3]f64
Point3 :: Vec3


vec3_length :: proc(v: Vec3) -> f64 {
    return math.sqrt_f64(vec3_length_squared(v))
}

vec3_length_squared :: proc(v: Vec3) -> f64 {
    return v.x * v.x + v.y * v.y + v.z * v.z
}

vec3_random :: proc{ vec3_random_vec, vec3_random_in_range }
vec3_random_vec :: proc() -> Vec3 {
    return Vec3{ random_double(), random_double(), random_double() }
}

vec3_random_in_range :: proc(min, max: f64) -> Vec3 {
    return Vec3{ random_double(min, max), random_double(min, max), random_double(min, max) }
}

vec3_dot :: proc(v, u: Vec3) -> f64 {
    return u.x * v.x + u.y * v.y + u.z * v.z
}

vec3_cross :: proc(v, u: Vec3) -> Vec3 {
    return Vec3{
        u.y * v.z - u.z * v.y,
        u.z * v.x - u.x * v.z,
        u.x * v.y - u.y * v.x
    }
}

vec3_unit_vector :: proc(v: Vec3) -> Vec3 {
    return v / vec3_length(v)
}

vec3_random_in_unit_sphere :: proc() -> Vec3 {
    for {
        p: Vec3 = vec3_random(-1, 1)
        if vec3_length_squared(p) < 1 {
            return p
        }
    }
}

vec3_random_unit_vector :: proc() -> Vec3 {
    return vec3_unit_vector(vec3_random_in_unit_sphere())
}

vec3_random_on_hemisphere :: proc(normal: Vec3) -> Vec3 {
    on_unit_sphere: Vec3 = vec3_random_in_unit_sphere()
    
    if vec3_dot(on_unit_sphere, normal) > 0.0 {
        return on_unit_sphere
    }

    return -on_unit_sphere
}