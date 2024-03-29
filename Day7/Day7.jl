## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, Tape
using Test: @test
using Combinatorics: permutations

repeat_amps(amp) = [Tape(copy(amp)) for i in 1:5]

# Get data
data = read_csv("input")
amplifiers = repeat_amps(data)



## Functions
# Answer getter
function get_answer(amps::Array, phases)
    seqs = permutations(phases) |> collect
    outputs = zeros(Int64, length(seqs))
    for (i, seq) in enumerate(seqs)
        outputs[i] = amplify!(deepcopy(amps), seq)
    end
    return max(outputs...)
end



## Part 1
# Open-loop amplification
function amplify!(amps, seq::Array)
    input = 0
    for (amp, phase) in zip(amps, seq)
        input = operate!(amp, phase, input)
        input = input[end]
    end
    return input
end

# Test
@test amplify!(repeat_amps([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]), [4,3,2,1,0])==43210

# Get answer
answer1 = get_answer(amplifiers, 0:4)
println("Part 1 answer:  ", answer1)



## Part 2
# Closed-loop amplification
function amplify!(amps, seq::Array)
    input = 0
    last_answer = nothing
    for idx in eachindex(amps)
        input = operate!(amps[idx], seq[idx], input)
        input = input[end]
    end
    while amps[end].pointer != -2
        for idx in eachindex(amps)
            input = operate!(amps[idx], input)
            input = input[end]
        end
    end
    return input
end

# Test
@test amplify!(repeat_amps([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]), [9,8,7,6,5])==139629729

# Get answer
answer2 = get_answer(amplifiers, 5:9)
println("Part 2 answer:  ", answer2)
