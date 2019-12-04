## Setup
using DelimitedFiles: readdlm
import Base: +, zero
using Test: @test

# Puzzle data
f = open("input")
data = readdlm(f, '\n', String)
close(f)

# Test data
test1 = "R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83"

test2 = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"



## Data types
# Point with x and y coordinates and the Manhattan distance from the origin
struct Point <: Number
    x
    y
end

# Parsed circuit direction
struct Direction
    dir::Char
    len::Int64
end
Direction(s::AbstractString) = Direction(s[1], parse(Int64, s[2:end]))

# Circuit through adjacent points
struct Circuit
    points::Vector{Point}
end
function Circuit(d::Direction)
    inc = 1:d.len
    fix = zero(inc)
    if d.dir=='U'
        x = fix
        y = inc
    elseif d.dir=='D'
        x = fix
        y = -inc
    elseif d.dir=='R'
        x = inc
        y = fix
    elseif d.dir=='L'
        x = -inc
        y = fix
    else error("Invalid direction $(d.dir)")
    end
    return Circuit(Point.(x, y))
end
Circuit(s::AbstractString) = split(s, ',') .|> Direction .|> Circuit |> sum



## Functions
# Addition for Circuits means end-to-end appending
+(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)
+(p::Point, c::Circuit) = Circuit(p .+ c.points)
+(c::Circuit, p::Point) = p + c
+(c1::Circuit, c2::Circuit) = Circuit(vcat(c1.points, (c1.points[end] + c2).points))

# Get additive identity for Circuits
zero(c::Circuit) = Circuit([Point(0,0)])

# Manhattan distance for points
manhat(x, y) = abs(x) + abs(y)
manhat(p::Point) = manhat(p.x, p.y)

# Answer getter
get_answer(s1::AbstractString, s2::AbstractString) = closest_intersection(Circuit(s1), Circuit(s2))
get_answer(s::AbstractString) = get_answer(split(s, '\n')...)
get_answer(s::Array{<:AbstractString}) = get_answer(s...)



## Part 1
# Get closest intersection
function closest_intersection(c1::Circuit, c2::Circuit)
    p1, p2 = (c1,c2) .|> (c -> sort(c.points, by=manhat))
    dist = manhat.(p1)
    for (i, point) in enumerate(p1)
        if dist[i]!=0 && point in p2
            return dist[i]
        end
    end
end
closest_intersection(c::Array{Circuit, 2}) = closest_intersection(c[1], c[2])

# Test
@test get_answer(test1) == 159
@test get_answer(test2) == 135

# Get answer
answer1 = get_answer(data)
println("Part 1 answer:  ", answer1)


## Part 2
# Get shortest intersection
function closest_intersection(c1::Circuit, c2::Circuit)
    p1, p2 = c1.points[2:end], c2.points[2:end]

    shortest = 999999999999
    for (dist1, point1) in enumerate(p1)
        for (dist2, point2) in enumerate(p2)
            if point1 == point2
                shortest = min(shortest, dist1 + dist2)
            end
            if dist2 ≥ shortest - dist1
                break
            end
        end
        if dist1 ≥ shortest
            break
        end
    end
    return shortest + 2
end
closest_intersection(c::Array{Circuit, 2}) = closest_intersection(c[1], c[2])

# Test
@test get_answer(test1) == 610
@test get_answer(test2) == 410

# Get answer
answer2 = get_answer(data)
println("Part 2 answer:  ", answer2)
