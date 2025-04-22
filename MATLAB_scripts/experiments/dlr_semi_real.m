%% DLR hybrid synthetic-real data experiment
clear all
close all
rng default

%% set parameters
SNR = 1000; % Signal-to-Noise Ratio in dB
S_low = 0.5; S_high = 1.5; % lower and upper bounds for the generation of scaling factors
smooth_S = false; % if true, the pixel scaling factors are generated using a Gaussian Random Field (GRF)
model = 'extended'; % or 'two-step'. Selects the physical model used for variability generation
type = 4; theta1 = 15; theta2 = 1.5; % GRF parameters, used if smooth_S = true

%% generate a semi-real hyperspectral image based on the DLR dataset
load DLR_HySU/large_targets.mat
% load DLR_HySU/all_targets.mat
[width, height, p] = size(X); % p = number of spectral bands
[~, k] = size(E); % k = number of endmembers
n = width * height; % n = number of pixels
X_r = reshape(X, [n, p])';


% re-order endmembers to for nicer visualization results later on
E = [E(:, 1) E(:, 5) E(:, 4) E(:, 2) E(:, 3) E(:, 6)];
materials = {materials{1}, materials{5}, materials{4}, materials{2}, materials{3}, materials{6}};
%% find the ground truth as the solution of FCLSU
A_gt = FCLSU(X_r, E);

% plot_abundance_map(A_gt, width, height, 'GT')
% for i=1:6
%     subplot(1,6,i)
%     title(materials{i})
% end

%% generate new image based on real abundances and endmembers

sigma = 10^(-SNR / 10);
err = sigma * randn(p, n) * mean(X_r, 'all'); % noise


if strcmp(model, "two-step")
    % generate the pixel scaling factors
    if smooth_S
        SX = getScalingsSampleGaussianFields(width, height, type, theta1, theta2, S_low, S_high);
    else
        SX = S_low + (S_high - S_low) * rand(n, 1);
    end
    
    % plot the pixel scaling factors
    % heatmap(reshape(SX, [width, height]));
    % colormap jet;
    % title("Pixel scaling factors");

    SE = S_low + (S_high - S_low) * rand(k, 1); % endmember scaling vector
    S = [SE; SX(:)]; % total scaling vector

    % generate synthetic image
    X = E * diag(S(1:k)) * A_gt * diag(S(k+1:end)) + err;
elseif strcmp(model, 'extended')
    if smooth_S
        S = zeros(k, width, height);
        for i=1:k
            S(i, :, :) = getScalingsSampleGaussianFields(width, height, type, theta1, theta2, S_low, S_high);
        end

        % plot the scaling values
        % tiledlayout;
        % for i=1:k
        %     nexttile;
        %     heatmap(squeeze(S(i, :, :)))
        %     colormap jet
        % end

        S = reshape(S, [k, n]); % reshape to proper dimensions
    else
        S = S_low + (S_high - S_low) * rand(k, n);
    end

    % generate synthetic image
    X = E * (S .* A_gt) + err;
else
    error("´´model´´ should be either ´´extended´´ or ´´two-step´´")
end


% save E and X to file
save('image_data.mat', "X", "E", "S_low", "S_high");

% variables for bookkeeping
RMSE_A = zeros(5, 1);
RMSE_X = zeros(5, 1);
SAD_X = zeros(5, 1);
delta_t = zeros(5, 1);

%% Fully constrained least squares (FCLSU)

disp("FCLSU")

tic
A_LMM = FCLSU(X, E);
delta_t(1) = toc;

RMSE_A(1) = model_errors(A_gt, A_LMM);
%% Scaled Constrained Least Squares (SCLSU)

disp("SCLSU")

tic
[A_SLMM, S_SLMM] = SCLSU(X, E);
delta_t(2) = toc;

RMSE_A(2) = model_errors(A_gt, A_SLMM);

%% Extended Linear Mixing Model (Warm start)
A_init = A_SLMM;

