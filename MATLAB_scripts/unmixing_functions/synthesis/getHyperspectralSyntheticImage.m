function [syntheticImage] = getHyperspectralSyntheticImage(endmembers,abundancies)
% [syntheticImage] = getHyperspectralSynthetic(endmembers,abundancies)
%
%    Copyright 2007,2008 Grupo Inteligencia Computacional, Universidad del País Vasco / Euskal Herriko Unibertsitatea (UPV/EHU)
%
%    Website: http://www.ehu.es/ccwintco
%
%    This file is part of the HYperspectral Data Retrieval and Analysis tools (HYDRA) program.
%
%    HYDRA is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    HYDRA is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%    You should have received a copy of the GNU General Public License
%    along with HYDRA.  If not, see <http://www.gnu.org/licenses/>.
%
% Return an hyperspectral synthetic image using a prebuild abundancies sample.
%
% Input:
%   - endmembers: the set of endmembers to use. The endmembers set must be
%   an e rows x p columns matrix, being 'e' the number of endmembers and 'p' the
%   number of bands of each endmember.
%   - abundancies: a sample of abundancies images. The abundancies must be
%   an w x h x n sized matrix, being 'w' and 'h' the width and height of
%   the spatial dimensions of the images, and 'n' the number of images in the sample.
%   'n' has to be equal to the number of endmembers 'e'.
%
% Output:
%   - syntheticImage: a 3-dimensional matrix (w x h x p) representing the built synthetic hyperspectral image.

%% Check parameters
if nargin < 1
    error('You must enter the set of endmembers to be used.');
end
if nargin < 2
    error('You must enter the abudnancies sample.');
end
% Check dimensions
[e p] = size(endmembers);
% Check dimensions
[w h n] = size(abundancies);
if e ~= n
    error('The number of endmembers and abundancies images must be the same.');
end

%% Synthetising
fprintf('Building image\n');
tic;
% Empty image
syntheticImage = double(zeros(w,h,p));
% Build the image
for i=1:w
    for j=1:h
        for k=1:e
            syntheticImage(i,j,:) = squeeze(syntheticImage(i,j,:))' + abundancies(i,j,k)*endmembers(k,:);
        end
    end
end

t = toc;
fprintf('Synthetic hyperspectral image completed in %g seconds.\n',t);