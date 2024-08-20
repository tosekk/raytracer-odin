package raytracer


Interval :: struct {
    min: f64,
    max: f64,
}

interval_size :: proc(i: Interval) -> f64 {
    return i.max - i.min
}

interval_contains :: proc(i: Interval, x: f64) -> bool {
    return i.min <= x && x <= i.max
}

interval_surrounds :: proc(i: Interval, x: f64) -> bool {
    return i.min < x && x < i.max
}

interval_clamp :: proc(i: Interval, x: f64) -> f64 {
    if (x < i.min) {
        return i.min
    }
    if (x > i.max) {
        return i.max
    } 
    return x
}

empty : Interval = { INFINITY, NEGATIVE_INFINITY }
universe : Interval = { NEGATIVE_INFINITY, INFINITY }