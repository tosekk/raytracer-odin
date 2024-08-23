package raytracer

import "core:fmt"


HittableList :: struct {
    using _base: Hittable,
    objects: [dynamic]^Hittable,
    bbox: ^AABB,
}

new_hittable_list :: proc { new_hittable_list_empty, new_hittable_list_object }
new_hittable_list_empty :: proc() -> (hl: ^HittableList) {
    hl = new(HittableList)
    return
}

new_hittable_list_object :: proc(object: ^Hittable) -> (hl: ^HittableList) {
    hl = new(HittableList)
    hl.bbox = &aabb_empty
    hittable_list_add(hl, object)
    return
}

hittable_list_clear :: proc(hl: ^HittableList) {
    clear_dynamic_array(&hl.objects)
}

hittable_list_add :: proc(hl: ^HittableList, object: ^Hittable) {
    append(&hl.objects, object)

    #partial switch obj in object.type {
        case ^Sphere:
            hl.bbox = new_aabb(hl.bbox, obj.bbox)
        case ^BVH:
            hl.bbox = new_aabb(hl.bbox, obj.bbox)
    }
}