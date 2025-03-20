function [A, S] = ip_2LMM_norm(X, E, lb_s, ub_s, options)
% ip_2LMM_norm - Solves the 2-step Linear Mixing Model (2LMM) using 
%               normalized input data and the Interior-Point algorithm.
%
% Syntax:  [A, S] = ip_2LMM_norm(X, E, lb_s, ub_s, options)
%
% Inputs:
%    X - (n x p matrix) The observed mixed data matrix, where n is the 
%        number of observations and p is the number of spectral bands.
%    E - (p x k matrix) The endmember matrix, where k is the number of 
%        endmembers.
%    lb_s - (scalar) The lower bound for the abundance sum-to-one constraint.
%    ub_s - (scalar) The upper bound for the abundance sum-to-one constraint.
%    options - (struct, optional) Options for the optimization algorithm.
%              If not provided, default options are used.
%
% Outputs:
%    A - (k x n matrix) The estimated abundance matrix.
%    S - (n*k x 1 vector) The estimated scaling factors for the endmembers
%       (first k elements) and pixels (last n * k elements)
%
% Example:
%    [A, S] = ip_2LMM_norm(X, E, 0, 1);
%
% Other m-files required: norm_two_step_LMM.m
%
% See also: lsqnonlin, optimoptions

k = size(E, 2); n = size(X, 1); p = size(X, 2);

if nargin < 5 % use default options
    options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations',...
        100 * (n*k + k), 'OptimalityTolerance', 1e-6,'FunctionTolerance', 1e-6,...
	'StepTolerance', 1e-6);
end
options.Algorithm = 'Interior-Point';

norm_X = vecnorm(X, 2, 2);
% X = X ./ vecnorm(X, 2, 2);
X = X ./ repmat(norm_X, [1 p]);

loss = @(AS) (norm_two_step_LMM(AS, E, X'));

lb_AS = [lb_s * ones(k, 1); zeros(n * k, 1)];
ub_AS = [ub_s * ones(k, 1); ones(n * k, 1)];
AS0 = [ones(k, 1); ones(n * k, 1) / k];

beq = ones(n, 1);
Aeq = zeros(n, k + n*k);
for j=1:n
    Aeq(j,j*k+1:(j+1)*k) = 1;
end

% beq = n;
% Aeq = [zeros(1, k) ones(1, k*n)];

% beq = []; Aeq = [];

[sol, ~, ~, ~, ~] = lsqnonlin(loss, AS0, lb_AS, ub_AS, [], [], Aeq, beq, [], options);

S = sol(1:k);
A = reshape(sol(k+1:end), [k, n]);
A = A ./ sum(A, 1);

S_pix = norm_X ./ vecnorm(E * diag(S) * A, 2)';

S = [S; S_pix];

end

