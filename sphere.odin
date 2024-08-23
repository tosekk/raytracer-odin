package raytracer

import "core:math"


Sphere :: struct {
    using _base: Hittable,
    center1: Point3,
    radius: f64,
    mat: Material,
    is_moving: bool,
    center_vec: Vec3,
    bbox: ^AABB,
}


new_sphere :: proc { new_stationary_sphere, new_moving_sphere }
new_stationary_sphere :: proc(center: Point3, radius: f64, mat: Material) -> (sphere: ^Sphere) {
    sphere = new(Sphere)
    sphere.type = sphere
    sphere.center1 = center
    sphere.radius = radius
    sphere.mat = mat
    sphere.is_moving = false

    rvec := Vec3{ radius, radius, radius }
    sphere.bbox = new_aabb(center - rvec, center + rvec)

    return
}

new_moving_sphere :: proc(center1, center2: Point3, radius: f64, mat: Material) -> (sphere: ^Sphere) {
    sphere = new(Sphere)
    sphere.type = sphere
    sphere.center1 = center1
    sphere.radius = radius
    sphere.mat = mat
    sphere.is_moving = true
    sphere.center_vec = center2 - center1

    rvec := Vec3{ radius, radius, radius }
    box1: ^AABB = new_aabb(center1 - rvec, center1 + rvec)
    box2: ^AABB = new_aabb(center2 - rvec, center2 + rvec)
    sphere.bbox = new_aabb(box1, box2)

    return
}

sphere_hit :: proc(sphere: ^Sphere, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
    center: Point3 = sphere.is_moving ? sphere_center(sphere, r.time) : sphere.center1
    oc: Vec3 = center - r.origin
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
    outward_normal: Vec3 = (rec.p - center) / sphere.radius
    hit_record_set_front_face(rec, r, outward_normal)
    rec.mat = sphere.mat

    return true
}

sphere_center :: proc(sphere: ^Sphere, time: f64) -> Vec3 {
    return sphere.center1 + time * sphere.center_vec
}

sphere_bounding_box :: proc(sphere: ^Sphere) -> ^AABB {
    return sphere.bbox
}