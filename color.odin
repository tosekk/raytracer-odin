package raytracer

import "core:fmt"
import "core:math"
import "core:os"


Color :: Vec3


color_write_color :: proc(out: os.Handle, pixel_color: Color) {
    r: f64 = pixel_color.x
    g: f64 = pixel_color.y
    b: f64 = pixel_color.z

    r = color_linear_to_gamma(r)
    g = color_linear_to_gamma(g)
    b = color_linear_to_gamma(b)

    intensity: Interval = { 0, 0.999 }
    rbyte: int = int(255 * interval_clamp(intensity, r))
    gbyte: int = int(255 * interval_clamp(intensity, g))
    bbyte: int = int(255 * interval_clamp(intensity, b))

    color_code: string = fmt.tprintf("%d %d %d\n", rbyte, gbyte, bbyte)

    _, color_code_write_err := os.write(out, transmute([]byte)color_code)
    if color_code_write_err != os.ERROR_NONE {
        fmt.panicf("Could not write pixel color: %v", color_code_write_err)
    }
}

@(private)
color_linear_to_gamma :: proc(linear_component: f64) -> f64 {
    if linear_component > 0 {
        return math.sqrt_f64(linear_component)
    }

    return 0
}