function plot_scaling_factors(S_hat, nbins, model, max_S, nb, nb_tot)
% PLOT_SCALING_FACTORS Plots histogram and boxplot of scaling factors.
%
%   PLOT_SCALING_FACTORS(S_hat, nbins, model, max_S, nb, nb_tot) plots a 
%   histogram and a boxplot of the scaling factors provided in S_hat.
%
%   Inputs:
%       S_hat  - Matrix of scaling factors.
%       nbins  - Number of bins for the histogram.
%       model  - (Optional) Title for the plots. Default is empty title.
%       max_S  - (Optional) Maximum value for the x-axis limit. If not 
%                provided, it defaults to the maximum value in S_hat.
%       nb     - (Optional) Subplot index for the current plot. Defaults to 1.
%       nb_tot - (Optional) Total number of subplots. Defaults to 1.
%
%   The function creates two subplots:
%       1. A histogram of the scaling factors.
%       2. A horizontal boxplot of the scaling factors.
%
%   Example:
%       S_hat = rand(100, 1);
%       plot_scaling_factors(S_hat, 10, 'Model 1');
%
%   See also: HISTOGRAM, BOXPLOT, SUBPLOT, XLIM, YTICKS, YTICKLABELS
if nargin < 3
    model = '';
end

if nargin < 4
    max_S = max(S_hat(:));
end

if nargin < 6
    nb = 1;
    nb_tot = 1;
end

subplot(2, nb_tot, nb)
histogram(S_hat(:), nbins)
title(model)
xlim([0, max_S])

subplot(2, nb_tot, nb_tot + nb)
boxplot(S_hat(:), 'Orientation','horizontal', 'PlotStyle','compact')
yticks([]); yticklabels([])
xlim([0, max_S])

end

