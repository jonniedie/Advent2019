## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, Tape
using OffsetArrays: OffsetArray
using Test: @test

data = read_csv("input")

function reset!(intcode::Tape)
    intcode.memory = intcode.init_mem
    intcode.pointer = 0
    intcode.rel_base = 0
    intcode.extra_mem = Dict()
    return nothing
end

function run_and_reset!(intcode::Tape, args...)
    output = operate!(intcode, args...)
    reset!(intcode)
    return output[1]
end

function get_grid(data)
    output = OffsetArray(zeros(Int, 50,50), 0:49, 0:49)
    for i in 0:49
        for j in 0:49
            output[i,j] = run_and_reset!(Tape(data), i, j)
        end
    end
    return output
end
