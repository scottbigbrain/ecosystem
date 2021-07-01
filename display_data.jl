using Plots
using DataFrames
using CSV

history = CSV.read(ARGS[1], DataFrame)

gr()
x = history.Time
y = [history.Mice history.Rabbits history.Hawks]

function plot_stoof() 
	plot(x, y, label=["Mice" "Rabbits" "Hawks"], xlabel="Time", ylabel="Population")
end
# savefig("data3.png")
# gui()