disp("ELMM (Warm start)")
tic
[A_ELMM_WS, S_ELMM_WS] = run_ELMM(X, E, width, height, ...
    'warm_start', false, 'verbose', false, 'A_init', A_init);
delta_t(3) = toc;
delta_t(3) = delta_t(3) + delta_t(2); % add time to compute SCLSU initialization

RMSE_A(3) = model_errors(A_gt, A_ELMM_WS);

%% Extended Linear Mixing Model (Cold start)
disp("ELMM (Cold Start)")
tic
[A_ELMM_CS, S_ELMM_CS] = run_ELMM(X, E, width, height, ...
    'warm_start', false, 'verbose', false);
delta_t(4) = toc;

RMSE_A(4) = model_errors(A_gt, A_ELMM_CS);

%% 2LMM using two-scaling-factor approach (using IPOPT)
% run the file ipopt.jl to calculate 2LMM results from the main directory
% by executing the command
% ´´ julia Julia_scripts/ipopt.jl ´´
disp('2LMM')
clear A_2LMM
clear S_2LMM
load ipopt_results.mat

RMSE_A(5) = model_errors(A_gt, A_2LMM);
delta_t(5) = time_2LMM;
%% display table

X_LMM = reconstruct(E, A_LMM);
X_SLMM = reconstruct(E, A_SLMM);
X_ELMM_WS = reconstruct(E, A_ELMM_WS, S_ELMM_WS);
X_ELMM_CS = reconstruct(E, A_ELMM_CS, S_ELMM_CS);
X_2LMM_IP = reconstruct(E, A_2LMM, S_2LMM);

SAD_X(1) = image_error(X, X_LMM);
SAD_X(2) = image_error(X, X_SLMM);
SAD_X(3) = image_error(X, X_ELMM_WS);
SAD_X(4) = image_error(X, X_ELMM_CS);
SAD_X(5) = image_error(X, X_2LMM_IP);

RMSE_X(1) = image_error(X, X_LMM, 'rmse');
RMSE_X(2) = image_error(X, X_SLMM, 'rmse');
RMSE_X(3) = image_error(X, X_ELMM_WS, 'rmse');
RMSE_X(4) = image_error(X, X_ELMM_CS, 'rmse');
RMSE_X(5) = image_error(X, X_2LMM_IP, 'rmse');


T2 = table(RMSE_A, SAD_X, RMSE_X, delta_t, 'RowNames', {'FCLSU', 'SCLSU', 'ELMM_WS', 'ELMM_CS', '2LMM'});
disp(T2)

%% plot the abundance maps

figure;
tot = 6; % total number of rows
plot_abundance_map(A_gt, width, height, 'GT', 1, tot);
plot_abundance_map(A_LMM, width, height, 'LMM', 2, tot);
plot_abundance_map(A_SLMM, width, height, 'SLMM', 3, tot);
plot_abundance_map(A_ELMM_WS, width, height, 'WS-ELMM', 4, tot);
plot_abundance_map(A_ELMM_CS, width, height, 'CS-ELMM', 5, tot);
plot_abundance_map(A_2LMM, width, height, '2LMM', 6, tot);


for i=1:6
    subplot(tot,6,i)
    title(materials{i})
end

%% plot scaling factors
% 
tot = 4;
max_S = max([S_SLMM(:); S_ELMM_WS(:); S_ELMM_CS(:); S_2LMM(:)]);
figure;

% the function plots a histogram and boxplot of scaling factors and gives
% an idea about the distributions of scaling factors

plot_scaling_factors(S_SLMM, 20, "SLMM", max_S, 1, tot);
plot_scaling_factors(S_ELMM_WS, 20, "ELMM (WS)", max_S, 2, tot);
plot_scaling_factors(S_ELMM_CS, 20, "ELMM (CS)", max_S, 3, tot);
plot_scaling_factors(S_2LMM, 20, "2LMM", max_S, 4, tot);