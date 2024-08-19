package raytracer

import "core:math"


sphere :: struct {
    using _base: hittable,
    center: point3,
    radius: f64,
}


new_sphere :: proc(center: point3, radius: f64) -> (s: ^sphere) {
    s = new(sphere)
    s.type = s
    s.center = center
    s.radius = radius
    return
}

hit_multi :: proc(objects: []^hittable, r: ray, ray_t: interval, rec: ^hit_record) -> bool {
    temp_rec: hit_record
    hit_anything: bool
    closest_so_far: f64 = ray_t.max

    for object in objects {
        #partial switch o in object.type {
            case ^sphere:
                if sphere_hit(o, r, interval{ ray_t.min, closest_so_far }, &temp_rec) {
                    hit_anything = true
                    closest_so_far = temp_rec.t
                    rec^ = temp_rec
                }
        }
    }

    return hit_anything
}

sphere_hit :: proc(s: ^sphere, r: ray, ray_t: interval, rec: ^hit_record) -> bool {
    oc: vec3 = s.center - r.origin
    a: f64 = vec3_length_squared(r.direction)
    h: f64 = vec3_dot(r.direction, oc)
    c: f64 = vec3_length_squared(oc) - s.radius * s.radius

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
    outward_normal: vec3 = (rec.p - s.center) / s.radius
    hit_record_set_front_face(rec, r, outward_normal)

    return true
}