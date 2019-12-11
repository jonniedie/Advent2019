## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, Tape
using OffsetArrays: OffsetArray
using UnicodePlots: spy
using Test: @test

# Get Data
data = read_csv("input")



## Functions
# Robot type that stores visited squares
mutable struct Robot
    intcode::Tape
    position    # (x,y)
    heading     # 0=>up, 1=>right, 2=>down, 3=>left
    visited::Dict
end
Robot(data, start=(0,0)) = Robot(Tape(data), start, 0, Dict(start=>0))

scan_color(robot::Robot) =
    haskey(robot.visited, robot.position) ? robot.visited[robot.position] : 0

# Run intcode instructions in robot until halting
function run_intcode!(robot::Robot, color=0)
    # Set initial color
    robot.visited[robot.position] = color

    # Pointer at -2 means program has halted
    while robot.intcode.pointer!=-2
        color = scan_color(robot)
        color, direction = operate!(robot.intcode, color)
        robot.visited[robot.position] = color
        move!(robot, direction)
    end

    return robot
end

function move!(robot::Robot, direction)
    turn!(robot, direction)
    go_forward!(robot)
end

turn!(robot::Robot, direction) =
    setfield!(robot, :heading, (robot.heading + 3 + direction*2) % 4)

function go_forward!(robot::Robot)
    move = rem(robot.heading, 2)==0 ? (0,1) : (1,0)
    move = move .* (robot.heading<2 ? 1 : -1)
    robot.position  = robot.position .+ move
end

# Show the grid painted by the robot
function paint(points::Dict, sz=(-100, 100, -50, 50))
    minx, maxx, miny, maxy = sz
    xs, ys = minx:maxx, miny:maxy
    canvas = OffsetArray(zeros(Int, maxx-minx+1, maxy-miny+1), xs, ys)
    for x in xs
        for y in ys
            if haskey(points, (x,y))
                canvas[x,y] = points[(x,y)]
            end
        end
    end
    reverse(permutedims(collect(canvas), [2,1]), dims=1) |> spy
end
paint(robot::Robot, args...) = paint(robot.visited, args...)



## Part 1
# Answer getter
get_answer(data) = Robot(data) |> get_answer
get_answer(robot::Robot) = run_intcode!(robot).visited |> length

# Get answer
robot = Robot(data)
answer1 = get_answer(robot)



## Part 2
# Answer getter
function get_answer(robot::Robot)
    run_intcode!(robot, 1)
    return paint(robot, (-10, 50, -10, 5))
end

robot = Robot(data)
answer2 = get_answer(robot)
