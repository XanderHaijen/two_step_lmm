function err = image_error(X,X_hat, type)
% IMAGE_ERROR Compute the error between two images using specified metric.
%
%   ERR = IMAGE_ERROR(X, X_HAT, TYPE) computes the error using the 
%   specified metric TYPE. TYPE can be either 'rmse' (Root Mean Square 
%   Error) or 'sam' (Spectral Angle Mapper). If TYPE is not provided, 
%   'sam' is used by default.
%
%   Inputs:
%       X      - Original image (matrix).
%       X_HAT  - Estimated image (matrix).
%       TYPE   - (Optional) Error metric to use ('rmse' or 'sam'). Default is 'sam'.
%
%   Outputs:
%       ERR    - Computed error between X and X_HAT.
%
%   See also: VEC, VECNORM, DOT, ACOS
if nargin < 3
    type = 'sam';
end

if strcmp(type, 'rmse')
    err = sqrt(mean((X(:) - X_hat(:)).^2));
elseif strcmpi(type, 'sam') || strcmpi(type, 'sad')
    err = 180 / pi * mean(acos(dot(X, X_hat, 1) ./ (vecnorm(X, 2, 1) .* vecnorm(X_hat, 2, 1))));
    err = abs(err); % remove imaginary part which might arise due to roundoff errors
else
    error('Invalid type. Must be either "rmse" or "sam".')
end

