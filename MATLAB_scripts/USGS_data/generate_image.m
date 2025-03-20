%% set parameters
height = 100;
width = 100;
n = width * height;
k = 4; % fixed, do not change
load usgs_materials.mat
nb_bands = size(wavelengths, 1);
p = 500;
% GRF parameters
%   type = type of gaussian field used:
%       1 - spheric (default)
%		2 - exponential
%		3 - rational
%		4 - matern
type = 4;
% theta1 = 0.8; theta2 = 0.8; % exp rf
theta1 = 20; theta2 = 0.2; % matern rf
% theta1 = 150; theta2 = 0; % spherical rf
SNR = 40;

wavelengths_reduced = linspace(1, nb_bands, p);
wavelengths_reduced = round(wavelengths_reduced);

asphalt = asphalt(wavelengths_reduced, :);
grass_interp = grass_interp(wavelengths_reduced, :);
leafy_spurge_interp = leafy_spurge_interp(wavelengths_reduced, :);
burn_area_interp = burn_area_interp(wavelengths_reduced, :);
wavelengths = wavelengths(wavelengths_reduced);

materials = {"grass", "asphalt", "leafy spurge", "burnt soil"};

% generate k abundance maps based on Gaussian random fields
A = getAbundanciesSampleGaussianFields(k, height, width, type, theta1, theta2);
A = reshape(A, [n, k])';

% generate scaling factors
% normally distributed around 1, and between 0.5 and 1.5
% S = 1 + randn(1, k + width*height) * 0.25;
% S(S < 0.5) = 0.5;
% S(S > 1.5) = 1.5;

% uniformly distributed between 0.5 and 1.5
S = 0.5 + rand(1, k + n);

% uniformly distributed between 0.2 and 8
% S = 0.2 + 7.8 * rand(1, k + n);

%% create endmembers via interpolation

lambda = 0:0.05:1;
L = length(lambda);
p = length(wavelengths);

% for grass
grass1 = grass_interp(:, 1); grass2 = grass_interp(:, 3);
% for asphalt
asphalt1 = asphalt(:, 1); asphalt2 = asphalt(:, 2);
% for leafy spurge
leafy_spurge1 = leafy_spurge_interp(:, 1); leafy_spurge2 = leafy_spurge_interp(:, 4);
%for burnt soil
burn1 = burn_area_interp(:, 1); burn2 = burn_area_interp(:, 2);

EM_grass = zeros(p, L);
EM_asphalt = zeros(p, L);
EM_leafyspurge = zeros(p, L);
EM_burnarea = zeros(p, L);

for j=1:L
    EM_grass(:, j) = lambda(j) * grass1 + (1 - lambda(j)) * grass2;
    EM_asphalt(:, j) = lambda(j) * asphalt1 + (1 - lambda(j)) * asphalt2;
    EM_leafyspurge(:, j) = lambda(j) * leafy_spurge1 + (1 - lambda(j)) * leafy_spurge2;
    EM_burnarea(:, j) = lambda(j) * burn1 + (1 - lambda(j)) * burn2;
end


%% generate the synthetic image, m pixels at a time, each time using a
% randomly chosen combination of endmembers
m = 20;
n_choice = idivide(int32(n), m);

choices_grass = randsample(size(grass_interp, 2), n_choice, 'true');
choices_asphalt = randsample(size(asphalt, 2), n_choice, 'true');
choices_leaf = randsample(size(leafy_spurge_interp, 2), n_choice, 'true');
choices_burnt = randsample(size(burn_area_interp, 2), n_choice, 'true');

X = zeros(p, n);
Se = S(1:k);
for j=1:n_choice
    Ej = [EM_grass(:, choices_grass(j)) EM_asphalt(:, choices_asphalt(j)) ...
        EM_leafyspurge(:, choices_leaf(j)) EM_burnarea(:, choices_burnt(j))];
    Aj = A(:, (j - 1)*m + 1:(j*m));
    X(:, (j - 1)*m + 1:(j*m)) = Ej * Aj;
end

sigma = 10^(-SNR / 10);
X = X + sigma * randn(p, width * height);

% endmembers are the mean of given endmembers, times a scaling factor
E1 = EM_grass(:, 10);
E2 = EM_asphalt(:, 10);
E3 = EM_leafyspurge(:, 10);
E4 = EM_burnarea(:, 10);

E = [E1 E2 E3 E4];

parameters = [width; height; p; k; SNR; 0];

% save X, A, S and E to a .mat file
filename = '/home/vlab/Documents/UAntwerpen/Unmixing/MATLAB_scripts/usgs_image.mat';
save(filename, 'X', 'A', 'S', 'E', 'parameters');

X_cap = X';
X_cap_r = reshape(X_cap, [width, height, p]);


%% hyperspectral unmxing using the linear mixing model

disp('LMM...')

tic
A_LMM = FCLSU(X, E)';
toc

X_LMM = E * A_LMM;
error_A_LMM = sqrt(mean((vec(A_LMM) - vec(A)).^2))
error_X_LMM = sqrt(mean((vec(X_LMM) - vec(X)).^2))

%% hyperspectral unmixing using the scaled linear mixing model

disp("SLMM...")

tic
[A_SLMM, S_SLMM] = SCLSU(X_cap_r, E);
toc

X_SLMM = E * (S_SLMM .* A_SLMM);
error_A_SLMM = sqrt(mean((vec(A_SLMM) - vec(A)).^2))
error_X_SLMM = sqrt(mean((vec(X_SLMM) - vec(X')).^2))

%% hyperspectral unmixing using the extended linear mixing model
lambda_s = 1e-3; 
lambda_a = 1e-3;
lambda_psi = 1e-3;
verbose = true; norm = '2,1';

A_init = A_SLMM;
psis_init = ones(size(A_init));

tic
[A_ELMM, psis_ELMM, S_ELMM, ~] = ELMM_ADMM(X_cap_r, A_init, psis_init, E,lambda_s,lambda_a,lambda_psi,norm,verbose, ...
    300);
toc

X_ELMM = E * (psis_ELMM .* A_ELMM);
error_A = sqrt(mean((vec(A_ELMM) - vec(A)).^2))
error_X = sqrt(mean((vec(X_ELMM) - vec(X_cap)).^2))

%% plot abundance estimates
A_im = reshape(A_SLMM, [k width height]);
for i=1:k
subplot(1,k,i)
imagesc(squeeze(A_im(i,:,:)));
colormap jet
axis equal
xlim([0 width]); ylim([0 height]);
xticks([]); yticks([]);
title(materials{i})
end