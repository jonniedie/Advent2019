## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, Tape
using OffsetArrays: OffsetArray
using Test: @test

# Get Data
data = read_csv("input")



## Functions
# Robot type that stores visited squares
mutable struct Robot
    intcode::Tape
    pointer
    position    # (x,y)
    heading     # 0=>up, 1=>right, 2=>down, 3=>left
    visited::Dict
end
Robot(data, start=(0,0)) = Robot(Tape(data), 0, start, 0, Dict(start=>0))

function run_intcode!(robot::Robot, color=0)
    (color, direction), robot.pointer  = operate!(robot.intcode, color, i=robot.pointer)
    robot.visited[robot.position] = color
    move!(robot, direction)
    while robot.intcode[robot.pointer] != 99 && robot.pointer>0
        color = haskey(robot.visited, robot.position) ? robot.visited[robot.position] : 0
        (color, direction), robot.pointer  = operate!(robot.intcode, color, i=robot.pointer)
        robot.visited[robot.position] = color
        move!(robot, direction)
    end
end

function move!(robot::Robot, direction)
    turn!(robot, direction)
    go_forward!(robot)
end

function turn!(robot::Robot, direction)
    robot.heading = direction==0 ? (robot.heading+3)%4 : (robot.heading+5)%4
end

function go_forward!(robot::Robot)
    move = rem(robot.heading, 2)==0 ? (0,1) : (1,0)
    move = move .* (robot.heading<2 ? 1 : -1)
    robot.position  = robot.position .+ move
end



## Part 1
# Answer getter
get_answer(data) = Robot(data) |> get_answer
function get_answer(robot::Robot)
    run_intcode!(robot)
    return length(robot.visited)
end

# Get answer
robot = Robot(data)
answer1 = get_answer(robot)



## Part 2
function paint(robot::Robot, sz=(-100, 100, -50, 50))
    minx, maxx, miny, maxy = sz
    xs, ys = minx:maxx, miny:maxy
    canvas = OffsetArray(repeat(['░'], maxx-minx+1, maxy-miny+1), xs, ys)
    for x in xs
        for y in ys
            if haskey(robot.visited, (x,y))
                canvas[x,y] = robot.visited[(x,y)]==1 ? '█' : '░'
            end
        end
    end
    return reverse(permutedims(collect(canvas), [2,1]), dims=1)
end

# Answer getter
function get_answer(robot::Robot)
    run_intcode!(robot, 1)
    return paint(robot, (-10, 50, -10, 5))
end

robot = Robot(data)
answer2 = get_answer(robot)
