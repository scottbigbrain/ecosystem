is_valid(v::Vector) = v.x%2 == v.y%2

int(x::Float64) = Int(round(x))

hex_dist(a::Vector, b::Vector) = abs(a.x - b.x)/(4/6) + abs(a.y - b.y)/(8/6)

function rand_hex()
	i = rand(1:2)
	return Vector(rand(bounds[1][i]), rand(bounds[2][i]))
end

function grow_grass(new_times=new_times, spread_chance=spread_chance)
	# if not to big, grow
	if (length(grass) < (x_max-x_min)*(y_max-y_min)/3)
		# spring up new grass
		for _ in 1:new_times
			push!(grass, rand_hex())
		end

		# possibly spread exsisting grass
		@threads for i in 1:2:length(grass)
			g = grass[i]
			if (rand() < spread_chance)
				# find where is will spread
				n = rand(vec_for_dir) + g
				# if the place it will spread to is outside the bounds, don't do it
				if (n.x < x_min)
					n = vec_for_dir[rand([1,6])] + g
				elseif (n.x > x_max)
					n = vec_for_dir[rand([3,4])] + g
				elseif (n.y < y_min)
					n = vec_for_dir[2] + g
				elseif (n.y > y_max)
					n = vec_for_dir[5] + g
				end
				push!(grass, n)
			end
		end

		# put some grass where there was grass before
		if (length(eaten_grass) > 0)
			for _ in 1:rand(1:3)
				index = rand(1:length(eaten_grass))
				push!(grass, eaten_grass[index])
				deleteat!(eaten_grass, index)
			end
		end
	end
end