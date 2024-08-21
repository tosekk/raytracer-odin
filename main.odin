package raytracer

import "core:fmt"
import "core:math"
import "core:os"


IMAGE_PATH : string: "images/image_test.ppm"


main :: proc() {
    world: [dynamic]^Hittable
    defer {
        for h in world {
            free(h)
        }
        delete(world)
    }

    switch 2 {
        case 1:
            three_spheres(&world)
        case 2:
            one_weekend_final_scene(&world)
    }

    cam: Camera

    cam.aspect_ratio = 16.0 / 9.0
    cam.image_width = 400
    cam.samples_per_pixel = 100
    cam.max_depth = 10
    
    cam.vfov = 20
    cam.lookfrom = Point3{ 13, 2, 3 }
    cam.lookat = Point3{ 0, 0, 0 }
    cam.vup = Vec3{ 0, 1, 0 }

    cam.defocus_angle = 0.6
    cam.focus_dist = 10.0

    image_handle, open_err := os.open(IMAGE_PATH, os.O_CREATE | os.O_RDWR)
    defer os.close(image_handle)

    if open_err != os.ERROR_NONE {
        fmt.panicf("Could not open image_handle at \"%s\": %v", IMAGE_PATH, open_err)
    }

    camera_render(image_handle, &cam, world[:]) 
}

three_spheres :: proc(world: ^[dynamic]^Hittable) {
    material_ground: ^Lambertian = new_lambertian(Color{ 0.8, 0.8, 0 })
    material_center: ^Lambertian = new_lambertian(Color{ 0.1, 0.2, 0.5 })
    material_left: ^Dielectric = new_dielectric(1.5)
    material_bubble: ^Dielectric = new_dielectric(1.0 / 1.5)
    material_right: ^Metal = new_metal(Color{ 0.8, 0.6, 0.2 }, 1.0)

    append(world, new_sphere(Point3{ 0, -100.5, -1 }, 100, material_ground))
    append(world, new_sphere(Point3{ 0, 0, -1.2 }, 0.5, material_center))
    append(world, new_sphere(Point3{ -1.0, 0, -1.0 }, 0.5, material_left))
    append(world, new_sphere(Point3{ -1.0, 0, -1.0 }, 0.4, material_bubble))
    append(world, new_sphere(Point3{ 1.0, 0, -1.0 }, 0.5, material_right))
}

one_weekend_final_scene :: proc(world: ^[dynamic]^Hittable) {
    ground_material: ^Lambertian = new_lambertian(Color{ 0.5, 0.5, 0.5 })
    append(world, new_sphere(Point3{ 0, -1000, 0 }, 1000, ground_material))

    for a in -11..<11 {
        for b in -11..<11 {
            choose_mat: f64 = random_double()
            center: Point3 = { f64(a) + 0.9 * random_double(), 0.2, f64(b) + 0.9 * random_double() }

            if vec3_length(center - Point3{ 4, 0.2, 0 }) > 0.9 {
                sphere_material: Material

                if choose_mat < 0.8 {
                    albedo: Color = vec3_random() * vec3_random()
                    sphere_material = new_lambertian(albedo)
                    append(world, new_sphere(center, 0.2, sphere_material))
                } else if choose_mat < 0.95 {
                    albedo: Color = vec3_random(0.5, 1)
                    fuzz: f64 = random_double()
                    sphere_material = new_metal(albedo, fuzz)
                    append(world, new_sphere(center, 0.2, sphere_material))
                } else {
                    sphere_material = new_dielectric(1.5)
                    append(world, new_sphere(center, 0.2, sphere_material))
                }
            }
        }
    }

    material1: ^Dielectric = new_dielectric(1.5)
    append(world, new_sphere(Point3{ 0, 1, 0 }, 1.0, material1))

    material2: ^Lambertian = new_lambertian(Color{ 0.4, 0.2, 0.1 })
    append(world, new_sphere(Point3{ -4, 1, 0 }, 1.0, material2))

    material3: ^Metal = new_metal(Color{ 0.7, 0.6, 0.5 }, 0)
    append(world, new_sphere(Point3{ 4, 1, 0 }, 1.0, material3))
}