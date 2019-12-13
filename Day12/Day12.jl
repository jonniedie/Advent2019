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
Moon(nothing) = error("That's no moon")

# Many moons
MoonSystem = Array{<:Moon}

# Get moons
Io = Moon(x=1, y=4, z=4)
Europa = Moon(x=-4, y=-1, z=19)
Ganymede = Moon(x=-15, y=-14, z=12)
Callisto = Moon(x=-17, y=1, z=10)
moons = [Io, Europa, Ganymede, Callisto]

# Get test moons
test_moons = [Moon(x=-1, y=0, z=2),
              Moon(x=2, y=-10, z=-7),
              Moon(x=4, y=-8, z=8),
              Moon(x=3, y=5, z=-1)]



## Functions
# Update moon states
update_position!(moon::Moon, Δx) = (moon.pos .= moon.pos .+ Δx)
update_velocity!(moon::Moon, Δv) = (moon.vel .= moon.vel .+ Δv)
function update_state!(moon::Moon, Δv)
    Δx = update_velocity!(moon, Δv)
    update_position!(moon, Δx)
end

# Apply gravity and step simulation in time
function gravitate!(moons::MoonSystem)
    last_moons = deepcopy(moons)
    for moon in moons
        Δv = [0,0,0]
        for other_moon in last_moons
            Δv += sign.(other_moon.pos .- moon.pos)
        end
        update_state!(moon, Δv)
    end
end

# Run simulation
simulate!(moons::MoonSystem, steps=1) = [gravitate!(moons) for t in 1:steps]

# Get energy
potential_energy(moon::Moon) = abs.(moon.pos) |> sum
kinetic_energy(moon::Moon) = abs.(moon.vel) |> sum
total_energy(moon::Moon) = potential_energy(moon) * kinetic_energy(moon)
total_energy(moons::MoonSystem) = total_energy.(moons) |> sum



## Part 1
# Answer getter
function get_answer(moons::MoonSystem, steps=1000)
    these_moons = deepcopy(moons)
    simulate!(these_moons, steps)
    return total_energy(these_moons)
end

# Test
@test get_answer(test_moons, 10) == 179

# Get answer
answer1 = get_answer(moons)
println("Part 1 answer: ", answer1)



## Part 2
# Check if system states are the same (in one dimension)
same_state(moon1::Moon, moon2::Moon, i) = moon1.pos[i] == moon2.pos[i] &&
                                          moon1.vel[i] == moon2.vel[i]
same_state(moons1::MoonSystem, moons2::MoonSystem, args...) =
    same_state.(moons1, moons2, args...) |> all

# Get period of repitition in each dimension
function get_periods(moons::MoonSystem)
    moons = deepcopy(moons)
    init_moons = deepcopy(moons)
    elapsed_time = 0
    periods = [0, 0, 0]
    while any(periods .== 0)
        simulate!(moons)
        elapsed_time +=1
        for i in eachindex(periods)
            if periods[i]==0 && same_state(moons, init_moons, i)
                periods[i] = elapsed_time
            end
        end
    end
    return periods
end

# Answer getter
get_answer(moons::MoonSystem) = get_periods(moons) |> lcm

# Test
@test get_answer(test_moons) == 2772

# Get answer
answer2 = get_answer(moons)
println("Part 2 answer: ", answer2)
