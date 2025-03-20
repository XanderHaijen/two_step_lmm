function err = scaling_error(S, S_hat, sad)
    % SCALING_ERROR Computes the scaling error between two matrices or vectors.
    % 
    %   ERR = SCALING_ERROR(S, S_HAT) computes the root mean square error (RMSE)
    %   between the vectorized forms of S and S_HAT.
    %
    %   ERR = SCALING_ERROR(S, S_HAT, SAD) computes the spectral angle distance (SAD)
    %   between S and S_HAT if SAD is true. If SAD is false or not provided, it computes
    %   the RMSE.
    %
    %   Inputs:
    %       S      - The original matrix or vector.
    %       S_HAT  - The estimated matrix or vector.
    %       SAD    - (Optional) Boolean flag to compute SAD instead of RMSE. Default is false.
    %
    %   Outputs:
    %       ERR    - The computed error (RMSE or SAD).
    %
    %   Note:
    %       - If SAD is true and S is a vector, the function computes the angle between
    %         the vectors in degrees.
    %       - If SAD is true and S is a matrix, the function computes the mean angle
    %         between corresponding columns of S and S_HAT in degrees.
    %       - If S has an invalid size, an error is thrown.
    if nargin < 3
        sad = false;
    end

    if sad
        sz = size(S);
        if (length(sz) == 2 && any(sz == 1))
            err = 180 / pi * acos(dot(S, S_hat) / (norm(S, 2) * norm(S_hat, 2)));
        elseif length(sz) == 2
            err = 180 / pi * mean(acos(dot(S, S_hat) ./ (vecnorm(S, 2, 1) .* vecnorm(S_hat, 2, 1))));
        else
            error("S has invalid size. Should be [1, k + n], [k + n, 1] or [k, n].")
        end
    else
        err = sqrt(mean((vec(S) - vec(S_hat)).^2));
    end
end

