
function [X, A, S, E, parameters, err] = generate_structured_data(n, p, k, SNR, model, S_low, S_high)
% GENERATE_STRUCTURED_DATA Generates structured hyperspectral data as all possible combinations of n elements divided into k groups
%
% Syntax:
%   [X, A, S, E, parameters, err] = generate_structured_data(n, p, k, SNR, model, S_low, S_high)
%
% Inputs:
%   n       - Number of pixels (scalar)
%   p       - Number of spectral bands (scalar)
%   k       - Number of endmembers (scalar)
%   SNR     - Signal-to-noise ratio (scalar)
%   model   - Variability model ('two-step' or 'extended')
%   S_low   - Lower bound for scaling factors (optional, default = 0.5)
%   S_high  - Upper bound for scaling factors (optional, default = 1.5)
%
% Outputs:
%   X         - Generated hyperspectral data matrix (p x n)
%   A         - Abundance matrix (k x n)
%   S         - Scaling factors (vector or matrix depending on model)
%   E         - Endmember matrix (p x k)
%   parameters- Parameters used for data generation (vector)
%   err       - Added noise matrix (p x n)
%
% Description:
%   This function generates structured hyperspectral data based on the specified
%   number of pixels, spectral bands, endmembers, and signal-to-noise ratio. The
%   data is generated according to the specified variability model ('two-step' or
%   'extended'). The function also adds random noise to the generated data.
%
% See also:
%   calculate_abundance, fzero, randperm, randn, linspace, diag, mean
    
    if nargin < 7
        S_low = 0.5;
        S_high = 1.5;
    end

    if p > 224
        disp('Warning: p > 224, setting p = 224');
        p = 224;
    end

    if k > 6
        disp('Warning: k > 6, setting k = 6');
        k = 6;
    end
    
    % load data and initialize parameters
    load E.mat
    sigma = 10^(-SNR / 10);

    % select k random endmembers
    E = E(:, 1:k);
    % select p equidistant spectral bands
    bands = linspace(1, 224, p);
    bands = floor(bands);
    E = E(bands, :);
    
    % calculate abundance
    % to determine the number of points along a face of the simplex when we are given the total
    % number of points and the number of groups, we find the root of the following polynomial minus n
    switch k
        case 2
            f = @(x) (x + 1);
        case 3
            f = @(x) (0.5 * x.^2 + 1.5*x + 1);
        case 4
            f = @(x) (0.1607*x.^3 + x.^2 + 1.833*x + 1);
        case 5
            f = @(x) (0.0417*x.^4 + 0.4167 * x.^3 + 1.4583*x.^2 + 2.0833*x + 1);
        case 6
            f = @(x) (0.0083 * x.^5 + 0.1250 * x.^4 + 0.07083 * x.^3 + 1.8750 * x.^2 + 2.2833 * x + 1);
    end

    % find the nb where f is closest to n, and round up
    nb = fzero(@(x) (f(x) - n), 10);
    nb = ceil(nb);

    % calculate the structured sequence of abundances
    A = calculate_abundance(nb, k);
    A = A(:, 1:n);
    
    % generate variability according to model
    if strcmp(model, "two-step")
        %generate a two-step linear mixing model (2LMM) dataset
    
        % generate scaling factors
        scaling_pixels = S_low + (S_high - S_low) * rand(n, 1);
        scaling_endmembers = S_low + (S_high - S_low) * rand(k, 1);
        S = [scaling_pixels; scaling_endmembers];
        
        % generate image
        E = E(:, 1:k);
        X = E * diag(scaling_endmembers) * A * diag(scaling_pixels);
    elseif strcmp(model, "extended")
        %generate an extended linear mixing model (ELMM) dataset
        
        % generate scaling factors
        S = S_low + (S_high - S_low) * rand(k, n);
        
        % generate image
        E = E(:,1:k);
        X = E * (S .* A);
    else
        error("Model not recognized. Please choose 'two-step' or 'extended'.");
    end

    %add random error and save to file
    err = sigma * mean(X, 'all') * randn(p, n);
    X = X + err;
    
    switch model
        case 'scaled'
            model_no = 1;
        case 'connected'
            model_no = 2;
        case 'extended'
            model_no = 3;
        case 'two-step'
            model_no = 4;
        case 'generalized'
            model_no = 5;
    end

    parameters = [n 1 p k SNR model_no];
end

