package raytracer

import "core:fmt"
import "core:os"


Camera :: struct {
    aspect_ratio: f64,
    image_width: int,
    samples_per_pixel: int,
    max_depth: int,
    image_height: int,
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    pixel_samples_scale: f64,
}


camera_render :: proc(image_handle: os.Handle, cam: ^Camera, world: []^Hittable) {
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
            pixel_color: Color = { 0, 0, 0 }
            for sample in 0..<cam.samples_per_pixel {
                r: Ray = get_ray(cam, i, j)
                pixel_color += ray_color(r, cam.max_depth, world)
            }
            write_color(image_handle, cam.pixel_samples_scale * pixel_color)
        }
    }

    fmt.eprintf("\rDone.                                  \n")
}

@(private)
camera_initialize :: proc(cam: ^Camera) {
    cam.image_height = int(f64(cam.image_width) / cam.aspect_ratio)
    cam.image_height = (cam.image_height < 1) ? 1 : cam.image_height

    cam.pixel_samples_scale = 1.0 / f64(cam.samples_per_pixel)

    focal_length: f64 = 1.0
    viewport_height: f64 = 2.0
    viewport_width: f64 = viewport_height * (f64(cam.image_width) / f64(cam.image_height))
    cam.center = { 0, 0, 0 }

    viewport_u: Vec3 = { viewport_width, 0, 0 }
    viewport_v: Vec3 = { 0, -viewport_height, 0 }

    cam.pixel_delta_u = viewport_u / f64(cam.image_width)
    cam.pixel_delta_v = viewport_v / f64(cam.image_height)

    viewport_upper_left: Point3 = cam.center - Vec3{ 0, 0, focal_length } - viewport_u / 2 - viewport_v / 2
    cam.pixel00_loc = viewport_upper_left + 0.5 * (cam.pixel_delta_u + cam.pixel_delta_v)
}

@(private)
ray_color :: proc(r: Ray, depth: int, world: []^Hittable) -> Color {
    if depth <= 0 {
        return Color{ 0, 0, 0 }
    }

    rec: HitRecord

    if (hit(world, r, Interval{ 0.001, INFINITY }, &rec)) {
        if ok, attenuation, scattered := scatter(r, rec); ok {
            return attenuation * ray_color(scattered, depth - 1, world)
        }

        return Color{ 0, 0, 0 }
    }

    unit_direction: Vec3 = vec3_unit_vector(r.direction)
    a: f64 = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * Color{ 1.0, 1.0, 1.0 } + a * Color{ 0.5, 0.7, 1.0 }
}

@(private)
get_ray :: proc(cam: ^Camera, i, j: int) -> Ray {
    offset: Vec3 = sample_square()
    pixel_sample: Point3 = cam.pixel00_loc + ((f64(i) + offset.x) * cam.pixel_delta_u) + ((f64(j) + offset.y) * cam.pixel_delta_v)
    
    ray_origin: Point3 = cam.center
    ray_direction: Vec3 = pixel_sample - ray_origin

    return Ray{ ray_origin, ray_direction }
}

@(private)
sample_square :: proc() -> Vec3 {
    return Vec3{ random_double() - 0.5, random_double() - 0.5, 0 }
}