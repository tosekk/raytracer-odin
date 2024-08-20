package raytracer


Ray :: struct {
    origin: Point3,
    direction: Vec3,
}


ray_at :: proc(r: Ray, t: f64) -> Point3 {
    return r.origin + t * r.direction
}