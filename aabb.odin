package raytracer

import "core:fmt"


AABB :: struct {
    x, y, z: Interval,
}

new_aabb :: proc { new_aabb_empty, new_aabb_interval, new_aabb_points, new_aabb_bboxes }
new_aabb_empty :: proc() -> (bbox: ^AABB) {
    bbox = new(AABB)
    return
}

new_aabb_interval :: proc(x, y, z: Interval) -> (bbox: ^AABB) {
    bbox = new_aabb_empty()
    bbox.x = x
    bbox.y = y
    bbox.z = z

    aabb_pad_to_minimums(bbox)

    return
}

new_aabb_points :: proc(a, b: Point3) -> (bbox: ^AABB) {
    bbox = new(AABB)
    bbox.x = (a.x <= b.x) ? Interval{ a.x, b.x } : Interval{ b.x, a.x }
    bbox.y = (a.y <= b.y) ? Interval{ a.y, b.y } : Interval{ b.y, a.y }
    bbox.z = (a.z <= b.z) ? Interval{ a.z, b.z } : Interval{ b.z, a.z }

    aabb_pad_to_minimums(bbox)

    return
}

new_aabb_bboxes :: proc(box0, box1: ^AABB) -> (bbox: ^AABB) {
    bbox = new(AABB)
    bbox.x = new_interval(box0.x, box1.x)
    bbox.y = new_interval(box0.y, box1.y)
    bbox.z = new_interval(box0.z, box1.z)

    return
}

aabb_axis_interval :: proc(bbox: ^AABB, n: int) -> Interval {
    switch n {
        case 1: return bbox.y
        case 2: return bbox.z
        case: return bbox.x
    }

}

aabb_longest_axis :: proc(bbox: ^AABB) -> int {
    if interval_size(bbox.x) > interval_size(bbox.y) {
        return interval_size(bbox.x) > interval_size(bbox.z) ? 0 : 2
    } else {
        return interval_size(bbox.y) > interval_size(bbox.z) ? 1 : 2
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

@(private)
aabb_pad_to_minimums :: proc(bbox: ^AABB) {
	delta: f64 = 0.0001

	if interval_size(bbox.x) < delta {
		bbox.x = interval_expand(bbox.x, delta)
	}
	if interval_size(bbox.y) < delta {
		bbox.y = interval_expand(bbox.y, delta)
	}
	if interval_size(bbox.z) < delta {
		bbox.z = interval_expand(bbox.z, delta)
	}
}

aabb_empty : AABB = { interval_empty, interval_empty, interval_empty }
aabb_universe : AABB = { interval_universe, interval_universe, interval_universe }
