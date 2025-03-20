function [X, A, S, E, parameters, err] = generate_stand_image(width, height, p, k, SNR, model, type, S_low, S_high, smooth_S)
%GENERATE_STAND_IMAGE A wrapper for the generateSyntheticImage function providing some standard combinations for types and parameters
%
% INPUTS:
%   width   - Width of the image.
%   height  - Height of the image.
%   p       - Number of spectral bands.
%   k       - Number of endmembers.
%   SNR     - Signal-to-noise ratio (dB).
%   model   - Model of the image (see generateSyntheticImage for details).
%   type    - Type of the Gaussian field used (integer from 1 to 4).
%   S_low   - Lower bound for the scaling factors (positive float). Default is 0.5.
%   S_high  - Upper bound for the scaling factors (positive float). Default is 1.5.
%   smooth_S- Flag to indicate whether or not to generate the scalings from a GRF. Default is false.
%
% OUTPUTS:
%   X          - The generated image.
%   A          - The true abundance matrix.
%   S          - The true endmember matrix.
%   E          - The true endmember matrix.
%   parameters - The parameters of the generated image. See generateSyntheticImage for details.
%   err        - The error added to the image. See generateSyntheticImage for details.
%
    if nargin < 7
        type = 1; % spheric
    end
 
    if nargin < 8
        S_low = 0.05;
        S_high = 3;
    end

    if nargin < 9
        smooth_S = false;
    end

    %   type = type of gaussian field used:
    %       1 - spheric (default)
    %		2 - exponential
    %		3 - rational
    %		4 - matern

    switch type
        case 1
            theta1 = 150; theta2 = 0;
        case 2
            theta1 = 0.8; theta2 = 0.8;
        case 3
            theta1 = 1.2; theta2 = 0.85;
        case 4
            theta1 = 20; theta2 = 0.2;
    end
    em_noise = 101;
    [X, A, S, E, parameters, err] = generateSyntheticImage(height, width, p, k, SNR, ...
        model, type, S_low, S_high, theta1, theta2, em_noise, smooth_S);
end

