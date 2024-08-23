package raytracer


Interval :: struct {
    min: f64,
    max: f64,
}

new_interval :: proc(a, b: Interval) -> (interval: ^Interval) {
    interval = new(Interval)
    interval.min = a.min <= b.min ? a.min : b.min
    interval.max = a.max <= b.max ? a.max : b.max
    return
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

interval_expand :: proc(i: Interval, delta: f64) -> Interval {
    padding := delta / 2
    return Interval{ i.min + padding, i.max + padding }
}

empty : Interval = { INFINITY, NEGATIVE_INFINITY }
universe : Interval = { NEGATIVE_INFINITY, INFINITY }