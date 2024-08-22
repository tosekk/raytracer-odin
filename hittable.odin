package raytracer


HitRecord :: struct {
    p: Point3,
    normal: Vec3,
    mat: Material,
    t: f64,
    front_face: bool,
}

Hittable :: struct {
    type: union{ ^Sphere }
}


hit_record_set_front_face :: proc(rec: ^HitRecord, r: Ray, outward_normal: Vec3) {
    rec.front_face = vec3_dot(r.direction, outward_normal) < 0
    rec.normal = rec.front_face ? outward_normal : -outward_normal
}

hittable_hit :: proc(objects: []^Hittable, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
    temp_rec: HitRecord
    hit_anything: bool
    closest_so_far: f64 = ray_t.max

    for object in objects {
        #partial switch o in object.type {
            case ^Sphere:
                if sphere_hit(o, r, Interval{ ray_t.min, closest_so_far }, &temp_rec) {
                    hit_anything = true
                    closest_so_far = temp_rec.t
                    rec^ = temp_rec
                }
        }
    }

    return hit_anything
}