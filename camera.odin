package raytracer

import "core:fmt"
import "core:os"


camera :: struct {
    aspect_ratio: f64,
    image_width: int,
    image_height: int,
    center: point3,
    pixel00_loc: point3,
    pixel_delta_u: vec3,
    pixel_delta_v: vec3,
}


camera_render :: proc(image_handle: os.Handle, cam: ^camera, world: []^hittable) {
    camera_initialize(cam)

    header: string = fmt.tprintf("P3\n%d %d\n255\n", cam.image_width, cam.image_height)

    _, header_write_err := os.write(image_handle, transmute([]byte)header)
    if header_write_err != os.ERROR_NONE {
        fmt.panicf("Could not write header: %v", header_write_err)
    }

    for j in 0..<cam.image_height {
        percent_progress: f64 = 100.0 * f64(j) / f64(cam.image_height)

        fmt.eprintf("\rTracing rays: {: 4d}/{: 4d} ({:.2f}%% done.)", j, cam.image_height, percent_progress)

        for i in 0..<cam.image_width {
            pixel_center: point3 = cam.pixel00_loc + (f64(i) * cam.pixel_delta_u) + (f64(j) * cam.pixel_delta_v)
            ray_direction: vec3 = pixel_center - cam.center
            r: ray = { cam.center, ray_direction }

            pixel_color: color = ray_color(r, world[:])
            write_color(image_handle, pixel_color)
        }
    }

    fmt.eprintf("\rDone.                                  \n")
}

@(private)
camera_initialize :: proc(cam: ^camera) {
    cam.image_height = int(f64(cam.image_width) / cam.aspect_ratio)
    cam.image_height = (cam.image_height < 1) ? 1 : cam.image_height

    focal_length: f64 = 1.0
    viewport_height: f64 = 2.0
    viewport_width: f64 = viewport_height * (f64(cam.image_width) / f64(cam.image_height))
    cam.center = { 0, 0, 0 }

    viewport_u: vec3 = { viewport_width, 0, 0 }
    viewport_v: vec3 = { 0, -viewport_height, 0 }

    cam.pixel_delta_u = viewport_u / f64(cam.image_width)
    cam.pixel_delta_v = viewport_v / f64(cam.image_height)

    viewport_upper_left: point3 = cam.center - vec3{ 0, 0, focal_length } - viewport_u / 2 - viewport_v / 2
    cam.pixel00_loc = viewport_upper_left + 0.5 * (cam.pixel_delta_u + cam.pixel_delta_v)
}

@(private)
ray_color :: proc(r: ray, world: []^hittable) -> color {
    rec: hit_record

    if (hit_multi(world, r, interval{ 0, INFINITY }, &rec)) {
        return 0.5 * (rec.normal + color{ 1, 1, 1 })
    }

    unit_direction: vec3 = vec3_unit_vector(r.direction)
    a: f64 = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * color{ 1.0, 1.0, 1.0 } + a * color{ 0.5, 0.7, 1.0 }
}