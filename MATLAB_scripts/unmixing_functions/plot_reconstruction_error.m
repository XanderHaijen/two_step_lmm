function [err_min, err_max]= plot_reconstruction_error(X, X_hat, width, height, provide_bounds, type)
    % PLOT_RECONSTRUCTION_ERROR Plots the reconstruction error between two matrices.
    %
    %   [err_min, err_max] = PLOT_RECONSTRUCTION_ERROR(X, X_hat, width, height, provide_bounds, tot_nb, nb, type)
    %   computes and plots the reconstruction error between the original matrix X and the reconstructed matrix X_hat.
    %
    %   Inputs:
    %       X              - Original matrix (p x n) where n is the number of pixels and p is the number of spectral bands.
    %       X_hat          - Reconstructed matrix (p x n).
    %       width          - Width of the reshaped error matrix.
    %       height         - Height of the reshaped error matrix.
    %       provide_bounds - (Optional) Boolean flag to indicate if error bounds should be provided. Default is false.
    %       type           - (Optional) Type of error to compute. Can be 'sam' (Spectral Angle Mapper) or 'rmse' (Root Mean Square Error). Default is 'sam'.
    %
    %   Outputs:
    %       err_min - Minimum error value (if provide_bounds is true, otherwise NaN).
    %       err_max - Maximum error value (if provide_bounds is true, otherwise NaN).
    %
    %
    %   See also: IMAGESC, SUBPLOT, ACOS, DOT, VECNORM, SQRT, MEAN, RESHAPE, SQUEEZE
    if nargin < 5
        provide_bounds = false;
    end

    if nargin < 8
        type = 'sam';
    end


    if strcmp(type, 'sam')
        err = 180 / pi * acos(dot(X, X_hat, 1) ./ (vecnorm(X, 2, 1) .* vecnorm(X_hat, 2, 1)));
    elseif strcmp(type, 'rmse')
        err = sqrt(mean((X - X_hat).^2, 2));
    else
        error('Invalid type. Must be either "rmse" or "sam".')
    end

    err = reshape(squeeze(err), [width, height]);
    
    imshow(err, []);
    colormap jet;
    
    if provide_bounds
        err_min = min(err, [], "all");
        err_max = max(err, [], "all");
    else
        err_min = NaN; err_max = NaN;
    end

end