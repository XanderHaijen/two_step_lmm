function [A, S] = SCLSU(X, E, varargin)
% SCLSU - Spectral Constrained Least Squares Unmixing
% Description:
%   This function performs spectral unmixing using either a closed-form 
%   solution or a constrained least squares optimization. The method 
%   estimates the abundance matrix (A) and the sum of abundances (S) 
%   for a given input data matrix (X) and endmember matrix (E).
%
% Inputs:
%   X - (p x n) matrix, where n is the number of pixels and p is the number
%       of spectral bands. Represents the observed mixed pixel data.
%   E - (p x k) matrix of endmembers, where k is the number of endmembers.
%       Each column represents an endmember spectrum.
%
% Optional Name-Value Pair Arguments:
%   'closedform' - Logical value (true/false). If true, the closed-form 
%                  solution is used for unmixing. If false, the 
%                  constrained least squares optimization is used 
%                  (default: false).
%
% Outputs:
%   A - (k x n) matrix. The abundance matrix, where each column represents 
%       the estimated abundances of the endmembers for a given pixel.
%   S - (1 x n) vector. The sum of abundances for each pixel.
%
% Notes:
%   - The closed-form solution is faster but may not enforce constraints 
%     as strictly as the optimization-based approach.
%   - The constrained least squares optimization enforces non-negativity 
%     and abundance sum-to-one constraints.
%
% Example:
%   % Define input data matrix X and endmember matrix E
%   X = rand(100, 10); % 100 pixels, 10 spectral bands
%   E = rand(10, 5);   % 10 spectral bands, 5 endmembers
%
%   % Perform unmixing using the closed-form solution
%   [A, S] = SCLSU(X, E, 'closedform', true);
%
%   % Perform unmixing using constrained least squares optimization
%   [A, S] = SCLSU(X, E, 'closedform', false);
%
% See also:
%   lsqlin

%% parse optional arguments
if nargin - length(varargin) < 2
    error('Not enough input arguments. Expected at least 2 (X, E).');
end

if rem(length(varargin), 2) ~= 0
    error('Optional arguments must be in name/value pairs.');
end

closedform = false;
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'closedform'
            closedform = varargin{i + 1};
        otherwise
            warning('Ignoring unknown parameter name: %s', varargin{i});
    end
end

%% main unmixing process
k = size(E, 2);

if closedform % solve the problem using closed form expression
    A = (E' * E) \ (E' * X);
    A = max(A, 0); % enforce non-negativity
else % solve the problem using lsqlin
    n = size(X, 2);
    A = zeros(k, n);
    lb = zeros(k, 1);
    ub = ones(k, 1);

    parfor i=1:n
        d = X(:, i);
        a_i = lsqlin(E, d, [], [], [], [], lb, ub, ones(k, 1) / k);
        A(:, i) = a_i;
    end
end

% normalize the abundance matrix
S = sum(A, 1);
A = A ./ repmat(S, k, 1);

end