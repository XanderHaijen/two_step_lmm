function X = multimodalGaussian(mu, sigma, n)
%multimodalGaussian generate a 1D multimodal Gaussian distribution and
%return n samples drawn from it
%
% PARAMETERS:
% - mu: a vector of means of the Gaussian modes
% - sigma: a vector of standard deviations of the Gaussian modes
% - n: number of samples to draw
%

% Check if the input parameters are valid
if length(mu) ~= length(sigma)
    error('The number of means and standard deviations must be the same');
end

if n < 1
    error('The number of samples must be greater than 0');
end

% Generate probability distribution
f = @(x) sum(arrayfun(@(i) normpdf(x, mu(i), sigma(i)), 1:length(mu)));

% Generate samples
n_discarded = 1000;
X = slicesample(0, n_discarded + n, 'pdf', f);
X = X(n_discarded + 1:end);

end

