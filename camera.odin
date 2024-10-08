package raytracer

import "core:fmt"
import "core:math"
import "core:os"


Camera :: struct {
    aspect_ratio: f64,
    image_width: int,
    samples_per_pixel: int,
    max_depth: int,
    vfov: f64,
    lookfrom: Point3,
    lookat: Point3,
    vup: Vec3,
    defocus_angle: f64,
    focus_dist: f64,
    image_height: int,
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u, pixel_delta_v: Vec3,
    pixel_samples_scale: f64,
    u, v, w: Vec3,
    defocus_disk_u, defocus_disk_v: Vec3,
}


camera_render :: proc(image_handle: os.Handle, cam: ^Camera, world: ^HittableList) {
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
                r: Ray = camera_get_ray(cam, i, j)
                pixel_color += camera_ray_color(r, cam.max_depth, world)
            }
            color_write_color(image_handle, cam.pixel_samples_scale * pixel_color)
        }
    }

    fmt.eprintf("\rDone.                                  \n")
}

@(private)
camera_initialize :: proc(cam: ^Camera) {
    cam.image_height = int(f64(cam.image_width) / cam.aspect_ratio)
    cam.image_height = (cam.image_height < 1) ? 1 : cam.image_height

    cam.pixel_samples_scale = 1.0 / f64(cam.samples_per_pixel)

    cam.center = cam.lookfrom

    theta: f64 = degrees_to_radians(cam.vfov)
    h: f64 = math.tan_f64(theta / 2)
    viewport_height: f64 = 2.0 * h * cam.focus_dist
    viewport_width: f64 = viewport_height * (f64(cam.image_width) / f64(cam.image_height))

    cam.w = vec3_unit_vector(cam.lookfrom - cam.lookat)
    cam.u = vec3_unit_vector(vec3_cross(cam.vup, cam.w))
    cam.v = vec3_cross(cam.w, cam.u)

    viewport_u: Vec3 = viewport_width * cam.u
    viewport_v: Vec3 = viewport_height * -cam.v

    cam.pixel_delta_u = viewport_u / f64(cam.image_width)
    cam.pixel_delta_v = viewport_v / f64(cam.image_height)

    viewport_upper_left: Point3 = cam.center - (cam.focus_dist * cam.w) - viewport_u / 2 - viewport_v / 2
    cam.pixel00_loc = viewport_upper_left + 0.5 * (cam.pixel_delta_u + cam.pixel_delta_v)

    defocus_radius: f64 = cam.focus_dist * math.tan_f64(degrees_to_radians(cam.defocus_angle / 2))
    cam.defocus_disk_u = cam.u * defocus_radius
    cam.defocus_disk_v = cam.v * defocus_radius
}

@(private)
camera_ray_color :: proc(r: Ray, depth: int, world: ^HittableList) -> Color {
    if depth <= 0 {
        return Color{ 0, 0, 0 }
    }

    rec: HitRecord

    if (hittable_hit(world.objects[:], r, &Interval{ 0.001, INFINITY }, &rec)) {
        if ok, attenuation, scattered := material_scatter(r, rec); ok {
            return attenuation * camera_ray_color(scattered, depth - 1, world)
        }

        return Color{ 0, 0, 0 }
    }

    unit_direction: Vec3 = vec3_unit_vector(r.direction)
    a: f64 = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * Color{ 1.0, 1.0, 1.0 } + a * Color{ 0.5, 0.7, 1.0 }
}

@(private)
camera_get_ray :: proc(cam: ^Camera, i, j: int) -> Ray {
    offset: Vec3 = camera_sample_square()
    pixel_sample: Point3 = cam.pixel00_loc + ((f64(i) + offset.x) * cam.pixel_delta_u) + ((f64(j) + offset.y) * cam.pixel_delta_v)

    ray_origin: Point3 = cam.defocus_angle <= 0 ? cam.center : camera_defocus_disk_sample(cam)
    ray_direction: Vec3 = pixel_sample - ray_origin
    ray_time: f64 = random_double()

    return Ray{ ray_origin, ray_direction, ray_time }
}

@(private)
camera_sample_square :: proc() -> Vec3 {
    return Vec3{ random_double() - 0.5, random_double() - 0.5, 0 }
}

@(private)
camera_defocus_disk_sample :: proc(cam: ^Camera) -> Point3 {
    p: Vec3 = vec3_random_in_unit_disk()
    return cam.center + (p.x * cam.defocus_disk_u) + (p.y * cam.defocus_disk_v)
}
