## Read in data
f = open("Day1Input")
lines = parse.(Int64, readlines(f))
close(f)

## Part 1
# Get fuel from mass
fuel(mass) = floor(mass/3)-2

# Test fuel function
using Test
@test fuel(12)==2
@test fuel(14)==2
@test fuel(1969)==654
@test fuel(100756)==33583

# Solve Puzzle
answer1 = sum(fuel.(lines))


## Part 2
# Get fuel from mass... but really this time
function fuel2(mass, accum_mass)
    mass = fuel(mass)
    if mass ≤ 0
        return (mass, accum_mass)
    else
        return fuel2(mass, accum_mass + mass)
    end
end
fuel2(mass) = fuel2(mass,0)[2]

# Test fuel2 function
@test fuel2(14)==2
@test fuel2(1969)==966
@test fuel2(100756)==50346

# Solve Puzzle
answer2 = sum(fuel2.(lines))
