## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, Tape
using Test: @test

# Get Data
data = read_csv("input")



## Functions
# Robot type that stores visited squares
mutable struct Robot
    intcode::Tape
    pointer
    position
    heading # 0=>up, 1=>right, 2=>down, 3=>left
    visited::Dict
end
Robot(data, start=(0,0)) = Robot(Tape(data, 0, start, 0, Dict(start=>0)))

function move!(robot::Robot)
    out, robot.pointer  = operate!(robot.intcode, robot.visited)
    robot.visited[robot.position] = out[1]
    robot.position = out[2]
    robot.heading = out[2]==0 ? 
end
