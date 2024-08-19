package raytracer


interval :: struct {
    min: f64,
    max: f64,
}

interval_size :: proc(i: interval) -> f64 {
    return i.max - i.min
}

interval_contains :: proc(i: interval, x: f64) -> bool {
    return i.min <= x && x <= i.max
}

interval_surrounds :: proc(i: interval, x: f64) -> bool {
    return i.min < x && x < i.max
}

empty : interval = { INFINITY, NEGATIVE_INFINITY }
universe : interval = { NEGATIVE_INFINITY, INFINITY }