package raytracer


AABB :: struct {
    x, y, z: Interval,
}

new_aabb :: proc { new_aabb_empty, new_aabb_interval, new_aabb_points, new_aabb_bboxes }
new_aabb_empty :: proc() -> (bbox: ^AABB) {
    bbox = new(AABB)
    return
}

new_aabb_interval :: proc(x, y, z: Interval) -> (bbox: ^AABB) {
    bbox = new(AABB)
    bbox.x = x
    bbox.y = y
    bbox.z = z
    return
}

new_aabb_points :: proc(a, b: Point3) -> (bbox: ^AABB) {
    bbox = new(AABB)
    bbox.x = (a.x <= b.x) ? Interval{ a.x, b.x } : Interval{ b.x, a.x }
    bbox.y = (a.y <= b.y) ? Interval{ a.y, b.y } : Interval{ b.y, a.y }
    bbox.z = (a.z <= b.z) ? Interval{ a.z, b.z } : Interval{ b.z, a.z }
    return
}

new_aabb_bboxes :: proc(box0, box1: ^AABB) -> (bbox: ^AABB) {
    bbox = new(AABB)
    bbox.x = new_interval(box0.x, box1.x)^
    bbox.y = new_interval(box0.y, box1.y)^
    bbox.z = new_interval(box0.z, box1.z)^
    return
}

aabb_axis_interval :: proc(bbox: ^AABB, n: int) -> Interval {
    switch n {
        case 1: return bbox.y
        case 2: return bbox.z
        case: return bbox.x
    }
}

aabb_hit :: proc(bbox: ^AABB, r: Ray, ray_t: ^Interval) -> bool {
    ray_origin: Point3 = r.origin
    ray_direction: Vec3 = r.direction

    for axis in 0..<3 {
        ax: Interval = aabb_axis_interval(bbox, axis)
        adinv: f64 = 1.0 / ray_direction[axis]

        t0 := (ax.min - ray_origin[axis]) * adinv
        t1 := (ax.max - ray_origin[axis]) * adinv

        if t0 < t1 {
            if t0 > ray_t.min {
                ray_t.min = t0
            }
            if t1 < ray_t.max {
                ray_t.max = t1
            }
        } else {
            if t1 > ray_t.min {
                ray_t.min = t1
            }
            if t0 < ray_t.max {
                ray_t.max = t0
            }
        }

        if ray_t.max <= ray_t.min {
            return false
        }
    }

    return true
}