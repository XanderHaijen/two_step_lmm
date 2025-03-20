function [X, A, S, E, parameters, err] = generateSyntheticImage(height, width, p, k, varargin)
% Generate a synthetic hyperspectral image according to the specified parameters
% [X, A, S, E, PARAMETERS, ERR] = GENERATESYNTHETICIMAGE(HEIGHT, WIDTH, P, K, VARARGIN)
%
% REQUIRED PARAMETERS
%   k = number of endmembers (max 20)
%   height = height of the image in pixels
%   width = width of the image in pixels
%   p = number of spectral bands (max 2151)
%
% OPTIONAL PARAMETERS
%   SNR = signal to noise ratio in dB (default is no noise: SNR = inf dB)
%   model = type of model to use for the generation of the synthetic image
%       - 'regular': each pixel is a linear combination of the endmembers, scaled by a
%       pixel-specific scaling factor
%       - 'connected': each pixel is a linear combination of the endmembers, which are scaled
%       by an endmember-specific scaling factor, which is the same for the entire image
%       - 'extended': each pixel is a linear combination of the endmembers, which are scaled
%       by a scaling factor which differs in each pixel and for each endmember
%       - 'two-step': containing image-wide scaling factors for the
%       endmembers, and additional pixel-wise scaling factors
%       - 'generalized': containing a scaling factor for every spectral
%       bands of every endmember in every pixel
%   type = type of gaussian field used:
%       1 - spheric (default)
%		2 - exponential
%		3 - rational
%		4 - matern
%   S_low = lower bound for the scaling factors (default is 0.5)
%   S_high = upper bound for the scaling factors (default is 1.5)
%   theta1 = parameter for the gaussian random field (default depends on
%   GRF type)
%   theta2 = parameter for the gaussian random field (default depends on
%   GRF type)
%   em_noise = signal to noise ratio for the endmembers (default is no noise)
%       if em_noise is provided, the endmembers are corrupted by Gaussian noise
%       with the specified SNR
%   smooth_S = if true, the scaling factors are generated using a GRF. 
%   If false, the scaling factors are drawn from the uniform distribution 
%   (default is false)
%
% OUTPUT
%   X = the synthetic hyperspectral image
%   A = the abundance maps
%   S = the scaling factors
%   E = the endmembers
%   parameters = the parameters used for the generation of the synthetic image, in the following order:
%       [width; height; p; k; SNR; model_no]
%   err = the added noise matrix
%


%% process input arguments

if nargin - length(varargin) < 4
    error('Not enough input arguments');
elseif nargin - length(varargin) > 4
    error('Too many required input arguments');
end

if rem(length(varargin), 2) ~= 0
    error('Optional parameters must be provided in pairs');
end

% SNR, model, type, S_low, S_high, theta1, theta2, em_noise, smooth_S
% default values
SNR = 1000;
model = 'regular';
type = 1;
S_low = 0.5;
S_high = 1.5;
em_noise = 1000;
theta1 = NaN; % depends on the type of GRF
theta2 = NaN; % depends on the type of GRF
smooth_S = false;

% parse optional parameters
for i=1:2:length(varargin)
    switch upper(varargin{i})
        case 'SNR'
            SNR = varargin{i+1};
        case 'MODEL'
            model = varargin{i+1};
        case 'TYPE'
            type = varargin{i+1};
        case 'S_LOW'
            S_low = varargin{i+1};
        case 'S_HIGH'
            S_high = varargin{i+1};
        case 'THETA1'
            theta1 = varargin{i+1};
        case 'THETA2'
            theta2 = varargin{i+1};
        case 'EM_NOISE'
            em_noise = varargin{i+1};
        case 'SMOOTH_S'
            smooth_S = varargin{i+1};
        otherwise
            warning("Ignoring unknown parameter %s", varargin{i});
    end
end

% set theta1 and theta2 to default values if not provided
if isnan(theta1)
    switch type
        case 1
            theta1 = 20;
        case 2
            theta1 = 0.5;
        case 3
            theta1 = 1.2;
        case 4
            theta1 = 10;
        otherwise
            error('Invalid type of Gaussian random field');
    end
end

if isnan(theta2)
    switch type
        case 1
            theta2 = 0;
        case 2
            theta2 = 0.8;
        case 3
            theta2 = 0.85;
        case 4
            theta2 = 1;
        otherwise
            error('Invalid type of Gaussian random field');
    end
end

