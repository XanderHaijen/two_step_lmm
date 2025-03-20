function X_hat = two_step_LMM(AS, E, X)
% FUNCTION: two_step_LMM
%
% DESCRIPTION:
%   This function performs a two-step Linear Mixing Model (LMM) unmixing process.
%   It estimates the mixed signal X_hat by subtracting the product of the endmember
%   matrix E, scaling factors SE and SX, and the abundance matrix A from the observed
%   signal X.
%
% INPUTS:
%   AS - A vector containing the scaling factors and the abundance matrix in a 
%        concatenated form. The first k elements are the scaling factors for the 
%        endmembers (SE), the next n elements are the scaling factors for the 
%        observations (SX), and the remaining elements form the abundance matrix (A).
%   E  - A matrix of size (p x k) representing the endmember signatures, where m is 
%        the number of spectral bands and k is the number of endmembers.
%   X  - A matrix of size (p x n) representing the observed mixed signals, where n is 
%        the number of observations and m is the number of spectral bands.
%
% OUTPUT:
%   X_hat - A matrix of size (p x n) representing the estimated
%   reconstruction error matrix after the mixing process.

k = size(E, 2); n = size(X, 2);

SE = AS(1:k);
A = AS(k+1:end);
A = reshape(A, k, n);
X_hat = X - E * diag(SE) * A;

end

