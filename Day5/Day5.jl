## Setup
# Import stuff
include("../CommonCode.jl")
using .ZeroBased: zero_based, OffsetArray
using .InputRead: read_csv
using .Intcode: operate!
using Test

# Get data
data = read_csv("input")


## Functions
# Answer getter
function get_answer(data::OffsetArray, input=1)
    output = 0
    index = 0
    while output==0
        output, index = operate!(data, input, index)
    end
    return isa(output, Nothing) ? 0 : output
end
get_answer(data, input=1) = get_answer(zero_based(data), input)

# Test functions
test_eq_8_pos(num) = get_answer([3,9,8,9,10,9,4,9,99,-1,8], num)==1
test_lt_8_pos(num) = get_answer([3,9,7,9,10,9,4,9,99,-1,8], num)==1
test_eq_8_imm(num) = get_answer([3,3,1108,-1,8,3,4,3,99], num)==1
test_lt_8_imm(num) = get_answer([3,3,1107,-1,8,3,4,3,99], num)==1


## Part 1
# Get answer
answer1 = get_answer(data)


## Part 2
# Run tests
@test test_eq_8_pos(8)
@test !test_eq_8_pos(7)

@test test_lt_8_pos(7)
@test !test_lt_8_pos(8)
@test !test_lt_8_pos(9)

@test test_eq_8_imm(8)
@test !test_eq_8_imm(7)

@test test_lt_8_imm(7)
@test !test_lt_8_imm(8)
@test !test_lt_8_imm(9)

# Get answer
answer2 = get_answer(data, 5)
