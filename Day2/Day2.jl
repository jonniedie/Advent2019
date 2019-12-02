## Read in data
using DelimitedFiles
f = open("Day2Input")
data = readdlm(f, ',', Int)
close(f)

# Zero-based-index arrays
using OffsetArrays
zero_based(array) = OffsetArray([array...], 0:length(array)-1)


## Part 1
# Copy data and change entries 1 and 2
data1 = zero_based(data)
data1[1] = 12
data1[2] = 2

# Functions
function operate!(array::OffsetArray, index)
    head = array[index]
    if head==1
        fun = (+)
    elseif head==2
        fun = (*)
    elseif head==99
        return array
    else error("Invalid operation type $head")
    end

    array[array[index+3]] = fun(array[array[index+1]], array[array[index+2]])
    operate!(array, index+4)
end
operate!(array::OffsetArray) = operate!(array, 0)
operate!(array) = [operate!(zero_based(array))...]

get_answer1(array::OffsetArray) = operate!(array)[0]

# Test operate!
using Test
@test operate!([1,0,0,0,99])==[2,0,0,0,99]
@test operate!([2,3,0,3,99])==[2,3,0,6,99]
@test operate!([2,4,4,5,99,0])==[2,4,4,5,99,9801]
@test operate!([1,1,1,4,99,5,6,0,99])==[30,1,1,4,2,5,6,0,99]
@test operate!([1,9,10,3,2,3,11,0,99,30,40,50])==[3500,9,10,70,2,3,11,0,99,30,40,50]

# Solve puzzle
answer1 = get_answer1(data1)



## Part 2
function get_answer2(array)
    d = copy(array)
    for noun in 0:99
        for verb in 0:99
            d .= array
            d[1] = noun
            d[2] = verb
            if operate!(d)[0] == 19690720
                return (100*noun + verb)
            end
        end
    end
end

data2 = zero_based(data)
answer2 = get_answer2(data2)
