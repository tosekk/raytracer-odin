package raytracer

import "core:fmt"


HitRecord :: struct {
    p: Point3,
    normal: Vec3,
    mat: Material,
    t: f64,
    front_face: bool,
}

Hittable :: struct {
    type: union{ ^Sphere, ^BVH, ^HittableList },
}


hit_record_set_front_face :: proc(rec: ^HitRecord, r: Ray, outward_normal: Vec3) {
    rec.front_face = vec3_dot(r.direction, outward_normal) < 0
    rec.normal = rec.front_face ? outward_normal : -outward_normal
}

hittable_hit :: proc { hittable_hit_multi, hittable_hit_single }
hittable_hit_multi :: proc(objects: []^Hittable, r: Ray, ray_t: ^Interval, rec: ^HitRecord) -> bool {
    temp_rec: HitRecord
    hit_anything: bool
    closest_so_far: f64 = ray_t.max
    is_hit: bool

    for object in objects {
        #partial switch o in object.type {
            case ^Sphere:
                if sphere_hit(o, r, Interval{ ray_t.min, closest_so_far }, &temp_rec) {
                    is_hit = true
                }
            case ^BVH:
                if bvh_hit(o, r, &Interval{ ray_t.min, closest_so_far }, &temp_rec) {
                    is_hit = true
                }
        }

        if is_hit {
            hit_anything = true
            closest_so_far = temp_rec.t
            rec^ = temp_rec
        }
    }

    return hit_anything
}

hittable_hit_single :: proc(object: ^Hittable, r: Ray, ray_t: ^Interval, rec: ^HitRecord) -> bool {
    temp_rec: HitRecord
    hit_anything: bool
    closest_so_far: f64 = ray_t.max
    is_hit: bool

    #partial switch o in object.type {
        case ^Sphere:
            if sphere_hit(o, r, Interval{ ray_t.min, closest_so_far }, &temp_rec) {
                is_hit = true
            }
        case ^BVH:
            if bvh_hit(o, r, &Interval{ ray_t.min, closest_so_far }, &temp_rec) {
                is_hit = true
            }
    }

    hit_anything = true
    closest_so_far = temp_rec.t
    rec^ = temp_rec

    return hit_anything
}

hittable_bounding_box :: proc(hittable: ^Hittable) -> ^AABB {
    #partial switch h in hittable.type {
        case ^Sphere:
            return h.bbox
        case ^BVH:
            return h.bbox
    }
    return new(AABB)
}