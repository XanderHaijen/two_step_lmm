
function plot_abundance_map(A, width, height, model, nb, tot_nb)
% PLOT_ABUNDANCE_MAP Plots the abundance maps for a given abundance matrix.
%
%   PLOT_ABUNDANCE_MAP(A, WIDTH, HEIGHT, MODEL, NB, TOT_NB) reshapes the
%   abundance matrix A into a 3D array and plots the abundance maps using
%   subplots with k columns and tot_nb rows. The abundance maps are displayed in grayscale.
%
%   Inputs:
%       A       - Abundance matrix of size (k, width*height)
%       WIDTH   - Width of the abundance map
%       HEIGHT  - Height of the abundance map
%       MODEL   - Model name to be displayed in the title
%       NB      - (Optional) Current subplot row number (default is 1)
%       TOT_NB  - (Optional) Total number of subplot rows (default is 1)
%
%   Example:
%       plot_abundance_map(A, 100, 100, 'Model1', 1, 3)
%
%   See also: RESHAPE, SUBPLOT, IMSHOW, GCA, CLIM, TITLE, COLORMAP
if nargin < 5
    nb = 1;
    tot_nb = 1;
end

k = size(A, 1);
A = reshape(A, [k, width, height]);


for j = 1:k
    subplot(tot_nb, k, (nb - 1)*k + j)
    imshow(squeeze(A(j,:,:)), [])
    clim([0 1])
    if j == 1
        ylabel(model)
    end
    colormap gray
end

