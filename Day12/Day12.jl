## Setup
# Import stuff
using Test: @test


## Get data
# A moon
mutable struct Moon
    pos
    vel
end
Moon(; x=0, y=0, z=0) = Moon([x, y, z], [0, 0, 0])
Moon() = error("That's no moon")

# Get moons
Io = Moon(x=1, y=4, z=4)
Europa = Moon(x=-4, y=-1, z=19)
Ganymede = Moon(x=-15, y=-14, z=12)
Callisto = Moon(x=-17, y=1, z=10)
moons = [Io, Europa, Ganymede, Callisto]

test_moons = [Moon(x=-1, y=0, z=2),
              Moon(x=2, y=-10, z=-7),
              Moon(x=4, y=-8, z=8),
              Moon(x=3, y=5, z=-1)]



## Functions
# Update position
update_position!(moon::Moon, dx) = (moon.pos .= moon.pos .+ dx)

# Update velocity
update_velocity!(moon::Moon, dv) = (moon.vel .= moon.vel .+ dv)

# Update position and velocity
function update_state!(moon::Moon, dv)
    dx = update_velocity!(moon, dv)
    update_position!(moon, dx)
end

get_gravity(moon::Moon, other_moon::Moon) = sign.(other_moon.pos .- moon.pos)

# Apply gravity and step simulation in time
function gravitate!(moons::Array{<:Moon})
    last_moons = deepcopy(moons)
    for moon in moons
        dv = [0,0,0]
        for other_moon in last_moons
            dv += get_gravity(moon, other_moon)
        end
        update_state!(moon, dv)
    end
end

# Energy
potential_energy(moon::Moon) = abs.(moon.pos) |> sum
kinetic_energy(moon::Moon) = abs.(moon.vel) |> sum
total_energy(moon::Moon) = potential_energy(moon) * kinetic_energy(moon)
total_energy(moons::Array{<:Moon}) = total_energy.(moons) |> sum

# Run simulation
function simulate!(moons::Array{<:Moon}, stop_time=1)
    for t in 1:stop_time
        gravitate!(moons)
    end
end



## Part 1
# Answer getter
function get_answer(moons::Array{<:Moon}, stop_time=1000)
    these_moons = deepcopy(moons)
    simulate!(these_moons, stop_time)
    return total_energy(these_moons)
end

# Test
@test get_answer(test_moons, 10) == 179

# Get answer
answer1 = get_answer(moons)
println("Part 1 answer: ", answer1)



## Part 2
same_state(moon1::Moon, moon2::Moon, i) = moon1.pos[i] == moon2.pos[i] &&
                                          moon1.vel[i] == moon2.vel[i]
same_state(moons1::Array{<:Moon}, moons2::Array{<:Moon}, args...) =
    same_state.(moons1, moons2, args...) |> all

# Get period of repitition in each dimension
function get_periods(moons::Array{<:Moon})
    moons = deepcopy(moons)
    init_moons = deepcopy(moons)
    counter = 0
    received_period = [false, false, false]
    period = [0, 0, 0]
    while !all(received_period)
        simulate!(moons)
        counter +=1
        for i in 1:3
            if !received_period[i] && same_state(moons, init_moons, i)
                received_period[i] = true
                period[i] = counter
            end
        end
    end
    return period
end

# Answer getter
get_answer(moons::Array{<:Moon}) = get_periods(moons) |> lcm

# Test
@test get_answer(test_moons) == 2772

# Get answer
answer2 = get_answer(moons)
println("Part 2 answer: ", answer2)
