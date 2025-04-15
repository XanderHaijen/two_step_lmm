%% Comaprison of different unmixing models on a fully synthetic dataset
close all
clear
rng default


%% set parameters
p = 224;
k = 3;
SNR = 1000;
type = 1;
width = 100; height = 100;
model = 'two-step';
smooth_S = false;
S_low = 0.5; S_high = 1.5; % scaling factors range
% in experiments, we use (0.5, 1.5) for low scaling variation and (0.1, 8) for high scaling variation
%% generate synthetic data

% GRF abundance maps
[X, A, S, E, param, err] = generateSyntheticImage(width, height, p, k, 'snr', SNR, 'model', model, 'smooth_S', smooth_S, 'S_low', S_low, 'S_high', S_high);

% save image to file
save('image_data.mat', 'X', 'E', 'S_low', 'S_high');


RMSE_X = zeros(5, 1);
SAD_X = zeros(5, 1);
RMSE_A = zeros(5, 1);
RMSE_S = zeros(5, 1);
Delta_t = zeros(5, 1);

%% Fully Constrained Least Squares Unmixing (FCLSU)

disp('FCLSU...')
tic
A_FCLSU = FCLSU(X,E);
Delta_t(1) = toc;

X_hat_FCLSU = reconstruct(E, A_FCLSU);

RMSE_X(1) = image_error(X, X_hat_FCLSU, 'rmse');
SAD_X(1) = image_error(X, X_hat_FCLSU, 'sam');
RMSE_A(1) = model_errors(A, A_FCLSU);
RMSE_S(1) = NaN; % no scaling factors in FCLSU


%% Scaled version of the (partially) Constrained Least Squares (SCLSU)

disp('CLSU...')

tic
[A_SCLSU, S_SCLSU] = SCLSU(X, E);
Delta_t(2) = toc;

X_hat_SCLSU = reconstruct(E, A_SCLSU, S_SCLSU);
RMSE_X(2) = image_error(X, X_hat_SCLSU, 'rmse');
SAD_X(2) = image_error(X, X_hat_SCLSU, 'sam');

if strcmp(model, 'two-step')
    S_SCLSU_ext = [ones(1, k) S_SCLSU]; % for 2LMM experiments
elseif strcmp(model, 'extended')
    S_SCLSU_ext = repmat(S_SCLSU, [k 1]); % for ELMM experiments
else
    err('Model not recognized. Should be two-step or extended')
end

[RMSE_A(2), RMSE_S(2)] = model_errors(A, A_SCLSU, S, S_SCLSU_ext);

%% Extended Linear Mixing Model, warm started

if strcmp(model, 'two-step')
    S_0_ELMM = zeros(k, width * height);
    for i=1:k
        S_0_ELMM(i, :) = S(i) * S(k+1:end);
    end
else % otherwise (when using ELMM data)
    S_0_ELMM = S;
end

disp('ELMM(WS)')
% provide the SCLSU abundances as initial guess
A_init = A_SCLSU;

tic
[A_ELMM_WS, S_ELMM_WS] = run_ELMM(X, E, width, height, ...
    'verbose', false, 'warm_start', false, 'A_init', A_init);
Delta_t(3) = toc;
Delta_t(3) = Delta_t(3) + Delta_t(2); % add the time for SCLSU initialization

X_hat_ELMM_WS = reconstruct(E, A_ELMM_WS, S_ELMM_WS);

RMSE_X(3) = image_error(X, X_hat_ELMM_WS, 'rmse');
SAD_X(3) = image_error(X, X_hat_ELMM_WS, 'sam');
[RMSE_A(3), RMSE_S(3)] = model_errors(A, A_ELMM_WS, S_0_ELMM, S_ELMM_WS);


%% Extended Linear Mixing Model, cold-started

disp('ELMM(CS)')
% provide no initial guess
tic
[A_ELMM_CS, S_ELMM_CS] = run_ELMM(X, E, width, height, ...
    'verbose', false, 'warm_start', false);
Delta_t(4) = toc;

X_hat_ELMM_CS = reconstruct(E, A_ELMM_CS, S_ELMM_CS);
RMSE_X(4) = image_error(X, X_hat_ELMM_CS, 'rmse');
SAD_X(4) = image_error(X, X_hat_ELMM_CS, 'sam');
[RMSE_A(4), RMSE_S(4)] = model_errors(A, A_ELMM_CS, S_0_ELMM, S_ELMM_CS);


%% 2LMM, two-scaling factor approach, using IPOPT

% run the file ipopt.jl to get the results

load ipopt_results.mat

disp('2LMM')

Delta_t(5) = time_2LMM;
X_hat_2LMM = reconstruct(E, A_2LMM, S_2LMM);
RMSE_X(5) = image_error(X, X_hat_2LMM, 'rmse');
SAD_X(5) = image_error(X, X_hat_2LMM, 'sam');

if  strcmp(model, 'two-step')
    S_2LMM_ext = S_2LMM; % for ELMM experiments
else % otherwise (when using ELMM data)
    S_2LMM_ext = zeros(k, width * height);
    for i=1:k
        S_2LMM_ext(i, :) = S_2LMM(i) * S_2LMM(k+1:end);
    end
end

[RMSE_A(5), RMSE_S(5)] = model_errors(A, A_2LMM, S, S_2LMM_ext);

%% display results
SAD_X = abs(SAD_X);
RMSE_S = abs(RMSE_S);
results = table(RMSE_X, SAD_X, RMSE_A, RMSE_S, Delta_t, 'RowNames', ...
    {'FCLSU', 'CLSU', 'ELMM(WS)', 'ELMM(CS)', '2LMM'})