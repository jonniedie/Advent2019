## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_big, int2vector, vector2int
using Test: @test
using Base.Threads: @threads
import Base: *, ^


## Structs and functions
# Stripey FFT matrix
struct StripeyBoi
end

# StripeyBoi to an integer power
struct PowerBoi
    power::Integer
end

# Raising a stripey boi to an integer power makes a power boi
(^)(mat::StripeyBoi, int::Integer) = PowerBoi(int)

# Multiplication by a vector handles getting absolute value of ones place
function (*)(mat::StripeyBoi, vect)
    filt!(y) = filter!(x-> 0<x≤len, y)
    len = length(vect)
    cumuvec = cumsum(vect)
    temp = zero(vect)
    @threads for i in eachindex(vect)
        if i==1
            temp[i] = sum(vect[1:4:len]) - sum(vect[3:4:len])
        else
            posidx = collect((3i-1):(4i):len-1)
            negidx = collect((i-1):(4i):len-1)
            posidx1 = negidx .+ i
            negidx1 = posidx .+ i
            endcheck = mod(div(len, i), 4) + 1
            if endcheck==2
                posidx1[end] = len
            elseif endcheck==4
                negidx1[end] = len
            end
            posidx = vcat(posidx, posidx1)
            negidx = vcat(negidx, negidx1)
            posidx = filt!(posidx)
            negidx = filt!(negidx)
            temp[i] = sum(cumuvec[posidx]) - sum(cumuvec[negidx])
        end
    end
    return abs.(temp) .% 10
end
function (*)(p::PowerBoi, vect)
    temp = zero(vect)
    last_temp = copy(vect)
    mat = StripeyBoi()
    for i in 1:p.power
        temp .= mat*last_temp
        last_temp .= temp
        println("Iteration $i complete")
    end
    return temp
end



## Setup
# Create stripey boi
mat = StripeyBoi()

# Test
test_vect = collect(1:8)
test_vect1 = read_big("test_input1") |> int2vector
@test mat*test_vect == [4,8,2,2,6,1,5,8]
@test (mat^4)*test_vect == [0,1,0,2,9,4,9,8]
@test ((mat^100)*test_vect1)[1:8] == [2,4,1,7,6,1,7,6]



## Part 1
vect = read_big("input") |> int2vector
answer1 = (mat^100 * vect)[1:8] |> vector2int
println("Part 1 answer: ", answer1)


## Part 2
vect = repeat(vect, 10_000)
ans_vect = (mat^100 * vect)
offset = vect[1:7] |> vector2int
answer2 = ans_vect[offset+1:offset+8] |> vector2int
println("Part 2 answer: ", answer2)
