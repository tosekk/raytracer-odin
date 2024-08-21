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

    material_ground: ^Lambertian = new_lambertian(Color{ 0.8, 0.8, 0 })
    material_center: ^Lambertian = new_lambertian(Color{ 0.1, 0.2, 0.5 })
    material_left: ^Metal = new_metal(Color{ 0.8, 0.8, 0.8 }, 0.3)
    material_right: ^Metal = new_metal(Color{ 0.8, 0.6, 0.2 }, 1.0)

    append(&world, new_sphere(Point3{ 0, -100.5, -1 }, 100, material_ground))
    append(&world, new_sphere(Point3{ 0, 0, -1.2 }, 0.5, material_center))
    append(&world, new_sphere(Point3{ -1.0, 0, -1.0 }, 0.5, material_left))
    append(&world, new_sphere(Point3{ 1.0, 0, -1.0 }, 0.5, material_right))

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