## Zero-based indexing
module ZeroBased

using OffsetArrays: OffsetArray

export zero_based, OffsetArray

# Zero-based-index arrays
zero_based(array) = OffsetArray([array...], 0:length(array)-1)

end #ZeroBased



## Input reading
module InputRead

using DelimitedFiles: readdlm

export read_csv, read_simple

# Comma-separated text file read
function read_csv(f_name)
    f = open(f_name)
    data = readdlm(f, ',', Int)
    close(f)
    return data
end

# Simple data reading function
function read_simple(f)
    f = open(f)
    data = readlines(f)
    close(f)
    return data
end

end #InputRead



## Intcode machine
module Intcode
using ..ZeroBased

export operate!, Tape

# Intcode tape. Stores initial intcode directly in an array
#   and uses a dict to add addresses that are out of memory
mutable struct Tape
    rel_base
    init_mem::OffsetArray
    mem_size
    extra_mem::Dict
end
Tape(data) = Tape(0, zero_based(data), length(data), Dict())

function Base.getindex(intcode::Tape, i::Int)
    if i == -1
        return intcode.rel_base
    elseif 0 ≤ i < intcode.mem_size
        return intcode.init_mem[i]
    elseif haskey(intcode.extra_mem, i)
        return intcode.extra_mem[i]
    else
        return 0
    end
end
Base.getindex(intcode::Tape, i::UnitRange) = getindex.(intcode, i)

function Base.setindex!(intcode::Tape, v, i::Int)
    if i == -1
        intcode.rel_base = v
    elseif 0 ≤ i < intcode.mem_size
        intcode.init_mem[i] = v
    else
        intcode.extra_mem[i] = v
    end
    return nothing
end

# Parsed instructions for each operation
struct Instruction
    opcode
    p1
    p2
    p3
end
function Instruction(code::Integer)
    d = digits(code, pad=5)
    return Instruction(d[1] + 10*d[2], d[3:5]...)
end

function get_value(intcode, mode_type, value)
    # Position mode
    if mode_type==0
        return intcode[value]

    # Value mode
    elseif mode_type==1
        return value

    # Relative position mode
    elseif mode_type==2
        return intcode[intcode.rel_base + value]

    else error("Invalid value mode type $mode_type")
    end
end

function get_address(intcode, mode_type, address)
    # Not sure why these are both position mode
    if mode_type==0 || mode_type==1
        return address

    # Relative position mode
    elseif mode_type==2
        return intcode.rel_base + address

    else error("Invalid address mode type $mode_type")
    end
end

# Run intcode machine
function operate!(intcode::Union{OffsetArray, Tape}, inputs...; i=0)

    inp_counter = 1
    count = 0
    output = []

    while true #count<100000
        # Get instructions
        head = Instruction(intcode[i])
        op = head.opcode

        # Operation setup
        if op != 3 && op != 99
            val1 = get_value(intcode, head.p1, intcode[i+1])
        end

        if op in 1:2 || op in 5:8
            val2 = get_value(intcode, head.p2, intcode[i+2])
        end

        if op in 1:2 || op in 7:8
            store_address = get_address(intcode, head.p3, intcode[i+3])

        elseif op==3
            store_address = get_address(intcode, head.p1, intcode[i+1])
        end

        # Operations
        if op == 1
            intcode[store_address] = val1 + val2
            i += 4

        elseif op == 2
            intcode[store_address] = val1 * val2
            i += 4

        elseif op == 3
            if inp_counter > length(inputs)
                return (output, i)
            end
            intcode[store_address] = inputs[inp_counter]
            inp_counter += 1
            i += 2

        elseif op == 4
            push!(output, val1)
            i += 2

        elseif op == 5
            i = val1==0 ? i+3 : val2

        elseif op == 6
            i = val1==0 ? val2 : i+3

        elseif op == 7
            intcode[store_address] = val1 < val2
            i += 4

        elseif op == 8
            intcode[store_address] = val1 == val2
            i += 4

        elseif op==9
            intcode.rel_base += val1
            i += 2

        elseif op == 99
            return (output, -2)

        else error("Invalid operation type $head")
        end

        count +=1
    end
    error("Infinite loop! $(intcode[i]) $(intcode[0])")
end
operate!(intcode, input=1, i=0) = operate!(zero_based(intcode), input, i)

end #Intcode
