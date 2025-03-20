function err = abundance_error(A, A_hat)
% ABUNDANCE_ERROR - Calculate the root mean square error (RMSE) between two abundance matrices.
%
% Inputs:
%    A - Original abundance matrix
%    A_hat - Estimated abundance matrix
%
% Outputs:
%    err - Root mean square error between the original and estimated abundance matrices
%
% Example:
%    A = [0.1, 0.2; 0.3, 0.4];
%    A_hat = [0.1, 0.25; 0.35, 0.45];
%    err = abundance_error(A, A_hat);
%
% See also: vec, mean, sqrt
    err = sqrt(mean((vec(A) - vec(A_hat)).^2));
end

