# Houston.jl is a companion file for the Houston.m file. It reads the synthetic hyperspectral image and the endmembers from the .mat file and performs 
# unmixing using the two-step algorithm. The estimated abundance maps, estimated scaling terms and required time are saved in a new .mat file.

using MAT
using LinearAlgebra
using JuMP, Ipopt
include("ip_unmixing.jl")

println("Reconstruction of synthetic hyperspectral image")
println("===============================================")

# Load the .mat file
file = matopen("houston_image.mat")

# Read variables from the file
X = read(file, "X")
E = read(file, "E")
close(file)

p, n = size(X)
_, k = size(E)
println("p = ", p, ", n = ", n, ", k = ", k)


Δt = @elapsed begin
    estimated_A, estimated_S = ls_unmixing(X, E, 4, optimizer = optimizer_with_attributes(Ipopt.Optimizer), S_lower = 0.5, S_upper = 2)
end

file = matopen("houston_ipopt.mat", "w")
write(file, "A_2LMM", estimated_A)
write(file, "S_2LMM", estimated_S)
write(file, "time_2LMM", Δt)
close(file)