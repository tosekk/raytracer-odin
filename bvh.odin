package raytracer


BVH :: struct {
    left, right: ^Hittable,
    bbox: ^AABB,
}


bvh_hit :: proc(bvh: ^BVH, r: Ray, ray_t: ^Interval, rec: ^HitRecord) -> bool {
    if !aabb_hit(bvh.bbox, r, ray_t) {
        return false
    }

    hit_left: bool = hittable_hit([]^Hittable{ bvh.left }, r, ray_t, rec)
    hit_right: bool = hittable_hit([]^Hittable{ bvh.right }, r, ray_t, rec)

    return hit_left || hit_right
}