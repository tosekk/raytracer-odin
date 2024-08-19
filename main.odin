package raytracer

import "core:fmt"
import "core:math"
import "core:os"


IMAGE_PATH : string: "images/image.ppm"


ray_color :: proc(r: ray, world: []^hittable) -> color {
    rec: hit_record

    if (hit_multi(world, r, interval{ 0, INFINITY }, &rec)) {
        return 0.5 * (rec.normal + color{ 1, 1, 1 })
    }

    unit_direction: vec3 = vec3_unit_vector(r.direction)
    a: f64 = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * color{ 1.0, 1.0, 1.0 } + a * color{ 0.5, 0.7, 1.0 }
}

main :: proc() {
    world: [dynamic]^hittable
    defer {
        for h in world {
            free(h)
        }
        delete(world)
    }

    append(&world, new_sphere(point3{ 0, 0, -1 }, 0.5))
    append(&world, new_sphere(point3{ 0, -100.5, -1 }, 100))

    aspect_ratio: f64 = 16.0 / 9.0
    image_width: int = 400

    image_height: int = int(f64(image_width) / aspect_ratio)
    image_height = (image_height < 1) ? 1 : image_height

    focal_length: f64 = 1.0
    viewport_height: f64 = 2.0
    viewport_width: f64 = viewport_height * (f64(image_width) / f64(image_height))
    camera_center: point3 = { 0, 0, 0 }

    viewport_u: vec3 = { viewport_width, 0, 0 }
    viewport_v: vec3 = { 0, -viewport_height, 0 }

    pixel_delta_u: vec3 = viewport_u / f64(image_width)
    pixel_delta_v: vec3 = viewport_v / f64(image_height)

    viewport_upper_left: point3 = camera_center - vec3{ 0, 0, focal_length } - viewport_u / 2 - viewport_v / 2
    pixel00_loc: point3 = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

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
            pixel_center: point3 = pixel00_loc + (f64(i) * pixel_delta_u) + (f64(j) * pixel_delta_v)
            ray_direction: vec3 = pixel_center - camera_center
            r: ray = { camera_center, ray_direction }

            pixel_color: color = ray_color(r, world[:])
            write_color(image_handle, pixel_color)
        }
    }
 
    fmt.eprintf("\rDone.                                  \n")
}