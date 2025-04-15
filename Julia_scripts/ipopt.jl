# ipopt.jl performs unmixing using the two-step algorithm. The estimated abundance maps, scaling terms and required time are saved in a new .mat file.

using MAT
using LinearAlgebra
using JuMP, Ipopt
include("ip_unmixing.jl")

model = 4 # model = 1 for scaled LMM, 2 for connected LMM and 3 for extended LMM, 4 for the two-step LMM

println("Unmixing of hyperspectral image")
println("===============================================")

# Load the .mat file
file = matopen("image_data.mat")
# Read variables from the file
X = read(file, "X")
E = read(file, "E")
S_upper = read(file, "S_high")
S_lower = read(file, "S_low")

# Close the file
close(file)

# extract the parameters
p, n = size(X)
_, k = size(E)
println("p = ", p, ", n = ", n, ", k = ", k)

Δt = @elapsed begin
    # pass model type = 4 for the two-step algorithm
    estimated_A, estimated_S = ls_unmixing(X, E, 4, optimizer = optimizer_with_attributes(Ipopt.Optimizer), 
    S_lower = S_lower, S_upper = S_upper)
end

file = matopen("ipopt_results.mat", "w")
write(file, "A_2LMM", estimated_A)
write(file, "S_2LMM", estimated_S)
write(file, "time_2LMM", Δt)
close(file)