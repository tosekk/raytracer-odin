package raytracer

import "core:math"
import "core:math/rand"


INFINITY: f64: (0h7ff0_0000_0000_0000)
NEGATIVE_INFINITY: f64: (0hfff0_0000_0000_0000)
PI: f64: 3.1415926535897932385

degrees_to_radians :: proc(degrees: f64) -> f64 {
    return degrees * PI / 180
}

random_double :: proc { random_f64, random_f64_in_range }

random_f64 :: proc() -> f64 {
    return rand.float64()
}

random_f64_in_range :: proc(min, max: f64) -> f64 {
    return min + (max - min) * random_f64()
}