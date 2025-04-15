function A = FCLSU(X, E)
%FCLSU perform Fully Constrained Least Squares Unmixing
%   A = FCLSU(X,E) performs Fully Constrained Least Squares Unmixing on the
%   data matrix X using the endmember matrix E. The output A is the
%   abundance matrix.
%
%  Inputs:
%   X - data matrix (p x n)
%       where p is the number of spectral bands and n is the number of
%       pixels
%   E - endmember matrix (p x k)
%       where p is the number of spectral bands and k is the number of
%       endmembers
%
%  Outputs:
%   A - abundance matrix (k x n)
%
% Author: Xander Haijen (Visionlab, University of Antwerp)

n = size(X, 2); k = size(E, 2);
A = zeros(k, n);
ub = ones(k, 1); lb = zeros(k, 1);
beq = 1; ceq = ones(1, k);

parfor i=1:n
    d = X(:, i);
    a_i = lsqlin(E, d, [], [], ceq, beq, lb, ub, ones(k, 1) / k);
    A(:, i) = a_i;
end

end

