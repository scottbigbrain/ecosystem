"""Vector geometry."""

mutable struct Vector
    x::Real
    y::Real
end

Vector() = Vector(0.0, 0.0)

import Base.+, Base.-, Base.*, Base./, Base.==
add(a::Vector, b::Vector) = Vector(a.x + b.x, a.y + b.y)
sub(a::Vector, b::Vector) = Vector(a.x - b.x, a.y - b.y)
mult(a::Vector, scalar) = Vector(a.x * scalar, a.y * scalar)
div(a::Vector, scalar) = Vector(a.x / scalar, a.y / scalar)
neg(v::Vector) = mult(v, -1)
(+)(a::Vector, b::Vector) = add(a, b)
(-)(a::Vector, b::Vector) = sub(a, b)
(*)(a::Vector, scalar) = mult(a, scalar)
(/)(a::Vector, scalar) = div(a, scalar)
(-)(v::Vector) = neg(v)
function (==)(a::Vector, b::Vector)
    a.x == b.x && a.y == b.y && return true
    return false
end

function add!(a::Vector, b::Vector)
    a.x += b.x
    a.y += b.y
    return a
end

function sub!(a::Vector, b::Vector)
    a.x -= b.x
    a.y -= b.y
    return a
end

function mult!(v::Vector, scalar)
    v.x *= scalar
    v.y *= scalar
    return v
end

function div!(v::Vector, scalar)
    v.x /= scalar
    v.y /= scalar
    return v
end

magnitude(v::Vector) = sqrt(v.x * v.x + v.y * v.y)
angle(v::Vector) = atan(v.y / v.x)

angle_between(a::Vector, b::Vector) = acos( (dot(a,b)) / (magnitude(a)*magnitude(b)) )

function normalize!(v::Vector)
    m = magnitude(v)
    if m == 0
        v.x = 0.0
        v.y = 0.0
    else
        v.x /= m
        v.y /= m
    end
    return v
end

function set_magnitude(v::Vector, scalar)
    v = mult!(normalize!(v), scalar)
    return v
end

function limit(v::Vector, scalar)
    if (magnitude(v) > scalar)
        v = set_magnitude(v, scalar)
    end
    return v
end

dot(a::Vector, b::Vector) = a.x * b.x + a.y * b.y
det(a::Vector, b::Vector) = a.x * b.y - a.y * b.x
cross(v::Vector) = Vector(-v.x, v.y)

dist_along(a::Vector, b::Vector) = magnitude(b) * cos(angle_between(a, b))

function rotate!(v::Vector, angle, point)
    angle == 0. && return
    dx = v.x - point.x
    dy = v.y - point.y
    v.x = point.x + (dx * cos(angle) - dy * sin(angle))
    v.y = point.y + (dx * sin(angle) + dy * cos(angle))
    return v
end

rotate!(v::Vector, angle) = rotate!(v, angle, Vector(0., 0.))

import Base.isapprox
function isapprox(a::Vector, b::Vector; atol = 1e-16)
    isapprox(a.x, b.x; atol = atol) && isapprox(a.y, b.y; atol = atol) && return true
    return false
end


average(a::Array{Vector}) = sum(a) / length(a)

dist(a::Vector, b::Vector) = magnitude(a - b)

function closest(a::Array{Vector}, v::Vector)
    best = a[1]
    best_i = 1
    best_dist = Inf
    for i in 1:length(a)
        if (dist(a[i], v) < best_dist)
            best = a[i]
            best_i = i
            best_dist = dist(a[i], v)
        end
    end
    return [best, best_i]
end
