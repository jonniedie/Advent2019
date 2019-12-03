##Init
# Read in data
using DelimitedFiles: readdlm
f = open("input")
data = readdlm(f, ',', String, '\n')
close(f)

import Base: +, promote_rule, convert, zero
using Test: @test


manhat(x, y) = abs(x) + abs(y)

struct Point <: Number
    x
    y
    dist
end
Point(x, y) = Point(x, y, manhat(x, y))

struct Direction
    dir::Char
    len::Int64
end
Direction(s::AbstractString) = Direction(s[1], parse(Int64, s[2:end]))

struct Circuit
    points::Vector{Point}
end
function Circuit(d::Direction)
    if d.dir=='U'
        y = 1:d.len
        x = zero(y)
    elseif d.dir=='D'
        y = -(1:d.len)
        x = zero(y)
    elseif d.dir=='R'
        x = 1:d.len
        y = zero(x)
    elseif d.dir=='L'
        x = -(1:d.len)
        y = zero(x)
    else error("Invalid direction $(d.dir)")
    end
    return Circuit(Point.(x, y))
end
Circuit(s::AbstractString) = split(s, ',') .|> Direction .|> Circuit |> sum
Circuit(s::Array{AbstractString}) = Circuit.(s) |> sum

promote_rule(::Type{Direction}, ::Type{Circuit}) = Circuit
convert(::Type{Circuit}, d::Direction) = Circuit(d)

+(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)
+(p::Point, c::Circuit) = Circuit(p .+ c.points)
+(c::Circuit, p::Point) = p + c
+(c1::Circuit, c2::Circuit) = Circuit(vcat(c1.points, (c1.points[end] + c2).points))
+(c::Circuit, d::Direction) = c + Circuit(d)
+(d1::Direction, d2::Direction) = Circuit(d1) + Circuit(d2)

zero(c::Circuit) = Circuit([Point(0,0)])

# Manhattan distance
manhat(p::Point) = p.dist
manhat(c::Circuit) = manhat.(c.points) |> sum




## Part 1
# Get intersections
function closest_intersection(c1::Circuit, c2::Circuit)
    p1, p2 = (c1,c2) .|> (c -> sort(c.points, by=manhat))
    for point in p1
        if point.dist!=0 && point in p2
            return point
        end
    end
end
closest_intersection(c::Array{Circuit, 2}) = closest_intersection(c[1], c[2])

# Answer getter
get_answer1(c::Array{Circuit, 2}) = closest_intersection(c).dist
get_answer1(s1::String, s2::String) = closest_intersection(Circuit(s1), Circuit(s2)).dist

# Test
@test get_answer1("R75,D30,R83,U83,L12,D49,R71,U7,L72",
                  "U62,R66,U55,R34,D71,R55,D58,R83") == 159
@test get_answer1("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
                  "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7") == 135

circuits = sum(Direction.(data), dims=2)
answer1 = get_answer1(circuits)


## Part 2
function all_intersections(c1::Circuit, c2::Circuit)
    p1, p2 = c1.points, c2.points
    dist_array = []
    for point in p1
        if point.dist!=0 && point in p2
            push!(dist_array, )
        end
    end
end
