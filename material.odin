package raytracer

import "core:fmt"


Material :: struct {
    type: union { ^Lambertian, ^Metal },
    albedo: Color,
}

Lambertian :: struct {
    using _base: Material,
    // albedo: Color,
}

Metal :: struct {
    using _base: Material,
    fuzz: f64,
}

new_lambertian :: proc(albedo: Color) -> (lambertian: ^Lambertian) {
    lambertian = new(Lambertian)
    lambertian.type = lambertian
    lambertian.albedo = albedo
    return
}

new_metal :: proc(albedo: Color, fuzz: f64) -> (metal: ^Metal) {
    metal = new(Metal)
    metal.type = metal
    metal.albedo = albedo
    metal.fuzz = fuzz < 1 ? fuzz : 1
    return
}

scatter :: proc(r_in: Ray, rec: HitRecord) -> (ok: bool, attenuation: Color, scattered: Ray) {
    switch m in rec.mat.type {
        case ^Lambertian:
            scatter_direction: Vec3 = rec.normal + vec3_random_unit_vector()

            if vec3_near_zero(scatter_direction) {
                scatter_direction = rec.normal
            }

            scattered = Ray{ rec.p, scatter_direction }
            attenuation = m.albedo
            ok = true
        case ^Metal:
            reflected := vec3_reflect(r_in.direction, rec.normal)
            reflected = vec3_unit_vector(reflected) + (m.fuzz * vec3_random_unit_vector())
            scattered = Ray{ rec.p, reflected }
            attenuation = m.albedo
            ok = vec3_dot(scattered.direction, rec.normal) > 0
    }

    return
}