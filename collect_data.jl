using Random

print("Input unique data collection tag: ")
tag = readline()

print("Input number of simulation runs: ")
len = parse(Int64, readline())

print("Input starting seed: ")
start = parse(Int64, readline())

print("Input seed step: ")
step = parse(Int64, readline())


for i in 1:len
	seed = i*step + start
	Random.seed!(seed)

	global name = string("data/", tag, "-data", i, ".csv")
	println(string("Run ", i))
	include("src.jl")
end
