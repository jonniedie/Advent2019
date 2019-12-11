## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, Tape
using Test

# Get data
data = read_csv("Day2Input")


## Functions
# Get answer for part 1 (also used in part 2)
function get_answer1(intcode::Tape)
    operate!(intcode)
    return intcode[0]
end
get_answer1(array) = Tape(array) |> get_answer1

# Test operate! function
function test_operate!(input, output)
    intcode = Tape(input)
    operate!(intcode)
    return collect(intcode.init_mem) == output
end


## Part 1
# Copy data and change entries 1 and 2
data1 = Tape(data)
data1[1] = 12
data1[2] = 2

# Test operate!
@test test_operate!([1,0,0,0,99], [2,0,0,0,99])
@test test_operate!([2,3,0,3,99], [2,3,0,6,99])
@test test_operate!([2,4,4,5,99,0], [2,4,4,5,99,9801])
@test test_operate!([1,1,1,4,99,5,6,0,99], [30,1,1,4,2,5,6,0,99])
@test test_operate!([1,9,10,3,2,3,11,0,99,30,40,50], [3500,9,10,70,2,3,11,0,99,30,40,50])
@test get_answer1([1,9,10,3,2,3,11,0,99,30,40,50])==3500

# Solve puzzle
answer1 = get_answer1(data1)


## Part 2
function get_answer2(intcode::Tape)
    for noun in 0:99
        for verb in 0:99
            d = deepcopy(intcode)
            d[1] = noun
            d[2] = verb
            if get_answer1(d) == 19690720
                return (100*noun + verb)
            end
        end
    end
end

data2 = Tape(data)
answer2 = get_answer2(data2)
