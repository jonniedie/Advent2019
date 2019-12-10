## Setup
# Import stuff
using Test: @test
using DelimitedFiles: readdlm
import Base: +, -

# Data getter
function get_data(file)
    f = open(file)
    data = readlines(f)
    data = split.(data, "") .|>
           collect |>
           (x -> vcat(x...)) |>
           (x -> reshape(x, length(data[1]), :)) .|>
           collect .|>
           (x -> x[1])
    close(f)
    return data
end

# Get data
data = get_data("input")
test_data1 = get_data("test_input1")
test_data2 = get_data("test_input2")
test_data3 = get_data("test_input3")
test_data4 = get_data("test_input4")



## Functions
# Vector with least common denominator
function lcd_vector(pt_from, pt_to)
    vector = (pt_to .- pt_from)
    if vector[1]==0 || vector[2]==0
        return sign.(vector)
    else
        frac = //(vector...) |> abs
        return (frac.num, frac.den) .* sign.(vector)
    end
end



## Part 1
# Block the view of occluded asteroids
function block_view!(field, station, asteroid)
    if station == asteroid
        return nothing
    elseif field[asteroid...] == '.'
        return nothing
    end
    h, w = size(field)
    vect = lcd_vector(station, asteroid)
    pt = asteroid .+ vect
    # println(pt)
    while (1 ≤ pt[1] ≤ h) && (1 ≤ pt[2] ≤ w)
        field[pt...] = '.'
        pt = pt .+ vect
    end
    return nothing
end
function block_view!(field, station)
    if field[station...] != '.'
        field[station...] = '🚉'
    else
        return 0
    end

    for i in 1:size(field, 1)
        for j in 1:size(field, 2)
            block_view!(field, station, (i, j))
        end
    end
    return count(x->x=='#', field)
end

# Answer getter
function get_answer(field)
    max_view = 0
    coords = (0, 0)
    for i in 1:size(field, 1)
        for j in 1:size(field, 2)
            view = block_view!(copy(field), (i, j))
            if view > max_view
                max_view = view
                coords = (i, j)
            end
        end
    end
    return (max_view, coords)
end

# Test
@test block_view!(copy(test_data1), (6, 9)) == 33
@test get_answer(copy(test_data1))[1] == 33

# Get answer
answer1, answer1_coords = get_answer(data)
println("Part 1 answer: ", answer1)



## Part 2
# Asteroid struct
mutable struct Asteroid
    angle
    dist
    coords
    exists
end

# Get angle between station and asteroid clockwise from the top
function get_angle(station, asteroid)
    vect = lcd_vector(station, asteroid)
    return 90 + atand(vect[2], vect[1])
end

# Get distance between station and asteroid (Manhattan distance is fine)
get_distance(station, asteroid) = (asteroid .- station) .|> abs |> sum

# Get the asteroids in an asteroid field
function get_asteroids(field, station)
    asteroids = []
    for i in 1:size(field, 1)
        for j in 1:size(field, 2)
            if field[i, j] == '#'
                coords = (i, j)
                push!(asteroids, Asteroid(get_angle(station, coords), get_distance(station, coords), coords, true))
            end
        end
    end
    return sort!(asteroids, by = x -> ((x.angle+360) % 360, x.dist))
end

# Vaporize asteroids!
function vaporize!(field, station, max_count)
    angles = get_asteroids(field, station) |> Iterators.cycle
    last_angle = nothing
    nth_asteroid = nothing
    counter = 0
    for (i, a) in enumerate(angles)
        if a.exists && a.angle != last_angle
            vaporize!(field, a)
            last_angle = a.angle
            counter+=1
            nth_asteroid = a
        end
        if counter == max_count
            break
        end
    end
    return nth_asteroid
end
function vaporize!(field, asteroid::Asteroid)
    field[asteroid.coords...] = '.'
    asteroid.exists = false
end

# Answer getter
function get_answer(field, station, n=200)
    asteroid = vaporize!(copy(field), station, n)
    x, y = asteroid.coords .- 1
    return x*100 + y
end

# Test
@test get_answer(test_data4, (12, 14), 1) == 1112
@test get_answer(test_data4, (12, 14), 2) == 1201
@test get_answer(test_data4, (12, 14), 200) == 802

# Get answer
answer2 = get_answer(data, answer1_coords)
println("Part 2 answer: ", answer2)
