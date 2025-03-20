function [syntheticImageCollection,abundanciesGT,endmembersGT] = getHyperspectralSyntheticImageCollectionLegendre(n,endmembers,ne)
% [syntheticImageCollection,abundanciesGT,endmembersGT] = getHyperspectralSyntheticImageCollectionLegendre(n,endmembers,ne)
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
% Return an hyperspectral synthetic image collection by Legendre polynomies method.
%
% Input:
%   - n: the number of synthetic hyperspectral images in the collection
%   - endmembers: the set of endmembers to use. The endmembers set must be
%   an e rows x p columns matrix, being 'e' the number of endmembers and 'p' the
%   number of bands of each endmember.
%   - ne: the number of endmembers selected from the set of endmembers to
%   build each image.
% Output:
%   - syntheticImageCollection: a 4-dimensional matrix (n x w x h x p) representing the built synthetic hyperspectral collection.
%   - abundanciesGT: a 4-dimensional matrix (n x w x h x ne) representing
%   the abundancies groundtruth collection used to build the syhtnetic
%   image collection.
%   - endmembersGT: a 3-dimensional matrix (n x ne x p) representing
%   the endmembers groundtruth collection used to build the syhtnetic
%   image collection.

%% Check parameters
if nargin < 1
    error('You must enter the number of images to be created.');
end
if nargin < 2
    error('You must enter the set of endmembers to be used.');
end
if nargin < 3
    error('You must enter the number of endmembers to use to build each image.');
end
% Check dimensions
[e p] = size(endmembers);
% Build default abundancies collection
fprintf('Building default abundancies collection\n');
tic;
abundanciesGT = getAbundanciesCollectionLegendre(n,ne);
t = toc;
% Check dimensions
[n2 w h e2] = size(abundanciesGT);
if ne ~= e2 || n ~= n2
    error('An error ocurred while building the abundancies collection.');
end

%% Synthetising
fprintf('\nBuilding image collection\n\n');
% Empty image
syntheticImageCollection = double(zeros(n,w,h,p));
t2 = zeros(1,n);
endmembersGT = zeros(n,ne,p);
for l=1:n
    % Build the image
    tic;
    fprintf('Building image %g.\n',l);
    % Select random non-previously selected endmember
    selectedEndmember = ones(1,e);
    for k=1:ne
        z = floor(rand()*e + 1);
        repeat = true;
        while repeat
            if selectedEndmember(1,z) == 1
                repeat = false;
            else
                z = z+1;
                if z > e
                    z = 1;
                end
            end
        end
        selectedEndmember(1,z) = 0;
        endmembersGT(l,k,:) = endmembers(z,:);
    end
    for i=1:w
        for j=1:h
            for k=1:ne
                syntheticImageCollection(l,i,j,:) = squeeze(syntheticImageCollection(l,i,j,:)) + squeeze(endmembersGT(l,k,:))*abundanciesCollection(l,i,j,k);
            end
        end
    end
    t2(1,l) = toc;
    fprintf('Image %g completed in %g seconds.\n\n',l,t2(1,l));
end

fprintf('Synthetic hyperspectral image collection completed in %g seconds.\n',t+sum(t2));