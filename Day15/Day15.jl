## Setup
# Import stuff
include("../CommonCode.jl")
using .InputRead: read_csv
using .Intcode: operate!, reset!, Tape
using Test: @test



## Structs
# Repair droid
mutable struct Droid
    intcode::Tape
    position
    last_move
    total_moves
    status
end
Droid(data) = Droid(Tape(data), (0,0), 0, 0, 1)
Droid() = Droid(Tape(99), (0,0), 0, 0, 0)

# Swarm of repair droids
Swarm = Array{Droid}



## Functions
# Command droid movement (could probably combine this with valid_moves)
function move!(droid::Droid, command)
    if command==1
        Δpos = (0,1)
    elseif command==2
        Δpos = (0,-1)
    elseif command==3
        Δpos = (1,0)
    elseif command==4
        Δpos = (-1,0)
    else
        error("Invalid command: $command")
    end
    droid.position = droid.position .+ Δpos
    droid.last_move = command
    droid.total_moves += 1
    droid.status = operate!(droid.intcode, command)[1]
end

# Make sure clone droids don't move in direction that original came from
function valid_moves(droid::Droid)
    if droid.last_move==1
        bad_move = 2
    elseif droid.last_move==2
        bad_move = 1
    elseif droid.last_move==3
        bad_move = 4
    elseif droid.last_move==4
        bad_move = 3
    else
        bad_move = 0
    end
    return filter(move -> move != bad_move, 1:4)
end

# Dispatch new droids from old droid position
function dispatch(droid::Droid)
    moves = valid_moves(droid)
    clones = []
    for move in moves
        clone = deepcopy(droid)
        move!(clone, move)
        if clone.status!=0
            push!(clones, clone)
        end
    end
    return clones
end
function dispatch(swarm::Swarm)
    new_swarm = empty(swarm)
    for droid in swarm
        push!(new_swarm, dispatch(droid)...)
    end
    return new_swarm
end

# Answer getter
get_answer(file, objective) = Droid(read_csv(file)) |> objective
get_answer(droid::Droid, objective) = objective(droid)



## Part 1
# See if the swarm has found the target
function found_target(swarm::Swarm)
    for droid in swarm
        if droid.status == 2
            return (true, droid)
        else
        end
    end
    return (false, Droid())
end

# Find the target
function find_target(swarm::Swarm)
    while true
        swarm = dispatch(swarm)
        found, droid = found_target(swarm)
        if found
            return droid
        end
    end
end
find_target(droid::Droid) = find_target([droid])

# Get answer
droid1 = get_answer("input", find_target)
println("Part 1 answer: ", droid1.total_moves)



## Part 2
# New objective: Fill maze with oxygen
function fill_maze(swarm::Swarm)
    last_droid = Droid()
    while !isempty(swarm)
        last_droid = swarm[end]
        swarm = dispatch(swarm)
    end
    return last_droid
end
fill_maze(droid::Droid) = fill_maze([droid])

# Reset the droid that found the oxygen source
droid1.last_move = 0
droid1.total_moves = 0

# Get last droid to fill the maze
droid2 = get_answer(droid1, fill_maze)
println("Part 2 answer: ", droid2.total_moves)
