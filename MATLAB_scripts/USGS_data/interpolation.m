% load endmembers into array called "incomplete_Es" with size p x n, where p
% is the number of spectral bands and n is the number of signatures. Invalid points
% should be zero. Provide the wavelengths in an array called "wavelengths"

[p, n] = size(incomplete_Es);
complete_Es = zeros(size(incomplete_Es));

for i=1:n
    incomplete_E = incomplete_Es(:, i);
    valid_wavelengths = wavelengths(incomplete_E > 0);
    
    % linear interpolation and extrapolation
    F = griddedInterpolant(valid_wavelengths, incomplete_E(incomplete_E > 0));
    complete_Es(:, i) = F(wavelengths);
end