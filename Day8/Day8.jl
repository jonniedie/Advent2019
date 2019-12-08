## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_simple



## Data processing functions
# Convert long string of numbers to array of integers
to_int(long_str) = parse.(Int8, split(long_str..., ""))


# Turn 3-dimensional array into array of 2-dimensional arrays
slice_images(images) = [images[:,:,i] for i in 1:size(images,3)]

# Process input data into images
make_images(data, w, h) = to_int(data) |>
                          (x->reshape(x, w, h, :)) |>
                          (x->permutedims(x, [2,1,3])) |>
                          slice_images



## Get and process data
data = make_images(read_simple("input"), 25, 6)



## Part 1
# Count occurences of a number in a matrix
count_num(image, num) = count(x -> x == num, image)

# Get count of non-zero entries and score for part 1
function score_image(image)
    count1 = count_num(image, 1)
    count2 = count_num(image, 2)
    return (count1 + count2, count1 * count2)
end

# Answer getter
function get_answer(images)
    last_count, out = 0, 0
    for image in images
        count, score = score_image(image)
        if count > last_count
            last_count, out = count, score
        end
    end
    return out
end

# Get answer
answer1 = get_answer(images)
println("Part 1 answer: ", answer1)



## Part 2
# Stack images with opaque pixels showing through transparent
smash_pixels(top, bottom) = top==2 ? bottom : top
smash_pixels(top::Array, bottom::Array) = smash_pixels.(top, bottom)

# Answer getter
get_answer(images) = reduce(smash_pixels, images)

# Get answer
answer2 = get_answer(images)
println("Part 2 answer: \n", answer2)
