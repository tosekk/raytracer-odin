package raytracer


HittableList :: struct {
    objects: [dynamic]^Hittable,
    bbox: ^AABB,
}


hittable_list_clear :: proc(hl: ^HittableList) {
    clear_dynamic_array(&hl.objects)
}

hittable_list_add :: proc(hl: ^HittableList, object: ^Hittable) {
    append(&hl.objects, object)

    switch obj in object.type {
        case ^Sphere:
            hl.bbox = new_aabb(hl.bbox, obj.bbox)
    }
}