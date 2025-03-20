function X_hat = norm_two_step_LMM(AS, E, Xn)
% norm_two_step_LMM - Loss function for the two-step Linear Mixing Model (2LMM) unmixing using
% norm-2 normalization approach.
%
% Inputs:
%    AS - A vector containing the scaling factors (first k elements) and the abundances (last n*k elements) (n*k + k x 1)
%    E  - The endmember matrix (each column represents an endmember) (p x k)
%    Xn - The observed mixed pixel matrix (each column represents a pixel) which has already been normalized (p x n)
%
% Important Note: the matrix Xn should be normalized before calling this function. For performance reasons, the normalization is not
% performed inside this function, and it is also not checked if the input matrix is normalized.
% Outputs:
%    X_hat - The loss function value as a vector (p*n x 1)
%
% See also: RESHAPE, VECNORM
    k = size(E, 2); n = size(Xn, 2);
    
    SE = AS(1:k);
    A = AS(k+1:end);
    A = reshape(A, k, n);
    X_r = E * diag(SE) * A;
    X_r = X_r ./ vecnorm(X_r, 2);
    X_hat = Xn(:) - X_r(:);

end

