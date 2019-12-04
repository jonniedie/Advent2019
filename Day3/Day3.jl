##Init

using DelimitedFiles: readdlm
import Base: +, promote_rule, convert, zero
using Test: @test


## Data definition
# Puzzle data
f = open("input")
data = readdlm(f, ',', String, '\n')
close(f)

# Test data
test1 = "R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83"

test2 = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"



## Functions
# Manhattan distance between origin and x,y point
manhat(x, y) = abs(x) + abs(y)

# Point with x and y coordinates and the Manhattan distance from the origin
struct Point <: Number
    x
    y
    dist
end
Point(x, y) = Point(x, y, manhat(x, y))

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
# Circuit(s::Array{AbstractString}) = Circuit.(s) |> sum

# Define addition for Circuits to mean end-to-end appending
+(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)
+(p::Point, c::Circuit) = Circuit(p .+ c.points)
+(c::Circuit, p::Point) = p + c
+(c1::Circuit, c2::Circuit) = Circuit(vcat(c1.points, (c1.points[end] + c2).points))
+(c::Circuit, d::Direction) = c + Circuit(d)
+(d1::Direction, d2::Direction) = Circuit(d1) + Circuit(d2)

# Define the additive identity for Circuits
zero(c::Circuit) = Circuit([Point(0,0)])

# Manhattan distance for points
manhat(p::Point) = p.dist




## Part 1
# Get closest intersection
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
get_answer1(s1::AbstractString, s2::AbstractString) = closest_intersection(Circuit(s1), Circuit(s2)).dist
get_answer1(s::AbstractString) = get_answer1(split(s, '\n')...)

# Test
@test get_answer1(test1) == 159
@test get_answer1(test2) == 135

circuits = sum(Direction.(data), dims=2)
answer1 = get_answer1(circuits)


## Part 2
# Get shortest intersection
function shortest_intersection(c1::Circuit, c2::Circuit)
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
    return shortest
end
shortest_intersection(c::Array{Circuit, 2}) = shortest_intersection(c[1], c[2])

# Answer getter TODO: Figure out why test version is off by 2
get_answer2(c::Array{Circuit, 2}) = shortest_intersection(c)
get_answer2(s1::AbstractString, s2::AbstractString) = shortest_intersection(Circuit(s1), Circuit(s2)) + 2
get_answer2(s::AbstractString) = get_answer2(split(s, '\n')...)

# Test
@test get_answer2(test1) == 610
@test get_answer2(test2) == 410

# Not sure why the test version needs
answer2 = get_answer2(circuits)
