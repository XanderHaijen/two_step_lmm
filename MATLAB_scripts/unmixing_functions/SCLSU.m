function [A, S] = SCLSU(X, E)
%SCLSU perform Scaled Constrained Least Squares Unmixing
%   A = SCLSU(X,E) performs Scaled Constrained Least Squares Unmixing on the
%   data matrix X using the endmember matrix E. The output A is the
%   abundance matrix.
%
%  Inputs:
%   X - data matrix (n x p)
%   E - endmember matrix (p x k)
%
%  Outputs:
%   A - abundance matrix (k x n)
%   S - scaling factors (1 x n)
%
% Author: Xander Haijen (Visionlab, University of Antwerp)

n = size(X, 1); k = size(E, 2);
A = zeros(k, n);
ub = ones(k, 1); lb = zeros(k, 1);

parfor i=1:n
    d = X(i, :)';
    a_i = lsqlin(E, d, [], [], [], [], lb, ub, ones(k, 1) / k);
    A(:, i) = a_i;
end

% normalize the abundance matrix
S = sum(A, 1);
A = A ./ repmat(S, k, 1);

end