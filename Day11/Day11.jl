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



# Robot type that stores visited squares
mutable struct Robot
    intcode::Tape
    position    # (x,y)
    heading     # 0=>up, 1=>right, 2=>down, 3=>left
    visited::Dict
end
Robot(data, start=(0,0)) = Robot(Tape(data), start, 0, Dict(start=>0))



## Functions
# Run intcode instructions in robot until halting
function paint!(robot::Robot, color=0)
    # Set initial color
    robot.visited[robot.position] = color

    # Pointer at -2 means program has halted
    while robot.intcode.pointer != -2
        color = scan_color(robot)
        color, direction = operate!(robot.intcode, color)
        robot.visited[robot.position] = color
        move!(robot, direction)
    end

    return robot.visited
end

scan_color(robot::Robot) = haskey(robot.visited, robot.position) ?
                           robot.visited[robot.position] :
                           0


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
function show_grid(points::Dict, sz=(-10, 50, -10, 5))
    minx, maxx, miny, maxy = sz
    canvas = OffsetArray(zeros(Int, maxx-minx+1, maxy-miny+1), minx:maxx, miny:maxy)
    for ((x,y), color) in points
        if (minx ≤ x ≤ maxx) && (miny ≤ y ≤ maxy)
            canvas[x,y] = color
        end
    end
    reverse(permutedims(collect(canvas), [2,1]), dims=1) |> spy
end
show_grid(robot::Robot, args...) = show_grid(robot.visited, args...)



## Part 1
# Answer getter
get_answer(data) = Robot(data) |> get_answer
get_answer(robot::Robot) = paint!(robot) |> length

# Get answer
robot = Robot(data)
answer1 = get_answer(robot)



## Part 2
# Answer getter
get_answer(robot::Robot) = paint!(robot, 1) |> show_grid

robot = Robot(data)
answer2 = get_answer(robot)
