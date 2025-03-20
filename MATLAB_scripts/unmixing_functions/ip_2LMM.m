function [A,S] = ip_2LMM(X, E, lb_s, ub_s, options)
% ip_2LMM - Performs the interior point-based two-step Linear Mixing Model (2LMM) unmixing.
%
% Syntax:  [A, S] = ip_2LMM(X, E, lb_s, ub_s, options)
%
% Inputs:
%    X - (n x p) matrix, where n is the number of pixels and p is the number of spectral bands.
%    E - (p x k) matrix of endmembers, where k is the number of endmembers.
%    lb_s - Lower bound for the scaling factors.
%    ub_s - Upper bound for the scaling factors.
%    options - (Optional) Optimization options for the 'lsqnonlin' function.
%
% Outputs:
%    A - (k x n) matrix of abundances.
%    S - (k+n x 1) vector containing the endmember scalings (first k elements) and the sum of abundances for each pixel (last elements).
%
%
% Other m-files required: two_step_LMM.m
%
% See also: lsqnonlin, optimoptions
n = size(X, 1); k = size(E, 2);

if nargin < 5 % use default options
    options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations',...
        1000 * (n*k + k), 'OptimalityTolerance', 1e-8,'FunctionTolerance', 1e-8,...
	'StepTolerance', 1e-8);
end
options.Algorithm = 'Interior-Point';


loss = @(AS) (two_step_LMM(AS, E, X'));

% AS is a (n*k + k) - dimensional vector containing the endmember scalings
% (first k elements) and the non-normalized abundances (last n*k elements)

ub_AS = ub_s * ones(n*k + k, 1);
lb_AS = [lb_s * ones(k, 1); zeros(n*k, 1)];

AS0 = [ones(k, 1); ones(n * k, 1) / k];

[sol, ~, ~, ~, ~] = lsqnonlin(loss, AS0, lb_AS, ub_AS, [], [], [], [], [], options);

SE = sol(1:k);

% A is a (k x n) matrix of abundances
A = reshape(sol(k+1:end), [k, n]);
% normalize the abundances
SX = sum(A, 1);
A = A ./ repmat(SX, [k 1]);

% concatenate the endmember scalings and the sum of abundances for each pixel
S = [SE; SX'];

end

