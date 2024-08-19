package raytracer

import "core:fmt"
import "core:os"


color :: vec3


write_color :: proc(out: os.Handle, pixel_color: color) {
    r: f64 = pixel_color.x
    g: f64 = pixel_color.y
    b: f64 = pixel_color.z

    rbyte: int = int(255.999 * r)
    gbyte: int = int(255.999 * g)
    bbyte: int = int(255.999 * b)

    color_code: string = fmt.tprintf("%d %d %d\n", rbyte, gbyte, bbyte)

    _, color_code_write_err := os.write(out, transmute([]byte)color_code)
    if color_code_write_err != os.ERROR_NONE {
        fmt.panicf("Could not write pixel color: %v", color_code_write_err)
    }
}