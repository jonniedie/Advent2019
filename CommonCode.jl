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
    init_mem
    memory::OffsetArray
    mem_size
    extra_mem::Dict
    pointer
end
Tape(data) = Tape(0, zero_based(data), zero_based(data), length(data), Dict(), 0)


# Get value at position of intcode
function Base.getindex(intcode::Tape, i::Int)

    # If index is in memory, get value from there
    if 0 ≤ i < intcode.mem_size
        return intcode.memory[i]

    # If index is in extra memory, get value from there
    elseif haskey(intcode.extra_mem, i)
        return intcode.extra_mem[i]

    # Tape is zero everywhere else
    else
        return 0
    end
end

Base.getindex(intcode::Tape, i::UnitRange) = getindex.(intcode, i)


# Set value at position of intcode
function Base.setindex!(intcode::Tape, val, i::Int)

    # If index is in memory, set value there
    if 0 ≤ i < intcode.mem_size
        intcode.memory[i] = val

    # if index is outside of memory, set value in extra memory
    else
        intcode.extra_mem[i] = val
    end
    return nothing
end

# Reset intcode machine
function reset!(intcode::Tape)
    intcode.rel_base = 0
    intcode.memory .= intcode.init_mem
    intcode.extra_mem = Dict()
    intcode.pointer = 0
end

# Parsed instructions for each operation
struct Instruction
    opcode
    p
end

function Instruction(code::Integer)
    d = digits(code, pad=5)
    return Instruction(d[1] + 10*d[2], d[3:5])
end


# Get value based on position/value mode type
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


# Get either absolute or relative address
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
function operate!(intcode::Tape, inputs...)

    inp_counter = 1
    output = []

    while true
        # Get instructions
        head = Instruction(intcode[intcode.pointer])
        op = head.opcode

        # Get values
        val1, val2 = map(i -> get_value(intcode, head.p[i], intcode[intcode.pointer+i]), 1:2)

        # Get store address
        add_idx = (op in 1:2 || op in 7:8) ? 3 : 1
        store_address = get_address(intcode, head.p[add_idx], intcode[intcode.pointer+add_idx])

        # Operations
        if op == 1
            intcode[store_address] = val1 + val2
            intcode.pointer += 4

        elseif op == 2
            intcode[store_address] = val1 * val2
            intcode.pointer += 4

        elseif op == 3
            if inp_counter > length(inputs)
                return output
            end
            intcode[store_address] = inputs[inp_counter]
            inp_counter += 1
            intcode.pointer += 2

        elseif op == 4
            push!(output, val1)
            intcode.pointer += 2

        elseif op == 5
            intcode.pointer = val1==0 ? intcode.pointer+3 : val2

        elseif op == 6
            intcode.pointer = val1==0 ? val2 : intcode.pointer+3

        elseif op == 7
            intcode[store_address] = val1 < val2
            intcode.pointer += 4

        elseif op == 8
            intcode[store_address] = val1 == val2
            intcode.pointer += 4

        elseif op==9
            intcode.rel_base += val1
            intcode.pointer += 2

        elseif op == 99
            intcode.pointer = -2
            return output

        else error("Invalid operation type $head")
        end
    end
end
operate!(intcode, input=1) = operate!(zero_based(intcode), input)

end #Intcode
