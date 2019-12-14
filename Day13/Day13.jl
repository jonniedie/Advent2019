## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, reset!, Tape
using OffsetArrays: OffsetArray
using UnicodePlots: spy
using Test: @test

# Get Data
data = read_csv("input")



## Functions
# Get pixels
function get_pixels(int_array)
    num_pixels = div(length(int_array), 3)
    pixels = Dict()
    for i in 0:num_pixels-1
        indices = i*3 .+ (1:3)
        x, y, id = int_array[indices]
        pixels[(x,y)] = id
    end
    return pixels
end

# Show the screen
function show_grid(points::Dict, sz=(0, 50, 0, 30))
    minx, maxx, miny, maxy = sz
    canvas = OffsetArray(zeros(Int, maxx-minx+1, maxy-miny+1), minx:maxx, miny:maxy)
    for ((x,y), color) in points
        if (minx ≤ x ≤ maxx) && (miny ≤ y ≤ maxy)
            canvas[x,y] = color
        end
    end
    reverse(permutedims(collect(canvas), [2,1]), dims=1) |> spy |> show
end



## Part 1
# Count block tiles
count_blocks(pixels::Dict) = count(x->x==2, values(pixels))

# Answer getter
get_answer(data) = Tape(data) |>
                   operate! |>
                   get_pixels |>
                   count_blocks

# Get answer
answer1 = get_answer(data)
println("Part 1 answer: ", answer1)



## Part 2
# Await keypress and manually move slider. Keypress part taken from:
# https://stackoverflow.com/questions/56888266/how-to-read-keyboard-inputs-at-every-keystroke-in-julia/56893331
function move_slider()
    ret = ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid},Int32), stdin.handle, true)
    ret == 0 || error("unable to switch to raw mode")
    c = read(stdin, Char)
    ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid},Int32), stdin.handle, false)
    key = parse(Int, c)
    if key==4
        return -1
    elseif key==6
        return 1
    else
        return 0
    end
end

# Get paddle and ball positions (not really the most efficient way to do this)
function get_positions(pixels::Dict)
    paddle, ball = (0, 0), (0, 0)
    for (pos, id) in pixels
        if id==3
            paddle = pos
        elseif id==4
            ball = pos
        end
    end
    return [paddle, ball]
end
get_positions(int_array) = get_pixels(int_array) |> get_positions

# Play game manually
function play!(intcode::Tape)
    intcode[0] = 2
    output = [0,0,0]
    while output[end-2:end-1] != [-1,0]
        input = move_slider()
        output = operate!(intcode, input)
        grid = output |> get_pixels |> show_grid
    end
    println("\n\nScore:  ", output[end])
    return output[end]
end
play(data) = Tape(data) |> play!

# Let game play itself with simple position feedback tracking
function autoplay!(intcode)
    intcode[0] = 2
    output = operate!(intcode, 0)
    while output[end-2:end-1] != [-1,0]
        pixels = get_pixels(output)
        paddle, ball = get_positions(pixels)
        input = sign(ball[1] - paddle[1])
        output = operate!(intcode, input)
    end
    return output[end]
end

# Answer getter
get_answer(data) = Tape(data) |> autoplay!

# Get answer
answer2 = get_answer(data)
println("Part 2 answer: ", answer2)
