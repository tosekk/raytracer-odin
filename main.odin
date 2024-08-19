package raytracer

import "core:fmt"
import "core:os"

IMAGE_PATH : string: "images/image.ppm"

main :: proc() {
    image_width: int = 256
    image_height: int = 256

    image_handle, open_err := os.open(IMAGE_PATH, os.O_CREATE | os.O_RDWR)
    defer os.close(image_handle)

    if open_err != os.ERROR_NONE {
        fmt.panicf("Could not open image_handle at \"%s\": %v", IMAGE_PATH, open_err)
    }

    header: string = fmt.tprintf("P3\n%d %d\n255\n", image_width, image_height)

    _, header_write_err := os.write(image_handle, transmute([]byte)header)
    if header_write_err != os.ERROR_NONE {
        fmt.panicf("Could not write header: %v", header_write_err)
    }

    for j in 0..<image_height {
        percent_progress: f64 = 100.0 * f64(j) / f64(image_height)

        fmt.eprintf("\rTracing rays: {: 4d}/{: 4d} ({:.2f}%% done.)", j, image_height, percent_progress)

        for i in 0..<image_width {
            pixel_color: color = { f64(i) / f64(image_width - 1), f64(j) / f64(image_height - 1), 0 }
            write_color(image_handle, pixel_color)
        }
    }
 
    fmt.eprintf("\rDone.                                  \n")
}