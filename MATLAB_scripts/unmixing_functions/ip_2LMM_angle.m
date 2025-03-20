
function [A, S] = ip_2LMM_angle(X, E, lb_s, ub_s, A_init, options)
%IP_2LMM_ANGLE Performs two-step linear mixing model (LMM) unmixing using SAD minimization.
%   [A, S] = IP_2LMM_ANGLE(X, E, lb_s, ub_s, A_init, options) performs unmixing of the
%   hyperspectral data matrix X using the endmember matrix E. The function minimizes the
%   angle between the observed and reconstructed spectra assuming a two-step LMM.
%
%   Inputs:
%       X       - Hyperspectral data matrix (n x p), where n is the number of pixels and p is the number of bands.
%       E       - Endmember matrix (p x k), where k is the number of endmembers.
%       lb_s    - Lower bound for the scaling factors.
%       ub_s    - Upper bound for the scaling factors.
%       A_init  - (Optional) Initial abundance matrix (k x n).
%       options - (Optional) Optimization options for 'fmincon'.
%
%   Outputs:
%       A       - Estimated abundance matrix (k x n).
%       S       - Estimated scaling factors (k+1 x 1), where the last element is the pixel pseudo-scaling factor.
%
%   The function uses the 'fmincon' solver with the 'Interior-Point' algorithm to minimize
%   the objective function defined by the angle between the observed and reconstructed spectra.
%   The sum-to-one constraint is enforced on the abundance matrix.
%
%   See also ANGLE_TWO_STEP_LMM, FMINCON, VECNORM, OPTIMOPTIONS.

k = size(E, 2); n = size(X, 1); p = size(X, 2);

if nargin < 6 % use default options
    options = optimoptions('fmincon', 'Display', 'iter', 'MaxFunctionEvaluations',...
        1000 * (n*k + k));
end
options.Algorithm = 'Interior-Point';

norm_X = vecnorm(X, 2, 2);

% objective function
loss = @(AS) (angle_two_step_LMM(AS, E, X'));

% upper/lower bounds and initial guess
lb_AS = [lb_s * ones(k, 1); zeros(n * k, 1)];
ub_AS = [ub_s * ones(k, 1); ones(n * k, 1)];

if nargin < 5
    AS0 = [ones(k, 1); ones(n * k, 1) / k];
else
    AS0 = [ones(k, 1); A_init(:)];
end

% construct the matrix for the sum-to-one constraint
beq = ones(n, 1);
Aeq = zeros(n, k + n*k);
for j=1:n
    Aeq(j,j*k+1:(j+1)*k) = 1;
end

% solve using general constrained optimization solver fmincon
sol = fmincon(loss, AS0, [], [], Aeq, beq, lb_AS, ub_AS, [], options);


S = sol(1:k);
A = reshape(sol(k+1:end), k, n);

% build the pixel psuedo-scaling factors
S_pix = norm_X ./ vecnorm(E * diag(S) * A, 2)';
S = [S; S_pix];

end