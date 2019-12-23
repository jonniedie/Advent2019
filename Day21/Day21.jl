## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv, read_simple
using .Intcode: operate!, reset!, Tape
using Test: @test



## Read in data and make intcode
data = read_csv("input")
intcode = Tape(data)



# 0 1 2 3 4 5 6 7 8 9
# > A B C D E F G H I


## Functions
# String to character integer array
to_int(str) = [Int(char) for char in str]

# See if springdroid made it past the holes, get
function interpret_ouput(output)
    try
        output = Char.(output) |> join
    catch
        output = output[end]
    end
    return output
end

# Run ascii intcode
ascii_op!(intcode::Tape, input) = operate!(intcode, input...)
ascii_op!(intcode::Tape, input::AbstractString) = ascii_op!(intcode, to_int(input))

# Answer getter
get_answer(intcode, input) = ascii_op!(intcode, input) |> interpret_ouput



## Part 1
# Read in program
program = read("program1", String)

# Get answer
answer1 = get_answer(intcode, program)
println("Part 1 answer: ", answer1)



## Part 2
# Read in program
program = read("program2", String)

# Get answer
reset!(intcode)
answer2 = get_answer(intcode, program)
println("Part 2 answer: ", answer2)
