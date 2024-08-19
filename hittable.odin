package raytracer


hit_record :: struct {
    p: point3,
    normal: vec3,
    t: f64,
    front_face: bool,
}

hittable :: struct {
    type: union{ ^sphere }
}


hit_record_set_front_face :: proc(rec: ^hit_record, r: ray, outward_normal: vec3) {
    rec.front_face = vec3_dot(r.direction, outward_normal) < 0
    rec.normal = rec.front_face ? outward_normal : -outward_normal
}