package raytracer

import "core:fmt"
import "core:slice"


BVH :: struct {
    using _base: Hittable,
    left, right: ^Hittable,
    bbox: ^AABB,
}


new_bvh_node :: proc { new_bvh_node_hittable_list, new_bvh_node_array }
new_bvh_node_hittable_list :: proc(hittable_list: ^HittableList) -> (bvh: ^BVH) {
    bvh = new(BVH)
    bvh.bbox = &aabb_empty
    bvh = new_bvh_node_array(bvh, hittable_list.objects[:], 0, len(hittable_list.objects))
    bvh.type = bvh

    return
}

new_bvh_node_array :: proc(bvh: ^BVH, objects: []^Hittable, start, end: int) -> ^BVH {
	bvh.bbox = &aabb_empty

    for object_index in start..<end {
        bvh.bbox = new_aabb(bvh.bbox, hittable_bounding_box(objects[object_index]))
    }

    axis: int = aabb_longest_axis(bvh.bbox)

    comparator := (axis == 0) ? bvh_box_x_compare : (axis == 1) ? bvh_box_y_compare : bvh_box_z_compare

    object_span: int = end - start

    if object_span == 1 {
        bvh.left = objects[start]
        bvh.right = objects[start]
    } else if object_span == 2 {
        bvh.left = objects[start]
        bvh.right = objects[start + 1]
    } else {
        slice.sort_by(objects[start: end], comparator)

        mid := start + object_span / 2

        n_bvh := new(BVH)
        n_bvh.type = n_bvh

        bvh.left = new_bvh_node(n_bvh, objects, start, mid)
        bvh.right = new_bvh_node(n_bvh, objects, mid, end)
    }

    return bvh
}

bvh_hit :: proc(bvh: ^BVH, r: Ray, ray_t: ^Interval, rec: ^HitRecord) -> bool {
    if !aabb_hit(bvh.bbox, r, ray_t) {
        return false
    }

    fmt.println("BVH_HIT")
    fmt.println("BVH --- ", bvh)
    fmt.println("Interval --- ", ray_t)
    fmt.println("Record --- ", rec)

	hit_left := hittable_hit(bvh.left, r, ray_t, rec)
	hit_right := hittable_hit(bvh.right, r, &Interval{ ray_t.min, hit_left ? rec.t : ray_t.max }, rec)

    return hit_left || hit_right
}

@(private)
bvh_box_compare :: proc(a, b: ^Hittable, axis_index: int) -> bool {
    a_axis_interval := aabb_axis_interval(hittable_bounding_box(a), axis_index)
    b_axis_interval := aabb_axis_interval(hittable_bounding_box(b), axis_index)
    return a_axis_interval.min < b_axis_interval.min
}

@(private)
bvh_box_x_compare :: proc(a, b: ^Hittable) -> bool {
    return bvh_box_compare(a, b, 0)
}

@(private)
bvh_box_y_compare :: proc(a, b: ^Hittable) -> bool {
    return bvh_box_compare(a, b, 1)
}

@(private)
bvh_box_z_compare :: proc(a, b: ^Hittable) -> bool {
    return bvh_box_compare(a, b, 2)
}
