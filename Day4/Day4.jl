## Setup
using Test: @test

# Puzzle input
input = 235741:706948



## Functions
# Finite difference the digits in the data to see consecutive pairs
convert_data(data) = digits(data) |> diff

# Check if digits are nondecreasing
nondecreasing(diffed) = all(diffed .≤ 0)

# Check if password is valid
valid_password(diffed) = nondecreasing(diffed) && consecutive_pair(diffed)
valid_password(data::Integer) = convert_data(data) |> valid_password

# Answer getter
get_answer(diffed) = filter(valid_password, diffed) |> length



## Part 1
# Check if digits contain consecutive pairs
consecutive_pair(diffed) = any(diffed .== 0)

# Test
@test valid_password(111111)
@test !valid_password(223450)
@test !valid_password(123789)

# Get answer
answer1 = get_answer(input)
println("Part 1 answer:  ", answer1)


## Part 2
# Check if digits contain consecutive pairs that are not part of larger group
function consecutive_pair(diffed)
    padded = vcat([1], diffed, [1])
    for i in 2:length(padded)-1
        if padded[i]==0 && padded[i-1]!=0 && padded[i+1]!=0
            return true
        end
    end
    return false
end

# Test
@test valid_password(112233)
@test !valid_password(123444)
@test valid_password(111122)

# Get answer
answer2 = get_answer(input)
println("Part 2 answer:  ", answer2)
