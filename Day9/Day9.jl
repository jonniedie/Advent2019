## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, Tape
using Test: @test

# Get data
data = read_csv("input")
test1_data = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
test2_data = [1102,34915192,34915192,7,4,7,99,0]
test3_data = [104,1125899906842624,99]


## Part 1
# Answer getter
get_answer(data) = operate!(Tape(data), 1)[1]

@test get_answer(test1_data) == test1_data
@test (get_answer(test2_data)[1] |> digits |> length) == 16
@test get_answer(test3_data)[1] == test3_data[2]

# Get answer
answer1 = get_answer(data)


## Part 2
# Answer getter
get_answer(data) = operate!(Tape(data), 2)[1]

# Get answer
answer2 = get_answer(data)
