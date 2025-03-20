function phi = angle_two_step_LMM(AS, E, Xn)
% angle_two_step_LMM - Computes the negative cosine similarity between the 
% input data and the estimated data for a two-step Linear Mixing Model (LMM).
%
% Syntax: phi = angle_two_step_LMM(AS, E, Xn)
%
% Inputs:
%    AS - A vector containing the abundance matrix (A) and scaling factors (S) (k + n values)
%    E - The endmember matrix (each column represents an endmember) (p x k)
%    Xn - The observed data matrix (each column represents an observation) (p x n)
%
% Outputs:
%    phi - The negative cosine similarity value
%
% See also: RESHAPE, DOT, VECNORM, DIAG
k = size(E, 2); n = size(Xn, 2);
S = AS(1:k);
A = AS(k+1:end);
A = reshape(A, k, n);

% since we have to maximize the cosine similarity, we will minimize
% the negative
phi = - sum((dot(Xn, E * diag(S) * A)) ./ (vecnorm(Xn, 2) .* vecnorm(E * diag(S) * A, 2)));
end

