function scalings = getScalingsSampleGaussianFields(height, width, type, theta1, theta2, S_min, S_max)
% [abundanciesSample] = getAbundanciesSampleGaussianFields(ne, height, width, type, theta1, theta2)
% Returns a synthetic sample of abundancy images by Gaussian Fields
% method. This work is based on:
%   Computations With Gaussian Random Fields
%   Kozintsev, Boris
%   1999, PhD Thesis 1999-3
%   ISR (Institute for System Research), University of Maryland
%
% Input:
%   - height,width: spatial dimensions of the images (> 0, defaults are 256,256).
%   - type: type of gaussian field used:
%       1 - spheric (default)
%		2 - exponential
%		3 - rational
%		4 - matern
%   - theta1,theta2: parameters for the gaussian field type
%       - spheric (defaults):    
%                   theta1 > 0 (usually between 1 and 200) 
%			        theta2 = 0 (don't used)
%		- exponential:  
%                   theta1 = (0,1)
%                   theta2 = (0, 2]
%				Usually:
%					theta1 = 0.5, 0.7, 0.9
%					theta2 = 0.8, 1.3, 1.9
%
%		- rational:     
%                   theta1, theta2 > 0
%				Usually:
%					theta1 = 1.2, 1.6, 1.85
%					theta2 = 0.85, 1.5, 2 	
%		- matern: 	
%                   theta1, theta2 > 0
%				Usually:
%					theta1 = 5, 10, 20
%					theta2 = 0.5, 1, 2
%
% Output:
%   - abundanciesSample: a 2-dimensional matrix (width x height).

%% Check parameters
% defaults
switch nargin
    case 0
        height = 256; width = 256; type = 1; theta1 = 100; theta2 = 0; S_min = 0.5; S_max = 1.5;
    case 1
        width = 256; type = 1; theta1 = 100; theta2 = 0; S_min = 0.5; S_max = 1.5;
    case 2
        type = 1; theta1 = 100; theta2 = 0; S_min = 0.5; S_max = 1.5;
    case 3
        switch type
            case 1
                theta1= 100; theta2 = 0;
            case 2
                theta1= 0.7; theta2 = 1.3;
            case 3
                theta1= 1.6; theta2 = 1.5;
            case 4
                theta1= 10; theta2 = 1;
        end
        S_min = 0.5; S_max = 1.5;
    case 4
        switch type
            case 1
                theta2 = 0;
            case 2
                theta2 = 1.3;
            case 3
                theta2 = 1.5;
            case 4
                theta2 = 1;
        end
        S_min = 0.5; S_max = 1.5;
    case 5
        S_min = 0.5; S_max = 1.5;
    case 6
        S_max = 1.5;
end

% check parameters
if height <= 0 || width <= 0
	error('width and height has to be greater than zero\n');
end

if type < 1 || type > 4
	error('gaussian field type is incorrect');
end

switch type
	case 1
        if (theta1 < 0)
        	warning('Model parameters are incorrect, defaults used.')
            theta1 = 100; theta2 = 0;
        end
	case 2
        if theta1 <= 0 || theta1 >= 1 || theta2 <= 0 || theta2 > 2
        	warning('Model parameters are incorrect, defaults used.')
        	theta1= 0.7; theta2 = 1.3;
        end
	case 3
        if theta1 <= 0 || theta2 <= 0
        	warning('Model parameters are incorrect, defaults used.')
        	theta1= 1.6; theta2 = 1.5;
        end
	case 4
        if theta1 <= 0 || theta2 <= 0
        	warning('Model parameters are incorrect, defaults used.')
        	theta1= 10; theta2 = 1;
        end
end

if S_min >= S_max
    error('S_min has to be smaller than S_max\n');
end

if S_min < 0 || S_min > 1
    error('S_min has to be in the interval [0,1]\n');
end

if S_max < 1
    error('S_max has to be greater than 1\n');
end

%% Build the sample
% Get the fewer power of 2 greater than width and height
nn = 2^nextpow2(max(height,width));
% Generate lambda
lambda = lambdaGeneration(nn, type, theta1, theta2);
% Generate samples (using abundance generation)
[scalings, ~] = getSamples(lambda, height, width, 1);

% center at mean 1
scalings = scalings - mean(scalings(:)) + 1;

% all values < 1 are rescaled to the interval [S_min, 1]
scalings(scalings < 1) = S_min + (1 - S_min) / (1 - min(scalings(:))) * (scalings(scalings < 1) - min(scalings(:)));
% all values > 1 are rescaled to the interval [1, S_max]
scalings(scalings > 1) = 1 + (S_max - 1) / (max(scalings(:)) - 1) * (scalings(scalings > 1) - 1);

end
