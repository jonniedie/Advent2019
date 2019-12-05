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

export read_csv

function read_csv(f_name)
    f = open(f_name)
    data = readdlm(f, ',', Int)
    close(f)
    return data
end

end #InputRead



## Intcode machine
module Intcode
using ..ZeroBased

export operate!

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
    if mode_type==0
        return intcode[value]
    elseif mode_type==1
        return value
    else error("Invalid mode type $mode_type")
    end
end

# Run intcode machine
function operate!(intcode::OffsetArray, input, i=0)
    len = length(intcode)
    count = 0
    while count<10000
        head = Instruction(intcode[i])
        op = head.opcode

        if op != 3 && op != 99
            val1 = get_value(intcode, head.p1, intcode[i+1])
        end
        if op in 1:2 || op in 5:8
            val2 = get_value(intcode, head.p2, intcode[i+2])
        end
        if op in 1:2 || op in 7:8
            store_address = intcode[i+3]
        elseif op==3
            store_address = intcode[i+1]
        end

        if op == 1
            intcode[store_address] = val1 + val2
            i += 4
        elseif op == 2
            intcode[store_address] = val1 * val2
            i += 4
        elseif op == 3
            intcode[store_address] = input
            i += 2
        elseif op == 4
            return (val1, i+2)
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
        elseif op == 99
            return intcode
        else error("Invalid operation type $head")
        end

        count +=1
    end
    error("Infinite loop! $(intcode[i:i+4]) $(intcode[0])")
end
operate!(intcode, input=1, i=0) = operate!(zero_based(intcode), input, i)

end #Intcode
