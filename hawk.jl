
mutable struct Hawk
	loc::Vector

	health::Float64
	hunger::Float64
	eaten::Int
	age::Int

	last_move::Int
	sense_dist::Real
end

function Hawk(x::Int, y::Int, sd=12)
	return Hawk(Vector(x, y), 1., 0., 0, 0, 1, sd)
end

function reproduce(h::Hawk)
	new_loc = h.loc + rand(vec_for_dir)
	return Hawk(new_loc, 1., 0., 0, 0, 1, h.sense_dist)
end

function sense(h::Hawk)
	in_veiw = Vector[]
	for m in mice
		# see if it is in the sight circle
		dist = hex_dist(h.loc, m.loc)
		if (dist <= h.sense_dist)
			if (rand() < mouse_camo) push!(in_veiw, m.loc) end
		end
	end
	for r in rabbits
		# see if it is in the sight circle
		dist = hex_dist(h.loc, r.loc)
		if (dist <= h.sense_dist)
			if (rand() < 0.7 && (!r.in_bush || (r.in_bush&&rand()<0.01))) push!(in_veiw, r.loc) end
		end
	end

	return in_veiw
end

function decide(h::Hawk, near_p)
	r_vecs = Vector[]  # holds the reletive vector to the grass from the mouse
	for p in near_p
		push!(r_vecs, p - h.loc)
	end 

	target_i = 1
	best = Inf
	for i in 1:length(near_p)
		p = near_p[i]
		score = hex_dist(h.loc, p)
		if (score < best)
			best = score
			target_i = i
		end
	end

	# check which move will get you closest to the target, and move there.
	to = r_vecs[target_i]

	to_check = Int[]
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

function move(h::Hawk, dir::Int)
	# find where is will move
	n = vec_for_dir[dir] + h.loc

	# if the place it will move to is outside the bounds, don't do it
	if (n.x < x_min)
		n = vec_for_dir[rand([1,6])] + h.loc

	elseif (n.x > x_max)
		n = vec_for_dir[rand([3,4])] + h.loc

	elseif (n.y < y_min)
		n = vec_for_dir[2] + h.loc

	elseif (n.y > y_max)
		n = vec_for_dir[5] + h.loc

	end
	
	h.loc = n

	# if you turn a new direction that takes more energy
	if (dir != h.last_move)
		h.hunger += 0.015
	else
		h.hunger += 0.0075
		h.last_move = dir
	end
	return true
end

function update(h::Hawk)
	# if they weren't just born, move around
	if (h.age > 3)

		in_veiw = sense(h)	

		if (length(in_veiw) > 0)
			i=1
			while length(in_veiw) > 0 && i <= 2
				dir = decide(h, in_veiw)
				move(h, dir)

				eaten = findall(x -> x.loc == h.loc, mice)
				deleteat!(mice, eaten)
				eaten = findall(x -> x.loc == h.loc, rabbits)
				deleteat!(rabbits, eaten)

				h.hunger -= length(eaten) * 0.175
				h.eaten += length(eaten)

				in_veiw = sense(h)
				i += 1
			end
		else
			if (rand()<0.75)
				h.last_move += (h.last_move > 1 && h.last_move < 6) * rand(-1:1)
				h.last_move += (h.last_move==1)*rand([1,5]) + (h.last_move==6)*rand([-1,-5])
			end
			move(h, h.last_move)
		end

	end

	# loose some health if hungery, gain it back if not
	if (h.hunger >= 0.6)
		h.health -= h.hunger
	elseif (h.hunger < 0.5 && h.hunger < 1)
		h.health += 0.015
	end

	# die if dead
	if (h.health <= 0)
		deleteat!(hawks, findall(x -> x==h, hawks))
	end

	# reproduce if able
	if (h.health > 0.5 && h.eaten >= 4)
		h.eaten = 1
		push!(hawks, reproduce(h))
	end

	h.age += 1
end
