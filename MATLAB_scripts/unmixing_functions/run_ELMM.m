
function [A, S] = run_ELMM(X, E, width, height, warm_start, verbose, A_init, S_init, maxiter, norm, lambda_e, lambda_a, lambda_s)
% RUN_ELMM Performs Extended Linear Mixing Model (ELMM) using Alternating Direction Method of Multipliers (ADMM)
%
% Syntax:
%   [A, S] = run_ELMM(X, E, width, height, warm_start, verbose, A_init, S_init, maxiter, norm, lambda_e, lambda_a, lambda_s)
%
% Inputs:
%   X         - Hyperspectral image data matrix (n x p)
%   E         - Endmember matrix (p x k)
%   width     - Width of the hyperspectral image
%   height    - Height of the hyperspectral image
%   warm_start- (Optional) Boolean flag to initialize abundances using SCLSU (default: true)
%   verbose   - (Optional) Boolean flag to enable verbose output (default: false)
%   A_init    - (Optional) Initial abundance matrix (endmembers x pixels) (default: uniform distribution)
%   S_init    - (Optional) Initial scaling matrix (endmembers x pixels) (default: ones)
%   maxiter   - (Optional) Maximum number of iterations for the outer ANLS algorithm (default: 300)
%   norm      - (Optional) Norm type for regularization (default: '2,1'). Other options: '1,1'
%   lambda_e  - (Optional) Regularization parameter for endmembers (default: 1e-3)
%   lambda_a  - (Optional) Regularization parameter for abundances (default: 1e-3)
%   lambda_s  - (Optional) Regularization parameter for scalings (default: 1e-3)
%
% Outputs:
%   A         - Estimated abundance matrix (endmembers x pixels)
%   S         - Estimated scaling matrix (endmembers x pixels)
%
% Careful: If warm_start is set to true, the provided initializations A_init will be overwritten by the SCLSU method.
%       If you want to use a specific initialization, set warm_start to false.
% 
%
% Description:
%   This function performs unmixing of hyperspectral images using the Extended Linear Mixing Model (ELMM) with
%   the Alternating Direction Method of Multipliers (ADMM). The function allows for optional warm start initialization
%   using the SCLSU method and provides options for regularization and verbosity.


[p, k] = size(E);

if nargin < 5
    warm_start = true;
end

if nargin < 6
    verbose = false;
end

if nargin < 7
    A_init = ones(k, width*height) / k;
end

if nargin < 8
    S_init = ones(k, width*height);
end

if nargin < 9
    maxiter = 300;
end

if nargin < 10
    norm = '2,1';
end

if nargin < 13
    lambda_e = 1e-3;
    lambda_a = 1e-3;
    lambda_s = 1e-3;
end


% reshape the image matrix
X_r = reshape(X, [width, height, p]);

% initialize the scalings and abundances
% this will overwrite a provided initialization, so provide warm_start = false if you want to use a provided initialization
if warm_start
    if verbose
        disp("starting SCLSU")
    end
    [A_init, ~] = SCLSU(X, E);
end

[A, S, ~, ~] = ELMM_ADMM(X_r, A_init, S_init, E,lambda_e,lambda_a,lambda_s, ...
    norm,verbose, maxiter);

end

