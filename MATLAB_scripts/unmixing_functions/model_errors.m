function [abundance_err,scaling_err] = model_errors(A, A_hat, S, S_hat, sam)
    % MODEL_ERRORS - Calculate the abundance and scaling errors between true and estimated models.
    %
    % DESCRIPTION:
    %   This function calculates the abundance error and scaling error between 
    %   the true and estimated abundance matrices (A and A_hat) and the true 
    %   and estimated scaling matrices (S and S_hat). The abundance error is 
    %   computed as the root mean square error (RMSE) between the vectorized 
    %   forms of A and A_hat. The scaling error can be computed either as the 
    %   RMSE between the vectorized forms of S and S_hat or as the spectral 
    %   angle mapper (SAM) error, depending on the value of the 'sam' parameter.
    %
    % USAGE:
    %   [abundance_error, scaling_error] = model_errors(A, A_hat)
    %   [abundance_error, scaling_error] = model_errors(A, A_hat, S, S_hat)
    %   [abundance_error, scaling_error] = model_errors(A, A_hat, S, S_hat, sam)
    %
    % INPUTS:
    %   A      - True abundance matrix.
    %   A_hat  - Estimated abundance matrix.
    %   S      - (Optional) True scaling matrix.
    %   S_hat  - (Optional) Estimated scaling matrix.
    %   sam    - (Optional) Boolean flag to indicate whether to compute the 
    %            scaling error using the spectral angle mapper (SAM) method. 
    %            Default is false.
    %
    % OUTPUTS:
    %   abundance_error - Root mean square error (RMSE) between the vectorized 
    %                     forms of A and A_hat.
    %   scaling_error   - Scaling error between S and S_hat. If 'sam' is true, 
    %                     the error is computed using the SAM method. If 'sam' 
    %                     is false, the error is computed as the RMSE between 
    %                     the vectorized forms of S and S_hat. If S and S_hat 
    %                     are not provided, scaling_error is NaN.
    %
    %
    % EXCEPTIONS:
    %   Throws an error if the size of S is invalid
abundance_err = abundance_error(A, A_hat);

if nargin < 3
    scaling_err = NaN;
else
    if nargin < 5
        sam = false;
    end

    [k, n] = size(A); sz = size(S);
    
    if ~(length(sz) == 2 && any(sz == 1)) && ~(sz(1) == k && sz(2) == n)
        error("S has invalid size. Should be [1, k + n], [k + n, 1] or [k, n].")
    end

    scaling_err = scaling_error(S, S_hat, sam);

end

