package raytracer

import "core:math"


Sphere :: struct {
    using _base: Hittable,
    center: Point3,
    radius: f64,
    mat: Material,
}


new_sphere :: proc(center: Point3, radius: f64, mat: Material) -> (sphere: ^Sphere) {
    sphere = new(Sphere)
    sphere.type = sphere
    sphere.center = center
    sphere.radius = radius
    sphere.mat = mat
    return
}

sphere_hit :: proc(sphere: ^Sphere, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
    oc: Vec3 = sphere.center - r.origin
    a: f64 = vec3_length_squared(r.direction)
    h: f64 = vec3_dot(r.direction, oc)
    c: f64 = vec3_length_squared(oc) - sphere.radius * sphere.radius

    discriminant: f64 = h * h - a * c
    if discriminant < 0 {
        return false
    }

    sqrtd: f64 = math.sqrt_f64(discriminant)

    root: f64 = (h - sqrtd) / a
    if !interval_surrounds(ray_t, root) {
        root = (h + sqrtd) / a
        if !interval_surrounds(ray_t, root) {
            return false
        }
    }

    rec.t = root
    rec.p = ray_at(r, rec.t)
    outward_normal: Vec3 = (rec.p - sphere.center) / sphere.radius
    hit_record_set_front_face(rec, r, outward_normal)
    rec.mat = sphere.mat

    return true
}