if p < 1
    error('Number of bands must be greater than 0');
end

if k < 1
    error('Number of endmembers must be greater than 0');
end

if height < 1
    error('Height must be greater than 0');
end

if width < 1
    error('Width must be greater than 0');
end

% check SNR and em_noise
if em_noise < 0
    error("EM SNR must be greater than 0")
end

if em_noise > 100
    em_noise = 0;
else
    em_noise = 10 ^ (-em_noise / 10);
end

if SNR < 0
    error('SNR must be greater than 0');
end

if SNR > 100
    SNR = 0;
else
    SNR = 10^(-SNR / 10);
end

%% load the endmembers
rng default;
load MATLAB_scripts/unmixing_functions/synthesis/Endmembers/endmembersReflectance.mat
[nb_endmembers, nb_bands] = size(endmembers);

if k > nb_endmembers % nb_endmembers = 20
    error('Number of endmembers exceeds the number of available endmembers which is 20');
end

if p > nb_bands % nb_bands = 2151
    error('Number of bands exceeds the number of available bands which is 2151');
end

% the indices for the wavelengths to be used are equidistantly spaced 
wavelengths = linspace(1, nb_bands, p);
wavelengths = round(wavelengths);

% select k endmembers
E = endmembers(1:k, wavelengths)';
if em_noise > 0
    E = E + em_noise * randn(p, k);
end

%% generate k abundance maps based on Gaussian random fields
A = getAbundanciesSampleGaussianFields(k, height, width, type, theta1, theta2);
A = reshape(A, [height * width, k])';

if strcmp(model, 'regular')
    % simple LMM
    X = E * A;
    S = NaN;
elseif strcmp(model, 'scaled')

    % generate a scaling factor for each pixel
    if smooth_S % GRF based scaling factors
        S = getScalingsSampleGaussianFields(height, width, 4, 20, 2, S_low, S_high);
        S = S(:);
    else % uniformly distributed scaling factors
        S = S_low + (S_high - S_low) * rand(height*width, 1);
    end
    X = (E * A) * diag(S);

elseif strcmp(model, 'connected')
    % generate only the first scaling step of the 2LMM
    % generate scaling factors, uniformly distributed
    S = S_low + (S_high - S_low) * rand(k, 1);

    % generate the synthetic image
    X = E * diag(S) * A;
elseif strcmp(model, 'extended')
    
    if smooth_S
        S = zeros(k, height, width);
        for i=1:k
            S(i, :, :) = getScalingsSampleGaussianFields(height, width, 4, 20, 2, S_low, S_high);
        end
        S = reshape(S, [k, height * width]);
    else
        % uniformly distributed scaling factors
        S = S_low + (S_high - S_low) * rand(k, height * width);
    end

    % generate the synthetic image
    X = E * (S .* A);

elseif strcmp(model, 'two-step')

    if smooth_S
        % EM scalings are uniformly distributed
        SE = S_low + (S_high - S_low) * rand(k, 1);
        % pixel scalings are GRF
        SX = getScalingsSampleGaussianFields(height, width, 4, 20, 2, S_low, S_high);
        S = [SE; SX(:)];
    else
        % uniformly distributed between 0.5 and 1.5
        S = S_low + (S_high - S_low) * rand(1, k + width*height);
    end

    % generate the synthetic image
    X = E * diag(S(1:k)) * A * diag(S(k+1:end));
elseif strcmp(model, 'generalized')
    % in every pixel, generate a scaling vector for each endmember, with
    % wavelength-dependent scaling factors

    if smooth_S
        S = zeros(p, k, height, width);
        for i=1:k
            parfor j=1:p
                S(j, i, :, :) = getScalingsSampleGaussianFields(height, width, 4, 20, 2, S_low, S_high);
            end
        end
        S = reshape(S, [p, k, height * width]);
    else
        S = S_low + (S_high - S_low) * rand(p, k, width * height);
    end
    
    X = zeros(p, width * height);
    for j=1:width*height
        X(:, j) = (S(:,:,j) .* E) * A(:, j);
    end
else
    error('Invalid model. Choose between ''scaled'', ''connected'', ''extended'', ''two-step'', and ''generalized''');
end

%% add noise
err = randn(p, height * width) * SNR * mean(X, 'all');
err = reshape(err, [p, width*height]);
X = X + err;

switch model
    case 'regular'
        model_no = 0;
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

parameters = [width; height; p; k; SNR; model_no];

end