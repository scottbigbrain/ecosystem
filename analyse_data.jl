using Statistics
using CSV
using DataFrames

data = DataFrame(Mice = Float64[], Rabbits = Float64[])

for (root, dirs, files) in walkdir("data")
	for file in files
		history = CSV.read(string("data/", file), DataFrame)
		m = mean(history.Mice)
		r = mean(history.Rabbits)
		push!(data, [m, r])
	end
end

CSV.write("data/data.csv", data)
