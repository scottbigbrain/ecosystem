
mutable struct Prey
	loc::Vector

	health::Float64
	hunger::Float64
	eaten::Int
	age::Int

	last_move::Int
	in_bush::Bool
	sense_dist::Real

	species::Symbol
end

function Prey(x::Int, y::Int, sd=9; species=:mouse)
	return Prey(Vector(x, y), 1., 0., 0, 0, 1, false, sd, species)
end

function reproduce(p::Prey)
	new_loc = p.loc + rand(vec_for_dir)
	return Prey(new_loc, 1., 0., 0, 0, 1, false, p.sense_dist, p.species)
end

function sense(p::Prey)
	in_veiw = Vector[]
	for g in grass
		# see if it is in the sight circle
		dist = hex_dist(p.loc, g)
		if (dist <= p.sense_dist)
			push!(in_veiw, g)
		end
	end

	return in_veiw
end

function sense_hawks(p::Prey)
	in_veiw = Hawk[]
	for h in hawks
		dist = hex_dist(p.loc, h.loc)
		if (dist <= p.sense_dist)
			if (rand() < 0.95) push!(in_veiw, h) end
		end
	end

	return in_veiw
end

function sense_bushes(p::Prey)
	in_veiw = Vector[]
	for b in bushes
		# see if it is in the sight circle
		dist = hex_dist(p.loc, b)
		if (dist <= p.sense_dist)
			push!(in_veiw, b)
		end
	end

	return in_veiw
end

function best_move(p::Prey, target::Vector)
	to = target - p.loc

	to_check = Int[7]
	if (to.x < 0) append!(to_check, [2, 3, 4, 5]) elseif (to.x > 0) append!(to_check, [2, 1, 6, 5]) end
	if (to.y < 0) append!(to_check, [6, 5, 4])    elseif (to.y > 0) append!(to_check, [1, 2, 3])    end
	to_check = Set(to_check)

	dir = 1
	best = Inf
	for i in to_check
		score = hex_dist(vec_for_dir[i], to)
		if (score < best)
			best = score
			dir = i
		end
	end

	return dir
end

function decide(p::Prey, near_g)
	r_vecs = Vector[]  # holds the reletive vector to the grass from the mouse
	for g in near_g
		push!(r_vecs, g - p.loc)
	end 

	target_i = 1
	best = Inf
	for i in 1:length(near_g)
		g = near_g[i]
		score = hex_dist(p.loc, g)
		if (score < best)
			best = score
			target_i = i
		end
	end

	return best_move(p, near_g[target_i])
end

function run(p::Prey, near_h)
	r_vecs = Vector[]  # holds the reletive vector to the grass from the mouse
	for h in near_h
		push!(r_vecs, h.loc - p.loc)
	end 

	target_i = 1
	best = Inf
	for i in 1:length(near_h)
		h = near_h[i]
		score = hex_dist(p.loc, h.loc)
		if (score < best)
			best = score
			target_i = i
		end
	end

	r_vecs[target_i] *= -1
	return best_move(p, p.loc + r_vecs[target_i])
end

function move(p::Prey, dir::Int, running::Bool=false)
	# find where is will move
	n = vec_for_dir[dir] + p.loc

	# if the place it will move to is outside the bounds, don't do it
	if (n.x < x_min)
		n = vec_for_dir[rand([1,6])] + p.loc

	elseif (n.x > x_max)
		n = vec_for_dir[rand([3,4])] + p.loc

	elseif (n.y < y_min)
		n = vec_for_dir[2] + p.loc

	elseif (n.y > y_max)
		n = vec_for_dir[5] + p.loc

	end
	
	p.loc = n

	if (!running)
		# if you turn a new direction that takes more energy
		if (dir != p.last_move)
			p.hunger += 0.0215
		else
			p.hunger += 0.0125
			p.last_move = dir
		end
	elseif (dir == 0)
		p.hunger += 0.001
	else
		p.hunger += 0.0125/rabbit_speed
		p.last_move = dir
	end
	return true
end

function eat(p::Prey)
	eaten = findall(x -> x == p.loc, grass)
	append!(eaten_grass, grass[eaten])
	deleteat!(grass, eaten)

	p.hunger -= length(eaten) * 0.06
	p.eaten += length(eaten)
end


function update(p::Prey)
	# if they weren't just born, move around
	if (p.age > 3)

		near_h = sense_hawks(p)

		# only romp around in there is not a nearby hawk
		if (length(near_h) == 0)
			in_veiw = sense(p)	

			if (length(in_veiw) > 0)
				dir = decide(p, in_veiw)
				move(p, dir)

				eat(p)

			else
				if (rand()<0.75)
					p.last_move += (p.last_move > 1 && p.last_move < 6) * rand(-1:1)
					p.last_move += (p.last_move==1)*rand([1,5]) + (p.last_move==6)*rand([-1,-5])
				end
				move(p, p.last_move)
			end
		
		else
			near_b = sense_bushes(p)

			if (p.species == :rabbit)
				i=1
				while i<=rabbit_speed && (length(near_h) > 0 || length(near_b) > 0)
					if (length(near_b) == 0)
						dir = run(p, near_h)
						move(p, dir, true)
					else
						dir = decide(p, near_b)
						move(p, dir, true)
					end

					near_h = sense_hawks(p)
					near_b = sense_bushes(p)
					i += 1
				end

				if (length(findall(x->x==p.loc, near_b)) > 0)
					p.in_bush = true
				else
					p.in_bush = false
				end

				eat(p)
			else
				dir = run(p, near_h)
				move(p, dir)

				eat(p)
			end
		end
	end

	# loose some health if hungery, gain it back if not
	if (p.hunger >= 0.6)
		p.health -= p.hunger
	elseif (p.hunger < 0.5 && p.hunger < 1)
		p.health += 0.015
	end

	# die if dead
	if (p.health <= 0)
		if (p.species == :mouse)
			deleteat!(mice, findall(x -> x==p, mice))
		else
			deleteat!(rabbits, findall(x -> x==p, rabbits))
		end
	end

	# reproduce if able
	if (p.health > 0.5 && p.eaten >= 3)
		p.eaten = rand(0:3)
		if (p.species == :mouse)
			push!(mice, reproduce(p))
		else
			push!(rabbits, reproduce(p))
		end
	end

	p.age += 1
end
