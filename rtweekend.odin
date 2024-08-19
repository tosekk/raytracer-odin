package raytracer

import "core:math"


INFINITY: f64: (0h7ff0_0000_0000_0000)
NEGATIVE_INFINITY: f64: (0hfff0_0000_0000_0000)
PI: f64: 3.1415926535897932385

degrees_to_radians :: proc(degrees: f64) -> f64 {
    return degrees * PI / 180
}