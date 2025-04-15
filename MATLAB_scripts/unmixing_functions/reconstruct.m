function X = reconstruct(E, A, S)
%RECONSTRUCT Reconstruct the data matrix X from the endmembers, abundances, and scalings.
%   X = RECONSTRUCT(E, A, S) reconstructs the data matrix X from the endmember matrix E, the abundance matrix A, and the
%   scaling factors S. The output X is the reconstructed data matrix. The model is deduced from the dimensions of the input
%   matrix S:
%       - If S is empty or if no argument is passed, the Linear Mixing Model (LMM) is used.
%       - If S is a vector of length n, the Scaled Linear Mixing Model (SLMM) is used.
%       - If S is a vector of length k + n, the Two-Layer Mixing Model (2LMM) is used.
%       - If S is a matrix of dimensions k x n, the Extended Linear Mixing Model (ELMM) is used.
%
%  Inputs:
%   E - endmember matrix (p x k)
%   A - abundance matrix (k x n)
%   S - scaling factors (1 x n), (n x 1), (1 x k + n), (k + n x 1), or (k x n)
%
%  Outputs:
%   X - reconstructed data matrix (p x n)
%

if nargin < 3
    S = [];
end

[k, n] = size(A);

if isempty(S) % LMM
    X = E * A;
elseif isequal(size(S), [1, n]) % SLMM
    X = E * A .* S;
elseif isequal(size(S), [n, 1]) % SLMM
    % Note: S is a column vector, so we need to transpose it
    % to match the dimensions for element-wise multiplication
    X = E * A .* S';
elseif isequal(size(S), [1, k + n]) % 2LMM
    X = E * diag(S(1:k)) * A .* S(k+1:end);
elseif isequal(size(S), [k + n, 1]) % 2LMM
    % Note: S(k+1:end) is a column vector, so we need to transpose it
    % to match the dimensions for element-wise multiplication
    X = E * diag(S(1:k)) * A .* S(k+1:end)';
elseif isequal(size(S), [k, n]) % ELMM
    X = E * (S .* A);
else
    error('Invalid input dimensions for S. Valid dimensions are [1, n], [n, 1], [1, k + n], [k + n, 1], or [k, n].')
end

