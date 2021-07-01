# if on linux, run `export ALSA_CONFIG_DIR=/usr/share/alsa` before running this program

using GameZero
import GameZero.draw
using Colors

global game_mode = true;
include("src.jl")

const unit = 8
const WIDTH = 3*unit*length(bounds[1][1])
const HEIGHT = int(sqrt(3)*unit*length(bounds[2][1]))
const BACKGROUND = colorant"grey"
frame = 1

function draw(g::Game)
	fill(BACKGROUND)

	# for i in 1:2
	# 	for j in bounds[1][i]
	# 		for k in bounds[2][i]
	# 			draw_hex_from_sim(j, k)
	# 		end
	# 	end
	# end

	for g in grass
		draw_hex_from_sim(g.x, g.y, colorant"green", fill=true)
	end

	for b in bushes
		draw_hex_from_sim(b.x, b.y, convert(Colorant, RGB(.0, .29, .0)), fill=true)
	end

	for m in mice
		draw_hex_from_sim(m.loc.x, m.loc.y, convert(Colorant, RGB(.44, .29, .05)), fill=true)
	end
	for r in rabbits
		draw_hex_from_sim(r.loc.x, r.loc.y, convert(Colorant, RGB(.29, .2, .05)), fill=true)
	end

	for h in hawks
		draw_hex_from_sim(h.loc.x, h.loc.y, colorant"red", fill=true)
	end
end

function update(g::Game)
	if (frame%1 == 0) update_sim(frame) end

	global frame += 1
end


function draw_hex_from_sim(x_in, y_in, color=colorant"black"; fill=false)
	x, y = 1.5*x_in*unit, 0.5*sqrt(3)*y_in*unit
	draw_hex(x, y, unit, color, fill=fill)
end

function draw_hex(x, y, u, color=colorant"black"; fill=false)
	# Define all the verticies
	x1, y1 = int(x - u/2), int(y - sqrt(3)*u/2)
	x2, y2 = int(x - u  ), int(y              )
	x3, y3 = int(x - u/2), int(y + sqrt(3)*u/2)
	x4, y4 = int(x + u/2), int(y + sqrt(3)*u/2)
	x5, y5 = int(x + u  ), int(y              )
	x6, y6 = int(x + u/2), int(y - sqrt(3)*u/2)

	if !fill
		# just draw the edges
		draw(Line(x1, y1, x2, y2), color)
		draw(Line(x2, y2, x3, y3), color)
		draw(Line(x3, y3, x4, y4), color)
		draw(Line(x4, y4, x5, y5), color)
		draw(Line(x5, y5, x6, y6), color)
		draw(Line(x6, y6, x1, y1), color)
	
	else
		#draw the face
		draw(Rect(x1, y1, x6-x1, y3-y1), color, fill=true)
		draw(Triangle(x1, y1, x2, y2, x3, y3), color, fill=true)
		draw(Triangle(x4, y4, x5, y5, x6, y6), color, fill=true)

	end
end


rungame()
