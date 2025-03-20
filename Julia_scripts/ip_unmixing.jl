# ip_unmixing.jl is a Julia script that contains functions for linear spectral unmixing using different models, and several auxiliary 
# functions for data processing and visualization.

using LinearAlgebra
using JuMP, Ipopt
using MathOptInterface
using Plots
using Statistics

"""
    ls_unmixing(X::Array{T}, E::Array{T}, model::Int; optimizer::MathOptInterface.OptimizerWithAttributes = optimizer_with_attributes(Ipopt.Optimizer), 
    S0:: Union{Array{T}, Vector{T}, Nothing} = nothing, A0:: Union{Array{T}, Vector{T}, Nothing} = nothing, S_upper::Real = 2, S_lower::Real = 0.5,
    quiet::Bool = false, regularization::Union{Array{String}, nothing} = nothing, weights::Union{Real, Array{Real}, nothing} = nothing) where {T <: Real}

Builds and optimizes a linear mixing model (LMM) based on the input data and specified model type.

# Arguments
- `X::Array{T}`: The observed data matrix (p x n).
- `E::Array{T}`: The endmember matrix (p x k).
- `model::Int`: The model type to use (1 to 5).
- `optimizer::MathOptInterface.OptimizerWithAttributes`: The optimizer to use (default is Ipopt).
- `S0::Union{Array{T}, Vector{T}, Nothing}`: Initial scaling vector (optional).
- `A0::Union{Array{T}, Vector{T}, Nothing}`: Initial abundance vector (optional).
- `S_upper::Real`: Upper bound for scaling factors (default is 2).
- `S_lower::Real`: Lower bound for scaling factors (default is 0.5).
- `quiet::Bool`: If `true`, suppresses output (default is `false`).
- `regularization::Union{Array{String}, nothing}`: Regularization terms to apply (optional). Supported terms are "L1", "L2", and "L0".
- `weights::Union{Real, Array{Real}, nothing}`: Weights for regularization terms (optional). Should either be a scalar or have the same length as `regularization`. Default is `1e-2`.


# Returns
- `estimated_A`: The estimated abundance matrix.
- `estimated_S`: The estimated scaling factors.

# Models
1. Scaled LMM: Partially constrained least squares approach.
2. Connected LMM: One scaling factor per endmember.
3. Extended LMM: One scaling factor for every pixel-endmember pair (deprecated, use MATLAB instead).
4. Two-step LMM: One scaling factor for every pixel and endmember.
5. Norm-adjusted LMM: Scaling factor for each endmember, scaled by the norm of the endmember.

# Constraints
- Abundance values (`A`) are constrained to be non-negative.
- Scaling factors (`S`) are constrained between `S_lower` and `S_upper`.
- For models 2, 3, and 5, abundance values (`A`) are constrained to sum to one for each pixel.

# Throws
- `ArgumentError`: If the model type is not recognized or if the initial vectors have incorrect dimensions.
- `ArgumentError`: If the regularization terms and weights have different lengths or if the weights are not a scalar.

# Notes
If unknown regularization terms are provided, a warning is displayed, and the terms are ignored. This does not cause an error. Regularization is only implemented for
the two-step LMM model (model 4) and is ignored for other models.
"""
function ls_unmixing(X::Array{T}, E::Array{T}, model::Int; optimizer::MathOptInterface.OptimizerWithAttributes = optimizer_with_attributes(Ipopt.Optimizer), 
    S0:: Union{Array{T}, Vector{T}, Nothing} = nothing, A0:: Union{Array{T}, Vector{T}, Nothing} = nothing, S_upper::Real = 2, S_lower::Real = 0.5,
    quiet::Bool = false, regularization::Union{Array{String}, Nothing} = nothing, weights = nothing, width::Union{Real, Nothing} = nothing, 
    height::Union{Real, Nothing} = nothing) where {T <: Real}

    p, n = size(X)
    _, k = size(E)
    m = Model(optimizer)

    if ~quiet
        println("Constructing the optimization problem ...")
    end

    # initialize the abundances
    if isnothing(A0)
        @variable(m, A[1:k*n], base_name="A")
        set_start_value.(A, ones(k * n) / k)
    else
        # check if dimensions match
        if length(A0) != k * n
            throw(ArgumentError("Initial abundance vector A0 has wrong dimensions. Expected $(k * n), got $(length(A0))"))
        end
        @variable(m, A[1:k*n], base_name="A", start = A0)
    end

    # initialize the regularization weights if not provided
    if ~isnothing(regularization) && isnothing(weights)
        weights = fill(1e-2, length(regularization))
    end

    if model == 1
        # scaled LMM, constructed using a partially constrained least squares approach
        ℓ = sum((X - E * reshape(A, k, n)).^2)
        @NLobjective(m, Min, ℓ)
        @constraint(m, A .>= 0)
    
    elseif model == 2
        # connected LMM: one scaling factor per endmember
        if isnothing(S0)
            @variable(m, S[1:k], base_name="S")
            set_start_value.(S, ones(k))
        else
            # check if dimensions match
            if size(S0) != (k,)
                throw(ArgumentError("Initial scaling vector S0 has wrong dimensions. Expected $(k), got $(size(S0)) for the connected LMM"))
            end
            @variable(m, S[1:k], base_name="S", start = S0)
        end
        ℓ = sum((X - E * diagm(S) * reshape(A, k, n)).^2)
        @NLobjective(m, Min, ℓ)
        @constraint(m, S .>= S_lower)
        @constraint(m, S .<= S_upper)
        @constraint(m, A .>= 0)
        @constraint(m, A .<= 1)
        # sum to one constraints
        for i=1:n
            @constraint(m, sum(A[(i-1)*k+1:i*k]) == 1)
        end
    
    elseif model == 3
        # extended LMM: one scaling factor for every pixel-endmember pair
        throw(ArgumentError("Extended LMM not implemented in Julia. Use MATLAB version instead."))
    elseif model == 4
        # two-step LMM: one scaling factor for every pixel, one scaling factor for every endmember, solved using a partially constrained least squares approach
        if isnothing(S0)
            @variable(m, S[1:k], base_name="S")
            set_start_value.(S, ones(k))
        else
            # check if dimensions match
            if length(S0) != k
                throw(ArgumentError("Initial scaling vector S0 has wrong dimensions. Expected $(k), got $(length(S0)) for the two-step LMM"))
            end
            @variable(m, S[1:k], base_name="S", start = S0)
        end
        ℓ = sum((X - E * diagm(S) * reshape(A, k, n)).^2)

        if ~isnothing(regularization)
            if length(regularization) != length(weights) && typeof(weights) != Real
                throw(ArgumentError("Regularization and weights must have the same length or weights must be a scalar"))
            end
            if typeof(weights) == Real
                weights = fill(weights, length(regularization))
            end
            
            # apply regularization terms
            penalties = []
            for i ∈ eachindex(regularization)
                if regularization[i] == "L1"
                    ℓ += weights[i] * sum(abs.(A))
                    if ~quiet
                        println("Including L1 regularization")
                    end
                elseif regularization[i] == "L2"
                    ℓ += weights[i] * sum(A.^2)
                    if ~quiet
                        println("Including L2 regularization")
                    end    
                elseif regularization[i] == "smoothness_A_L2"
                    if isnothing(width) || isnothing(height)
                        throw(ArgumentError("Width and height must be specified for smoothness regularization"))
                    end
                    ℓ += weights[i] * smooth_A_penalty(A, width, height, "L2")
                    if ~quiet
                        println("Including smoothness_A_L2 regularization")
                    end
                elseif regularization[i] == "smoothness_A_L1"
                    if isnothing(width) || isnothing(height)
                        throw(ArgumentError("Width and height must be specified for smoothness regularization"))
                    end
                    ℓ += weights[i] * smooth_A_penalty(A, width, height, "L1")
                    if ~quiet
                        println("Including smoothness_A_L1 regularization")
                    end
                else
                    println("WARNING: Ignoring unknown regularization term $(regularization[i])")
                end
            end
        end

        @NLobjective(m, Min, ℓ)
        @constraint(m, S .>= S_lower)
        @constraint(m, S .<= S_upper)
        @constraint(m, A .>= 0)
        @constraint(m, A .<= S_upper)
        # sum constraints
        for i=1:n
            @constraint(m, sum(A[(i-1)*k+1:i*k]) <= S_upper)
        end

    elseif model == 5
        if ~isnothing(regularization)
            # display warning
            println("Regularization is not implemented for norm-adjusted approach. Ignoring regularization.")
        end
        # norm-adjusted LMM: one scaling factor for every endmember, scaled by the norm of the endmember
        if isnothing(S0)
            @variable(m, S[1:k], base_name="S")
            set_start_value.(S, ones(k))
        else
            # check if dimensions match
            if length(S0) != k
                throw(ArgumentError("Initial scaling vector S0 has wrong dimensions. Expected $(k), got $(length(S0)) for the norm-adjusted LMM"))
            end
            @variable(m, S[1:k], base_name="S", start = S0)
        end

        ℓ = sum((X ./ repeat(mapslices(vecnorm, X, dims=1), p, 1) - 
                (E * diagm(S) * reshape(A, k, n)) ./ repeat(mapslices(vecnorm, E * diagm(S) * reshape(A, k, n), dims=1), p, 1)).^2)

        @NLobjective(m, Min, ℓ)

        @constraint(m, S .>= S_lower)
        @constraint(m, S .<= S_upper)
        @constraint(m, A .>= 0)
        @constraint(m, A .<= 1)
        # sum to one constraints
        for i=1:n
            @constraint(m, sum(A[(i-1)*k+1:i*k]) == 1)
        end
    else
        throw(ArgumentError("Unknown model type $model"))
    end

    if ~quiet
        println("Solving the optimization problem ...")
    end

    optimize!(m)

    if ~quiet
        println("Processing the results ...")
    end

    estimated_A = value.(A)
    estimated_A = reshape(estimated_A, k, n)


    if model == 1
        estimated_S = sum(estimated_A, dims=1)
        estimated_A = estimated_A ./ repeat(estimated_S, k, 1)
    elseif model == 2
        estimated_S = value.(S)
    elseif model == 4
        estimated_SX = sum(estimated_A, dims=1)
        estimated_A = estimated_A ./ repeat(estimated_SX, k, 1)
        estimated_SE = value.(S)
        estimated_S = [estimated_SE; estimated_SX']
    elseif model == 5
        estimated_SE = value.(S)
        estimated_SX = mapslices(vecnorm, X, dims=1) ./ mapslices(vecnorm, E * diagm(estimated_SE) * reshape(estimated_A, k, n), dims=1)
        estimated_S = [estimated_SE; estimated_SX']
    end

    return estimated_A, estimated_S

end

"""
    model_errors(A::Union{Array{T}, Vector{T}}, estimated_A::Union{Array{T}, Vector{T}}, 
                 S::Union{Array{T}, Vector{T}}, estimated_S::Union{Array{T}, Vector{T}}, 
                 print::Bool = true, plot::Bool = false, width::Union{Int, Nothing} = nothing, height::Union{Int, Nothing} = nothing) where {T <: Real}

Calculate the Root Mean Square Error (RMSE) between the actual and estimated abundance matrices (A and estimated_A) 
and scaling matrices (S and estimated_S). Optionally, print the errors and plot the abundance errors.

# Arguments
- `A::Union{Array{T}, Vector{T}}`: Actual abundance matrix or vector.
- `estimated_A::Union{Array{T}, Vector{T}}`: Estimated abundance matrix or vector.
- `S::Union{Array{T}, Vector{T}}`: Actual scaling matrix or vector.
- `estimated_S::Union{Array{T}, Vector{T}}`: Estimated scaling matrix or vector.
- `print::Bool`: If `true`, print the RMSE values. Default is `true`.
- `plot::Bool`: If `true`, plot the abundance errors. Default is `false`.
- `width::Union{Int, Nothing}`: Width of the plot. Must be specified if `plot` is `true`.
- `height::Union{Int, Nothing}`: Height of the plot. Must be specified if `plot` is `true`.

# Returns
- `rmse_A`: The RMSE of the abundance matrix/vector.
- `rmse_S`: The RMSE of the scaling matrix/vector.
- `p`: The plot object if `plot` is `true`.

# Throws
- `ArgumentError`: If `plot` is `true` and either `width` or `height` is not specified.
"""
function model_errors(A::Union{Array{T}, Vector{T}}, estimated_A::Union{Array{T}, Vector{T}}; 
    S::Union{Array{T}, Vector{T}, Nothing} = nothing, estimated_S::Union{Array{T}, Vector{T}, Nothing} = nothing, 
    print::Bool = true, plot::Bool = false, width::Union{Int, Nothing} = nothing, height::Union{Int, Nothing} = nothing) where {T <: Real}

    rmse_A = sqrt(mean((vec(A) - vec(estimated_A)).^2))
    if isnothing(S) || isnothing(estimated_S)
        rmse_S = NaN
    else
        rmse_S = sqrt(mean((vec(S) - vec(estimated_S)).^2))
    end

    if print
        println("Abundance error (RMSE) = ", rmse_A)
        println("Scaling error (RMSE) = ", rmse_S)
    end

    if plot
        if isnothing(width) || isnothing(height)
            throw(ArgumentError("Width and height must be specified for plotting"))
        end
        p = plot_errors(A, estimated_A, width, height, "Abundance")
        return rmse_A, rmse_S, p
    else
        return rmse_A, rmse_S
    end
end

"""
    reconstruction(A::Array{T}, S::Array{T}, E::Array{T}, model::Int) where {T <: Real}

Reconstructs the matrix `X_hat` based on the input matrices `A`, `S`, and `E`, and the specified `model`.

# Arguments
- `A::Array{T}`: A matrix of type `T` where `T` is a subtype of `Real`.
- `S::Array{T}`: A matrix of type `T` where `T` is a subtype of `Real`.
- `E::Array{T}`: A matrix of type `T` where `T` is a subtype of `Real`.
- `model::Int`: An integer specifying the model to use for reconstruction. The models are:
    - `1`: Scaled Linear Mixing Model (LMM)
    - `2`: Connected Linear Mixing Model (LMM)
    - `3`: Extended Linear Mixing Model (LMM)
    - `4`: Two-step Linear Mixing Model (LMM)
    - `5`: Norm-adjusted Linear Mixing Model (LMM)

# Returns
- `X_hat`: The reconstructed matrix based on the specified model.

# Models
1. **Scaled LMM**: `X_hat = E * reshape(A, k, n) * diagm(S)`
2. **Connected LMM**: `X_hat = E * diagm(S) * reshape(A, k, n)`
3. **Extended LMM**: `X_hat = E * (reshape(S, k, n) .* reshape(A, k, n))`
4. **Two-step LMM**: 
    - `SE = S[1:k]`
    - `SX = S[k+1:end]`
    - `X_hat = E * diagm(SE) * reshape(A, k, n) * diagm(SX)`
5. **Norm-adjusted LMM**: 
    - `X_hat = (E * diagm(S) * reshape(A, k, n) / repeat(mapslices(vecnorm, E * diagm(S) * reshape(A, k, n), dims=1), p, 1))`
"""
function reconstruction(A::Array{T}, S::Array{T}, E::Array{T}, model::Int) where {T <: Real}
    k, n = size(A)
    p, _ = size(E)

    if model == 1
        # scaled LMM
        X_hat = E * (reshape(A, k, n) .* repeat(S, k, 1))
    elseif model == 2
        # connected LMM
        X_hat = E * diagm(S) * reshape(A, k, n)
    elseif model == 3
        # extended LMM
        X_hat = E * (reshape(S, k, n) .* reshape(A, k, n))
    elseif model == 4
        # two-step LMM
        SX = S[1:n]
        SE = S[n+1:end]
        X_hat = E * diagm(SE) * reshape(A, k, n) * diagm(SX)
    elseif model == 5
        # norm-adjusted LMM
        X_hat = (E * diagm(S) * reshape(A, k, n) / repeat(mapslices(vecnorm, E * diagm(S) * reshape(A, k, n), dims=1), p, 1))
    end
end

"""
    reconstruction_error(X::Array{T}, X_hat::Array{T}; print::Bool = true, plot::Bool = false, width::Union{Int, Nothing} = nothing, height::Union{Int, Nothing} = nothing) where {T <: Real}

Calculate the reconstruction error (Root Mean Square Error, RMSE) between the original matrix `X` and the reconstructed matrix `X_hat`.

# Arguments
- `X::Array{T}`: The original matrix.
- `X_hat::Array{T}`: The reconstructed matrix.
- `print::Bool`: If `true`, prints the RMSE value. Default is `true`.
- `plot::Bool`: If `true`, plots the error. Default is `false`.
- `width::Union{Int, Nothing}`: The width of the plot. Must be specified if `plot` is `true`.
- `height::Union{Int, Nothing}`: The height of the plot. Must be specified if `plot` is `true`.

# Returns
- `rmse_X`: The RMSE value between `X` and `X_hat`.
- `p` (optional): The plot object if `plot` is `true`.

# Throws
- `ArgumentError`: If `plot` is `true` and either `width` or `height` is not specified.

"""
function reconstruction_error(X::Array{T}, X_hat::Array{T}; print::Bool = true, plot::Bool = false, width::Union{Int, Nothing} = nothing, height::Union{Int, Nothing} = nothing) where {T <: Real}
    rmse_X = sqrt(mean((vec(X) - vec(X_hat)).^2))
    
    if print
        println("Reconstruction error (RMSE) = ", rmse_X)
    end

    if plot
        if isnothing(width) || isnothing(height)
            throw(ArgumentError("Width and height must be specified for plotting"))
        end
        p = plot_errors(X, X_hat, width, height, "Reconstruction")
        return rmse_X, p
    else
        return rmse_X
    end
end

"""
    reconstruction_error(X::Array{T}, A::Array{T}, S::Array{T}, E::Array{T}, model::Int; 
                         print::Bool = true, plot::Bool = false, width::Union{Int, Nothing} = nothing, 
                         height::Union{Int, Nothing} = nothing) where {T <: Real}

Calculate the reconstruction error between the original matrix `X` and the reconstructed matrix `X_hat`.

# Arguments
- `X::Array{T}`: The original data matrix.
- `A::Array{T}`: The abundance matrix.
- `S::Array{T}`: The scaling matrix.
- `E::Array{T}`: The endmember matrix.
- `model::Int`: The model identifier used for reconstruction.
- `print::Bool`: Optional; whether to print the error. Default is `true`.
- `plot::Bool`: Optional; whether to plot the error. Default is `false`.
- `width::Union{Int, Nothing}`: Optional; the width of the plot if `plot` is `true`. Default is `nothing`.
- `height::Union{Int, Nothing}`: Optional; the height of the plot if `plot` is `true`. Default is `nothing`.

# Returns
- The reconstruction error between `X` and the reconstructed matrix

# Notes
- The function `reconstruction` is used to compute `X_hat` from `A`, `S`, `E`, and `model`.
- Then the RMSE is calculated between the true data matrix and the reconstruction.
"""
function reconstruction_error(X::Array{T}, A::Array{T}, S::Array{T}, E::Array{T}, model::Int; 
    print::Bool = true, plot::Bool = false, width::Union{Int, Nothing} = nothing, height::Union{Int, Nothing} = nothing) where {T <: Real}
    X_hat = reconstruction(A, S, E, model)
    return reconstruction_error(X, X_hat, print=print, plot=plot, width=width, height=height)
end


"""
    plot_errors(Z::Union{Array{T}, Vector{T}}, estimated_Z::Union{Array{T}, Vector{T}}, width::Int, height::Int, title::String) where {T <: Real}

Plots the error between the true values `Z` and the estimated values `estimated_Z` as a heatmap.

# Arguments
- `Z::Union{Array{T}, Vector{T}}`: The true values, either as a matrix or a vector.
- `estimated_Z::Union{Array{T}, Vector{T}}`: The estimated values, either as a matrix or a vector.
- `width::Int`: The width of the reshaped error matrix.
- `height::Int`: The height of the reshaped error matrix.
- `title::String`: The title for the heatmap plot.

# Returns
- `p`: A heatmap plot of the errors with the specified title.

# Details
The function calculates the root mean square error (RMSE) between `Z` and `estimated_Z`, scales it by 100, and reshapes it into a matrix of dimensions `width` x `height`. 
    The resulting error matrix is then plotted as a heatmap using the `viridis` color scheme.
"""
function plot_errors(Z::Array{T}, estimated_Z::Array{T}, width::Int, height::Int, title::String) where {T <: Real}
    Z_err = sqrt.(mean((Z .- estimated_Z).^2, dims=1)) * 100
    Z_err = reshape(Z_err, width, height)
    p = heatmap(Z_err, aspect_ratio=1, color=:viridis, colorbar = true, title="$title errors (%)", axes=false)
    return p
end

"""
    vecnorm(v::AbstractVector)

Compute the L1 norm (Manhattan norm) of a vector `v`.

# Arguments
- `v::AbstractVector`: A vector of numerical values.

# Returns
- `Float64`: The L1 norm of the vector, which is the sum of the absolute values of its elements.

"""
function vecnorm(v::AbstractVector)
    return sum(abs.(v))
end

"""
    plot_abundance_maps(A::Array{T, 3}) where T<:Real

Plots abundance maps from a 3D matrix `A`.

# Arguments
- `A::Array{T, 3}`: A 3D matrix with dimensions `(k, width, height)` 
where `k` is the number of abundance maps,`width` is the width of each map, 
and `height` is the height of each map.

# Description
This function takes a 3D matrix `A` and plots each 2D slice along the first dimension as 
    an abundance map using a heatmap. 

# Errors
- Throws an error if `A` is not a 3D matrix.
"""
function plot_abundance_maps(A::Array{T}) where T<:Real

    if ndims(A) != 3
        error("A must be a 3D matrix with dimensions (k, width, height)")
    end

    k, _, _ = size(A)
    plots = []

    for i in 1:k
        A_i = A[i, :, :]
        p = heatmap(A_i, c=:thermal, aspect_ratio=1, colorbar=false, axes=false, title="Abundance map $i")
        push!(plots, p)
    end

    return plots
end


"""
    smooth_A_penalty(A::Array, width::Integer, height::Integer, mode::String = "L2") -> Number

Compute a smoothness penalty for a 3D array `A` reshaped into dimensions `(k, width, height)`. 
The penalty is calculated based on the differences between adjacent elements in the horizontal 
and vertical directions, using either L2 or L1 norms.

# Arguments
- `A::Array`: A 1D array to be reshaped into dimensions `(k, width, height)`.
- `width::Integer`: The width of the reshaped array.
- `height::Integer`: The height of the reshaped array.
- `mode::String`: The norm to use for calculating the penalty. 
  - `"L2"` (default): Uses the squared differences (L2 norm).
  - `"L1"`: Uses the absolute differences (L1 norm).

# Returns
- `penalty`: The computed smoothness penalty.

# Notes
- The function assumes that the input array `A` can be reshaped into dimensions `(k, width, height)`.
- The penalty is computed by summing the differences between adjacent elements in both 
  horizontal and vertical directions.

"""
function smooth_A_penalty(A::Array, width::Integer, height::Integer, mode::String = "L2")
    A_r = reshape(A, k, width, height)
    penalty = 0
    # horizontal smoothness
    if mode == "L2"
        for w ∈ 1:width-1
            for h ∈ 1:height
                penalty += sum((A_r[:, w, h] - A_r[:, w+1, h]).^2)
            end
        end
    elseif mode == "L1"
        for w ∈ 1:width-1
            for h ∈ 1:height
                penalty += sum(abs.(A_r[:, w, h] - A_r[:, w+1, h]))
            end
        end
    end

    # vertical smoothness
    if mode == "L2"
        for w ∈ 1:width
            for h ∈ 1:height-1
                penalty += sum((A_r[:, w, h] - A_r[:, w, h+1]).^2)
            end
        end
    elseif mode == "L1"
        for w ∈ 1:width
            for h ∈ 1:height-1
                penalty += sum(abs.(A_r[:, w, h] - A_r[:, w, h+1]))
            end
        end
    end

    return penalty

end
