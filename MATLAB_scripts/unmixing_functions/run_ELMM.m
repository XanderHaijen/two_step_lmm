
function [A, S, E] = run_ELMM(X, E, width, height, varargin)
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
%
%   Optional Inputs:
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


if nargin - length(varargin) < 4
    error('Not enough input arguments. Expected at least 4 (X, E, width, height).');
end

if rem(length(varargin), 2) ~= 0
    error('Optional arguments must be in name/value pairs.');
end

%% parse optional arguments
[p, k] = size(E);
warm_start = true;
verbose = false;
A_init = ones(k, width*height) / k;
S_init = ones(k, width*height);
maxiter = 300;
norm = '2,1';
lambda_e = 1e-3;
lambda_a = 1e-3;
lambda_s = 1e-3;

for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'warm_start'
            warm_start = varargin{i + 1};
        case 'verbose'
            verbose = varargin{i + 1};
        case 'a_init'
            A_init = varargin{i + 1};
        case 's_init'
            S_init = varargin{i + 1};
        case 'maxiter'
            maxiter = varargin{i + 1};
        case 'norm'
            norm = varargin{i + 1};
        case 'lambda_e'
            lambda_e = varargin{i + 1};
        case 'lambda_a'
            lambda_a = varargin{i + 1};
        case 'lambda_s'
            lambda_s = varargin{i + 1};
        case 'spatial_reg'
            if ~varargin{i + 1}
                lambda_s = 0;
                lambda_a = 0;
            end
        otherwise
            warning('Ignoring unknown parameter name: %s', varargin{i});
    end
end

% reshape the image matrix
X_r = reshape(X', [width, height, p]);

%% initialize the scalings and abundances
% this will overwrite a provided initialization, so provide warm_start = false if you want to use a provided initialization
if warm_start
    if verbose
        disp("starting SCLSU")
    end
    [A_init, ~] = SCLSU(X, E);
end

%% run ELMM

[A, S, E, ~] = ELMM_ADMM(X_r, A_init, S_init, E,lambda_e,lambda_a,lambda_s, ...
    norm, verbose, maxiter);

end

