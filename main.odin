package raytracer

import "core:fmt"
import "core:math"
import "core:os"


IMAGE_PATH : string: "images/image.ppm"


main :: proc() {
    world: [dynamic]^Hittable
    defer {
        for h in world {
            free(h)
        }
        delete(world)
    }

    append(&world, new_sphere(Point3{ 0, 0, -1 }, 0.5))
    append(&world, new_sphere(Point3{ 0, -100.5, -1 }, 100))

    cam: Camera

    cam.aspect_ratio = 16.0 / 9.0
    cam.image_width = 400
    cam.samples_per_pixel = 100
    cam.max_depth = 50

    image_handle, open_err := os.open(IMAGE_PATH, os.O_CREATE | os.O_RDWR)
    defer os.close(image_handle)

    if open_err != os.ERROR_NONE {
        fmt.panicf("Could not open image_handle at \"%s\": %v", IMAGE_PATH, open_err)
    }

    camera_render(image_handle, &cam, world[:]) 
}