package raytracer


HitRecord :: struct {
    p: Point3,
    normal: Vec3,
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