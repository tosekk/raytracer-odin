package raytracer

import "core:fmt"
import "core:os"

IMAGE_PATH : string: "images/image.ppm"

main :: proc() {
    image_width: int = 256
    image_height: int = 256

    file, open_err := os.open(IMAGE_PATH, os.O_CREATE | os.O_RDWR)
    defer os.close(file)

    if open_err != os.ERROR_NONE {
        fmt.panicf("Could not open file at \"%s\": %v", IMAGE_PATH, open_err)
    }

    header: string = fmt.tprintf("P3\n%d %d\n255\n", image_width, image_height)

    _, header_write_err := os.write(file, transmute([]byte)header)
    if header_write_err != os.ERROR_NONE {
        fmt.panicf("Could not write header: %v", header_write_err)
    }

    for j in 0..<image_height {
        percent_progress: f32 = 100.0 * f32(j) / f32(image_height)

        fmt.eprintf("\rTracing rays: {: 4d}/{: 4d} ({:.2f}%% done.)", j, image_height, percent_progress)

        for i in 0..<image_width {
            r: f32 = f32(i) / f32(image_width - 1)
            g: f32 = f32(j) / f32(image_height - 1)
            b: f32 = 0

            ir: int = int(255.999 * r)
            ig: int = int(255.999 * g)
            ib: int = int(255.999 * b)

            pixel_color: string = fmt.tprintf("%d %d %d\n", ir, ig, ib)

            _, pixel_color_write_err := os.write(file, transmute([]byte)pixel_color)
            if pixel_color_write_err != os.ERROR_NONE {
                fmt.panicf("Could not write pixel color: %v", pixel_color_write_err)
            }
        }
    }
 
    fmt.eprintf("\rDone.                                  \n")
}