## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_simple
using Test: @test
import Base: parse, *, vcat


## Structs
mutable struct Chemical
    coeff
    name
end
Chemical(coeff::AbstractString, name) = Chemical(parse(Int64, coeff), name)

Formula = Tuple{Int64, Array{Chemical}}
Formulas = Dict{String, Formula}



## Functions
# Read input file
read_formulas(file) = read_simple(file) |> x -> parse(Formulas, x)

# Parse text into chemicals and formulas
parse(::Type{Chemical}, s) = Chemical(split(s, ' ')...)
function parse(::Type{Formulas}, str::Array{<:AbstractString})
    formulas = Formulas()
    for s in str
        LHS, RHS = split(s, " => ")
        reagents = split(LHS, ", ") .|>
                   x -> parse(Chemical, x)
        coeff, name = split(RHS, " ")
        formulas[string(name)] = (parse(Int64, coeff), reagents)
    end
    return formulas
end

# Reduce formula by inserting constituent formulas
function reduce!(formulas::Formulas, key="FUEL", surplus=Dict())

    coeff, chemicals = formulas[key]
    chemicals = deepcopy(chemicals)

    while !all_ore(chemicals)
        # Break off first chemical in list of fomula
        chemical = popfirst!(chemicals)
        name, needed = chemical.name, chemical.coeff

        # Check surplus for chemical needed
        if haskey(surplus, name)
            if surplus[name] ≥ needed
                surplus[name] = surplus[name] - needed
                needed = 0
            else
                needed = needed - surplus[name]
                surplus[name] = 0
            end
        end

        # Ore is the base case
        if name=="ORE"
            push!(chemicals, chemical)
            chemicals = combine(chemicals)
            continue
        end

        # Get constituent chemicals and calculate how many batches are needed
        (formula_coeff, chems_to_insert) = formulas[name]
        num_batches, leftover = batches_needed(needed, formula_coeff)

        # Insert new chemicals to end of formula
        chems_to_insert = chems_to_insert .* num_batches
        push!(chemicals, chems_to_insert...)
        chemicals = combine(chemicals)

        # Add leftovers to surplus
        if haskey(surplus, name)
            surplus[name] += leftover
        else
            surplus[name] = leftover
        end
    end
    return chemicals
end

# Get number of batches to make needed amount of chemical
function batches_needed(needed, batch_size)
    if needed==0
        return 0, 0
    end
    num_batches = div(needed, batch_size) + (mod(needed, batch_size)==0 ? 0 : 1)
    leftover = num_batches * batch_size - needed
    return num_batches, leftover
end

# Define multiplication by a scalar for chemicals and formulas
(*)(x::Number, c::Chemical) = Chemical(x * c.coeff, c.name)
(*)(c::Chemical, x::Number) = x * c
(*)(x::Number, f::Formula) = (x * f[1], x .* f[2])
(*)(f::Formula, x::Number) = x * f

# Check if chemicals in a list are all ore (probably not needed because of combine)
all_ore(chemicals::Array{Chemical}) = all(map(x->x.name=="ORE", chemicals))

# Combine like chemicals in a formula
function combine(chemicals::Array{Chemical})
    new_chemicals = empty(chemicals)
    names = map(x->x.name, chemicals) |> unique
    for name in names
        only_this = filter(x-> x.name==name, chemicals)
        coeff = map(x-> x.coeff, only_this) |> sum
        push!(new_chemicals, Chemical(coeff, name))
    end
    return new_chemicals
end



## Part 1
# Answer getter
get_answer1(file) = read_formulas(file) |> get_answer1
get_answer1(formulas::Formulas) = reduce!(formulas)[1].coeff

# Test
@test get_answer1("test_input1")==31

# Get answer
answer1 = get_answer1("input")
println("Part 1 answer: ", answer1)



## Part 2
# b r ̈u t   f o r c e
function get_answer2(file, init_guess)
    formulas = read_formulas(file)
    fuel_formula = deepcopy(formulas["FUEL"])
    fuel = init_guess
    ore = 0
    while ore < 1_000_000_000_000
        fuel += 1
        formulas["FUEL"] = fuel * fuel_formula
        ore = get_answer1(formulas)
    end
    return fuel - 1
end

# Test
@test get_answer2("test_input2", 82892750) == 82892753

# Pretty much manual bisection method to find good starting point
answer2 = get_answer2("input", 1330000)
println("Part 2 answer: ", answer2)
