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
    verbose
end
StripeyBoi(;verbose=false) = StripeyBoi(verbose)

# StripeyBoi to an integer power
struct PowerBoi
    power::Integer
    verbose
end
PowerBoi(power; verbose=false) = PowerBoi(Power, verbose)

# Raising a stripey boi to an integer power makes a power boi
(^)(mat::StripeyBoi, int::Integer) = PowerBoi(int, mat.verbose)


# Multiplication by a vector handles getting absolute value of ones place
function (*)(mat::StripeyBoi, vect)
    # Filter out values that are out of vector index range
    function filt!(x)
        if x[1] < 0
            popfirst!(x)
        end
        if x[end] > len
            pop!(x)
        end
    end

    # Set up
    len = length(vect)
    cumuvec = cumsum(vect)
    temp = zero(vect)

    temp[1] = abs(sum(vect[1:4:len]) - sum(vect[3:4:len])) % 10

    # Multithread the for loop
    @threads for i in 2:len
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

        filt!(posidx)
        filt!(negidx)

        temp[i] = abs(sum(cumuvec[posidx]) - sum(cumuvec[negidx])) % 10
    end
    return temp
end

function (*)(p::PowerBoi, vect)
    temp = copy(vect)
    mat = StripeyBoi()
    for i in 1:p.power
        temp = mat*temp
        p.verbose && println("Iteration $i complete")
    end
    return temp
end



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
mat = StripeyBoi(verbose=true)
vect = repeat(vect, 10_000)
ans_vect = (mat^100 * vect)
offset = vect[1:7] |> vector2int
answer2 = ans_vect[offset+1:offset+8] |> vector2int
println("Part 2 answer: ", answer2)
