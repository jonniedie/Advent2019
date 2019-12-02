## Read in data
using DelimitedFiles
f = open("Day2Input")
data = readdlm(f, ',', Int)
close(f)


## Part 1
# Use zero-based indexing
using OffsetArrays
data1 = OffsetArray([data...], 0:length(data)-1)

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
operate!(array) = [operate!(OffsetArray([array...], 0:length(array)-1))...]

# Test operate!
using Test
@test operate!([1,0,0,0,99])==[2,0,0,0,99]
@test operate!([2,3,0,3,99])==[2,3,0,6,99]
@test operate!([2,4,4,5,99,0])==[2,4,4,5,99,9801]
@test operate!([1,1,1,4,99,5,6,0,99])==[30,1,1,4,2,5,6,0,99]
@test operate!([1,9,10,3,2,3,11,0,99,30,40,50])==[3500,9,10,70,2,3,11,0,99,30,40,50]

# Solve puzzle
data1[1] = 12
data1[2] = 2
answer1 = operate!(data1)



## Part 2
function tryoperations(data)
    d = copy(data)
    for noun in 0:99
        for verb in 0:99
            d = copy(data)
            d[1] = noun
            d[2] = verb
            if operate!(d)[0] == 19690720
                return (100*noun + verb)
            end
        end
    end
end

data2 = OffsetArray([data...], 0:length(data)-1)
answer2 = tryoperations(data2)
