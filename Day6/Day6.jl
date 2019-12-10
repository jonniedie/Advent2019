## Setup
# Import stuff
include("../CommonCode.jl")
using DelimitedFiles: readdlm
using .InputRead: read_simple
using Test: @test
import Base: +, -


# Get data
data = read_simple("input")
test_data1 = read_simple("test_input")
test_data2 = read_simple("test_input2")


## Functions
# Prepare data for combining
prepare(data) = split.(data, ")") .|>
                reverse |>
                (x -> sort(x, by=x->(x[1], x[2])))

# Combine multiple parent orbit definitions and make dict
function combine_parents(data::Vector{<:Array{<:AbstractString}})
    last_body = data[1][1]
    dict = Dict(data[1][1] => [data[1][2]])
    for i in 2:length(data)
        elem = data[i]
        if elem[1] == last_body
            push!(dict[last_body], elem[2])
        else
            dict[elem[1]] = [elem[2]]
        end
        last_body = elem[1]
    end
    return dict
end
combine_parents(data) = prepare(data) |> combine_parents

# Transfer path and its length
struct Transfers <: Number
    path
    count
end

# Addition of two transfers adds their paths together
+(t1::Transfers, t2::Transfers) = Transfers(vcat(t1.path, t2.path), t1.count+t2.count)

# Subtraction of two transfers finds the shortest path between them
function -(t1::Transfers, t2::Transfers)
    path = vcat(t1.path, t2.path) |> symdiff
    return Transfers(path, length(path))
end

# Compute transfer from body to COM
function to_COM(dict::Dict, key, path=[], count=0)
    if haskey(dict, key)
        return sum([to_COM(dict, k, push!(path,k), count+1) for k in dict[key]])
    else
        return Transfers(path, count)
    end
end
to_COM(data, key) = to_COM(combine_parents(data), key)



## Part 1
# Answer getter
get_answer(dict::Dict) = sum([to_COM(dict, d.first) for d in dict]).count
get_answer(data) = combine_parents(data) |> get_answer

# Test
@test get_answer(test_data1) == 42

# Get answer
answer1 = get_answer(data)
println("Part 1 answer:  ", answer1)



## Part 2
# Answer getter
function get_answer(dict::Dict)
    transfer = to_COM(dict, "YOU") - to_COM(dict, "SAN")
    return transfer.count
end

# Test
@test get_answer(test_data2) == 4

# Get answer
answer2 = get_answer(data)
println("Part 2 answer:  ", answer2)
