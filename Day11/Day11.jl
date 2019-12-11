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
    heading
    visited::Dict
end
Robot(data) = Robot(Tape(data, (0,0), 'U', Dict((0,0)=>0)))

function move!(robot::Robot)
    color, robot.pointer  = operate!(robot.intcode, robot.visited)
    robot.visited[robot.position] = color

end
