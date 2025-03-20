%% load data

width = 105; height = 128; p = 144; k = 4;
load houston_data.mat

X = reshape(X_r, width * height, p); % p = number of spectral bands


materials{1} = 'vegetation'; % identify materials
materials{2} = 'red roofs';
materials{3} = 'concrete';
materials{4} = 'asphalt';

save("houston_image.mat", "E", "X")

SAD_X = zeros(5, 1);
timings = zeros(5, 1);

%% Fully Constrained Least Squares Unmixing (FCLSU)

disp('FCLSU...')
tic
A_FCLSU = FCLSU(X, E);
timings(1) = toc;

X_hat_LMM = reconstruct(E, A_FCLSU);
SAD_X(1) = image_error(X, X_hat_LMM, 'sam');

%% Scaled version of the (partially) Constrained Least Squares (SCLSU)

disp('SCLSU...')

tic
[A_CLSU, S_CLSU] = SCLSU(X, E);
timings(2) = toc;

X_hat_SLMM = reconstruct(E, A_CLSU, S_CLSU);
SAD_X(2) = image_error(X, X_hat_SLMM, 'sam');

%% Full Extended Linear Mixing Model, warm started

disp('ELMM(WS) ...')

% initialization with SCLSU

A_init = A_CLSU;

tic
[A_WS_ELMM, S_WS_ELMM] = run_ELMM(X, E, width, height, false, false, A_init);
timings(3) = toc;
timings(3) = timings(2) + timings(3); % include time of SCLSU initialization

X_hat_WS_ELMM = reconstruct(E, A_WS_ELMM, S_WS_ELMM);
SAD_X(3) = image_error(X, X_hat_WS_ELMM, 'sam');

%% Full Extended Linear Mixing Model, cold-started

disp('ELMM(CS) ...')

tic
[A_CS_ELMM, S_CS_ELMM] = run_ELMM(X, E, width, height, false, false);
timings(4) = toc;

X_hat_CS_ELMM = reconstruct(E, A_CS_ELMM, S_CS_ELMM);
SAD_X(4) = image_error(X, X_hat_CS_ELMM, 'sam');

%% 2LMM using Ipopt

load houston_ipopt.mat

timings(5) = time_2LMM;

X_hat_2LMM = reconstruct(E, A_2LMM, S_2LMM);
SAD_X(5) = image_error(X, X_hat_2LMM, 'sam');

%% display some results

% reconstruction errors (Spectral Angle Distance)

nb_tot = 5;

maximum = zeros(1, nb_tot);
minimum = zeros(1, nb_tot);
fig = figure;
tiledlayout(1, nb_tot); nexttile
[minimum(1), maximum(1)] = plot_reconstruction_error(X, X_hat_LMM, width, height, true, nb_tot, 1);
title("FCLSU"); nexttile
[minimum(2), maximum(2)] = plot_reconstruction_error(X, X_hat_SLMM, width, height, true, nb_tot, 2);
title("CLSU"); nexttile
[minimum(3), maximum(3)] = plot_reconstruction_error(X, X_hat_WS_ELMM, width, height, true, nb_tot, 3);
title("ELMM(WS)"); nexttile
[minimum(4), maximum(4)] = plot_reconstruction_error(X, X_hat_CS_ELMM, width, height, true, nb_tot, 4);
title("ELMM(CS)"); nexttile
[minimum(5), maximum(5)] = plot_reconstruction_error(X, X_hat_2LMM, width, height, true, nb_tot, 5);
title("2LMM");

maximum = max(maximum);
minimum = min(minimum);

h = axes(fig,'visible','off'); 
c = colorbar(h, 'Position',[0.93 0.168 0.022 0.7]);
clim(h, [minimum, maximum])
  

% abundance maps
figure;
plot_abundance_map(A_FCLSU, width, height, "FCLSU", 1, nb_tot);
plot_abundance_map(A_CLSU, width, height, "CLSU", 2, nb_tot);
plot_abundance_map(A_WS_ELMM, width, height, "ELMM(WS)", 3, nb_tot);
plot_abundance_map(A_CS_ELMM, width, height, "ELMM(CS)", 4, nb_tot);
plot_abundance_map(A_2LMM, width, height, "2LMM", 5, nb_tot);

for i=1:4
    subplot(nb_tot,4,i)
    title(materials{i})
end

%% plot the distribution of the scaling factors

max_S = max([vec(S_CLSU); vec(S_WS_ELMM); vec(S_CS_ELMM); vec(S_2LMM)]);
nb_tot = 4;

figure;
plot_scaling_factors(S_CLSU, 1000, "CLSU", max_S, 1, nb_tot)
plot_scaling_factors(S_WS_ELMM, 1000, "ELMM(WS)", max_S, 2, nb_tot)
plot_scaling_factors(S_CS_ELMM, 1000, "ELMM(CS)", max_S, 3, nb_tot)
plot_scaling_factors(S_2LMM, 1000, "2LMM", max_S, 4, nb_tot)

%% generate table with reconstruction errors and timings
error_X = zeros(5, 2);

error_X(1, 1) = image_error(X, X_hat_LMM);
error_X(1, 2) = image_error(X, X_hat_LMM, 'rmse');

error_X(2, 1) = image_error(X, X_hat_SLMM);
error_X(2, 2) = image_error(X, X_hat_SLMM, 'rmse');

error_X(3, 1) = image_error(X, X_hat_WS_ELMM);
error_X(3, 2) = image_error(X, X_hat_WS_ELMM, 'rmse');

error_X(4, 1) = image_error(X, X_hat_CS_ELMM);
error_X(4, 2) = image_error(X, X_hat_CS_ELMM, 'rmse');

error_X(5, 1) = image_error(X, X_hat_2LMM);
error_X(5, 2) = image_error(X, X_hat_2LMM, 'rmse');

T = table(error_X(:,1), error_X(:,2), timings, 'VariableNames', {'SAD', 'RMSE', 'Time'}, ...
    'RowNames', {'FCLSU', 'SCLSU', 'ELMM(WS)', 'ELMM(CS)', '2LMM'});
disp(T)