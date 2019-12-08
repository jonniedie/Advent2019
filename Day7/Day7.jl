## Setup
# Import stuff
include("../CommonCode.jl")
using .ZeroBased: zero_based, OffsetArray
using .InputRead: read_csv
using .Intcode: operate!
using Test: @test
using Combinatorics: permutations

repeat_amps(amp) = [zero_based(amp) for i in 1:5]

# Get data
data = read_csv("input")
amplifiers = repeat_amps(data)



## Functions
# Answer getter
function get_answer(amps::Array, phases)
    seqs = permutations(phases) |> collect
    thrust = 0
    for seq in seqs
        thrust = max(thrust, amplify!(copy(amps), seq))
    end
    return thrust
end



## Part 1
# Open-loop amplification
function amplify!(amps, seq::Array)
    input = 0
    for (amp, phase) in zip(amps, seq)
        input = operate!(amp, phase, input)[1]
    end
    return input
end

# Test
@test amplify!(repeat_amps([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]), [4,3,2,1,0])==43210

# Get answer
answer1 = get_answer(amplifiers, 0:4)
println("Part 1 answer:  ", answer1)



#Part 2
# Closed-loop amplification
function amplify!(amps, seq::Array)
    input = 0
    pointers = zeros(Int64, size(amps))
    last_answer = nothing
    for idx in eachindex(amps)
        (input, pointers[idx]) = operate!(amps[idx], seq[idx], input, i=pointers[idx])
    end
    while !isa(input, Nothing)
        last_answer = input
        for idx in eachindex(amps)
            (input, pointers[idx]) = operate!(amps[idx], input, i=pointers[idx])
        end
    end
    return last_answer
end

# Test
@test amplify!(repeat_amps([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]), [9,8,7,6,5])==139629729

# Get answer
answer2 = get_answer(amplifiers, 5:9)
println("Part 2 answer:  ", answer2)
