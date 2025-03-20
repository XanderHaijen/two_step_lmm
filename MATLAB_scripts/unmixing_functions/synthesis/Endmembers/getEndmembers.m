function [endmembers] = getEndmembers(folder)
% [endmembers] = getEndmembers(folder)
%
%    Copyright 2010 Grupo Inteligencia Computacional, Universidad del País Vasco / Euskal Herriko Unibertsitatea (UPV/EHU)
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
% Extract the information on the given USGS folder to a matlab struct variable.
%
% Input:
%   - fodler: path to one of the USGS folders. The folder must contain
%   'asc' files.
%
% Output:
%   - endmembers: a struct containing the information of the materials
%   name, measured wavelengths, reflectance and standar deviations provided by
%   the 'asc' files on the given folder.

files = dir(folder);
count = 1;
fprintf('Number of files: %g\n',size(files,1));
for i=1:size(files,1)
    fprintf('Reading file %g\n',i);
    if ~strcmp(files(i).name,'.') && ~strcmp(files(i).name,'..')
        endmembers(count).name = files(i).name;
        fid = fopen([folder '/' files(i).name],'r');
        while feof(fid) == 0
            tline = fgetl(fid);
            if strcmp(tline,'----------------------------------------------------');
                break;
            end
        end
        tline = fgetl(fid);
        tline = fgetl(fid);
        band = 1;
        A = zeros(1,3);
        while feof(fid) == 0
            tline = fgetl(fid);
            A = sscanf(tline,'%f');
            endmembers(count).wavelength(band) = A(1);
            endmembers(count).reflectance(band) = A(2);
            endmembers(count).std(band) = A(3);
            band = band + 1;
        end
        fclose(fid);
        count = count + 1;
    end
end