package raytracer

import "core:fmt"
import "core:math"


Material :: struct {
    type: union { ^Lambertian, ^Metal, ^Dielectric },
}

Lambertian :: struct {
    using _base: Material,
    albedo: Color,
}

Metal :: struct {
    using _base: Material,
    albedo: Color,
    fuzz: f64,
}

Dielectric :: struct {
    using _base: Material,
    refraction_index: f64,
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

new_dielectric :: proc(refraction_index: f64) -> (dielectric: ^Dielectric) {
    dielectric = new(Dielectric)
    dielectric.type = dielectric
    dielectric.refraction_index = refraction_index
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
        case ^Dielectric:
            attenuation = Color{ 1.0, 1.0, 1.0 }
            ri: f64 = rec.front_face ? (1.0 / m.refraction_index) : m.refraction_index

            unit_direction: Vec3 = vec3_unit_vector(r_in.direction)
            cos_theta: f64 = min(vec3_dot(-unit_direction, rec.normal), 1.0)
            sin_theta: f64 = math.sqrt_f64(1.0 - cos_theta * cos_theta)

            cannot_refract: bool = ri * sin_theta > 1.0
            direction: Vec3

            if (cannot_refract || dielectric_reflectance(cos_theta, ri) > random_double()) {
                direction = vec3_reflect(unit_direction, rec.normal)
            }

            direction = vec3_refract(unit_direction, rec.normal, ri)

            scattered = Ray{ rec.p, direction }
            ok = true
    }

    return
}

@(private)
dielectric_reflectance :: proc(cosine, refraction_index: f64) -> f64 {
    r0: f64 = (1.0 - refraction_index) / (1.0 + refraction_index)
    r0 = r0 * r0
    return r0 + (1 - r0) * math.pow_f64((1 - cosine), 5.0)
}