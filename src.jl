# Try out Random.seed!(576474)

include("vector.jl")
include("prey.jl")
include("hawk.jl")

using CSV
using DataFrames
using Base.Threads

# Vectors for each possible direction
const vec_for_dir = [Vector(1,1), Vector(0,2), Vector(-1,1), Vector(-1,-1), Vector(0,-2), Vector(1,-1), Vector(0,0)]


const x_min, x_max = 0, 100
const y_min, y_max = 0, 100
const bounds = [[x_min:2:x_max, x_min+1:2:x_max], [y_min:2:y_max, y_min+1:2:y_max]]
const area = (x_max-x_min)*(y_max-y_min)

const mouse_camo = 0.26
const rabbit_speed = 10

const new_times = area / 3500
const spread_chance = area / 80000


include("functions.jl")


grass = Vector[]
for _ in 1:10+area/6
	push!(grass, rand_hex())
end
eaten_grass = Vector[]

bushes = Vector[]
for _ in 1:5+area/50
	push!(bushes, rand_hex())
end

prey_count = 2+area/10
mice = Prey[]
for _ in 1:prey_count/2
	v = rand_hex()
	push!(mice, Prey(v.x, v.y, species=:mouse))
end
rabbits = Prey[]
for _ in 1:prey_count/2
	v = rand_hex()
	push!(rabbits, Prey(v.x, v.y, species=:rabbit))
end

hawks = Hawk[]
for _ in 1:2+area/90
	v = rand_hex()
	push!(hawks, Hawk(v.x, v.y))
end

population = DataFrame(Time = Int[], Grass = Int[], Mice = Int[], Rabbits = Int[], Hawks = Int[])


function update_sim(i)
	@threads for h in hawks
		update(h)
	end

	@threads for m in mice
		update(m)
	end
	@threads for r in rabbits
		update(r)
	end

	for i in 1:2 grow_grass() end
end


if !isdefined(Main, :game_mode)

sim_len = 800
for i in 1:sim_len
	update_sim(i)

	if (i%round(sim_len/100) == 0)
		push!(population, [i, length(grass), length(mice), length(rabbits), length(hawks)])
	end
	if (i%20==0)
		print("-")
	end
end
print("|\n")

try
	CSV.write(name, population)
catch
	CSV.write("data/foo.csv", population)
end

end

