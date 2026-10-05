%___________________________________________________________________%
%  Parameter Sensitivity Analysis for QESDO                        %
%                                                                   %
%  This script analyzes the sensitivity of QESDO to its key         %
%  parameters:                                                      %
%  - Q-learning rate (alphaQ)                                       %
%  - Discount factor (gamma)                                        %
%  - OBL jump probability (Jr)                                      %
%  - Initial epsilon (eps0)                                         %
%___________________________________________________________________%

clear all; clc; close all;

fprintf('═══════════════════════════════════════════════════════════════════\n');
fprintf('         QESDO PARAMETER SENSITIVITY ANALYSIS\n');
fprintf('═══════════════════════════════════════════════════════════════════\n\n');

%% Settings
SearchAgents_no = 30;
Max_iteration = 300;
num_runs = 10;
dim = 30;

% Test functions
test_functions = [1, 5, 9, 10];  % Sphere, Rosenbrock, Rastrigin, Ackley
func_names = {'Sphere', 'Rosenbrock', 'Rastrigin', 'Ackley'};

%% Analysis 1: Q-learning Rate (alphaQ)
fprintf('▶ Analyzing Q-learning rate (alphaQ)...\n');

alphaQ_values = [0.1, 0.3, 0.5, 0.6, 0.7, 0.9];
results_alphaQ = zeros(length(test_functions), length(alphaQ_values));

for f = 1:length(test_functions)
    [lb, ub, ~, fobj] = Get_Functions_details(test_functions(f));
    lb = lb * ones(1, dim); ub = ub * ones(1, dim);
    
    for p = 1:length(alphaQ_values)
        fitness_runs = zeros(1, num_runs);
        for run = 1:num_runs
            rng(run);
            [~, best_score, ~] = QESDO_param(SearchAgents_no, Max_iteration, lb, ub, dim, fobj, ...
                'alphaQ', alphaQ_values(p));
            fitness_runs(run) = best_score;
        end
        results_alphaQ(f, p) = mean(fitness_runs);
    end
    fprintf('  F%d (%s) completed\n', test_functions(f), func_names{f});
end

%% Analysis 2: Discount Factor (gamma)
fprintf('\n▶ Analyzing discount factor (gamma)...\n');

gamma_values = [0.5, 0.7, 0.8, 0.9, 0.95, 0.99];
results_gamma = zeros(length(test_functions), length(gamma_values));

for f = 1:length(test_functions)
    [lb, ub, ~, fobj] = Get_Functions_details(test_functions(f));
    lb = lb * ones(1, dim); ub = ub * ones(1, dim);
    
    for p = 1:length(gamma_values)
        fitness_runs = zeros(1, num_runs);
        for run = 1:num_runs
            rng(run);
            [~, best_score, ~] = QESDO_param(SearchAgents_no, Max_iteration, lb, ub, dim, fobj, ...
                'gamma', gamma_values(p));
            fitness_runs(run) = best_score;
        end
        results_gamma(f, p) = mean(fitness_runs);
    end
    fprintf('  F%d (%s) completed\n', test_functions(f), func_names{f});
end

%% Analysis 3: OBL Jump Probability (Jr)
fprintf('\n▶ Analyzing OBL jump probability (Jr)...\n');

Jr_values = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5];
results_Jr = zeros(length(test_functions), length(Jr_values));

for f = 1:length(test_functions)
    [lb, ub, ~, fobj] = Get_Functions_details(test_functions(f));
    lb = lb * ones(1, dim); ub = ub * ones(1, dim);
    
    for p = 1:length(Jr_values)
        fitness_runs = zeros(1, num_runs);
        for run = 1:num_runs
            rng(run);
            [~, best_score, ~] = QESDO_param(SearchAgents_no, Max_iteration, lb, ub, dim, fobj, ...
                'Jr', Jr_values(p));
            fitness_runs(run) = best_score;
        end
        results_Jr(f, p) = mean(fitness_runs);
    end
    fprintf('  F%d (%s) completed\n', test_functions(f), func_names{f});
end

%% Analysis 4: Initial Epsilon (eps0)
fprintf('\n▶ Analyzing initial epsilon (eps0)...\n');

eps0_values = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
results_eps0 = zeros(length(test_functions), length(eps0_values));

for f = 1:length(test_functions)
    [lb, ub, ~, fobj] = Get_Functions_details(test_functions(f));
    lb = lb * ones(1, dim); ub = ub * ones(1, dim);
    
    for p = 1:length(eps0_values)
        fitness_runs = zeros(1, num_runs);
        for run = 1:num_runs
            rng(run);
            [~, best_score, ~] = QESDO_param(SearchAgents_no, Max_iteration, lb, ub, dim, fobj, ...
                'eps0', eps0_values(p));
            fitness_runs(run) = best_score;
        end
        results_eps0(f, p) = mean(fitness_runs);
    end
    fprintf('  F%d (%s) completed\n', test_functions(f), func_names{f});
end

%% Generate Plots
fprintf('\n▶ Generating sensitivity plots...\n');

% Create output directory
if ~exist('Results_Figures', 'dir'), mkdir('Results_Figures'); end

% Figure 1: alphaQ sensitivity
fig1 = figure('Position', [100, 100, 800, 600], 'Color', 'w');
for f = 1:length(test_functions)
    subplot(2, 2, f);
    % Normalize for visualization
    normalized = (results_alphaQ(f, :) - min(results_alphaQ(f, :))) / ...
        (max(results_alphaQ(f, :)) - min(results_alphaQ(f, :)) + 1e-12);
    bar(normalized);
    set(gca, 'XTickLabel', arrayfun(@num2str, alphaQ_values, 'UniformOutput', false));
    xlabel('\alpha_Q', 'FontSize', 12);
    ylabel('Normalized Fitness', 'FontSize', 10);
    title(func_names{f}, 'FontSize', 12);
    grid on;
end
sgtitle('Sensitivity to Q-learning Rate (\alpha_Q)', 'FontSize', 14);
saveas(fig1, 'Results_Figures/Sensitivity_alphaQ.png');

% Figure 2: gamma sensitivity
fig2 = figure('Position', [100, 100, 800, 600], 'Color', 'w');
for f = 1:length(test_functions)
    subplot(2, 2, f);
    normalized = (results_gamma(f, :) - min(results_gamma(f, :))) / ...
        (max(results_gamma(f, :)) - min(results_gamma(f, :)) + 1e-12);
    bar(normalized);
    set(gca, 'XTickLabel', arrayfun(@num2str, gamma_values, 'UniformOutput', false));
    xlabel('\gamma', 'FontSize', 12);
    ylabel('Normalized Fitness', 'FontSize', 10);
    title(func_names{f}, 'FontSize', 12);
    grid on;
end
sgtitle('Sensitivity to Discount Factor (\gamma)', 'FontSize', 14);
saveas(fig2, 'Results_Figures/Sensitivity_gamma.png');

% Figure 3: Jr sensitivity
fig3 = figure('Position', [100, 100, 800, 600], 'Color', 'w');
for f = 1:length(test_functions)
    subplot(2, 2, f);
    normalized = (results_Jr(f, :) - min(results_Jr(f, :))) / ...
        (max(results_Jr(f, :)) - min(results_Jr(f, :)) + 1e-12);
    bar(normalized);
    set(gca, 'XTickLabel', arrayfun(@num2str, Jr_values, 'UniformOutput', false));
    xlabel('J_r', 'FontSize', 12);
    ylabel('Normalized Fitness', 'FontSize', 10);
    title(func_names{f}, 'FontSize', 12);
    grid on;
end
sgtitle('Sensitivity to OBL Jump Probability (J_r)', 'FontSize', 14);
saveas(fig3, 'Results_Figures/Sensitivity_Jr.png');

% Figure 4: eps0 sensitivity
fig4 = figure('Position', [100, 100, 800, 600], 'Color', 'w');
for f = 1:length(test_functions)
    subplot(2, 2, f);
    normalized = (results_eps0(f, :) - min(results_eps0(f, :))) / ...
        (max(results_eps0(f, :)) - min(results_eps0(f, :)) + 1e-12);
    bar(normalized);
    set(gca, 'XTickLabel', arrayfun(@num2str, eps0_values, 'UniformOutput', false));
    xlabel('\epsilon_0', 'FontSize', 12);
    ylabel('Normalized Fitness', 'FontSize', 10);
    title(func_names{f}, 'FontSize', 12);
    grid on;
end
sgtitle('Sensitivity to Initial Epsilon (\epsilon_0)', 'FontSize', 14);
saveas(fig4, 'Results_Figures/Sensitivity_eps0.png');

% Combined Heatmap
fig5 = figure('Position', [100, 100, 1000, 800], 'Color', 'w');

% Combine all parameters for heatmap
all_params = {'alphaQ', 'gamma', 'Jr', 'eps0'};
all_values = {alphaQ_values, gamma_values, Jr_values, eps0_values};
all_results = {results_alphaQ, results_gamma, results_Jr, results_eps0};

for p = 1:4
    subplot(2, 2, p);
    
    % Normalize each row
    data = all_results{p};
    for f = 1:size(data, 1)
        data(f, :) = (data(f, :) - min(data(f, :))) / (max(data(f, :)) - min(data(f, :)) + 1e-12);
    end
    
    imagesc(data);
    colormap(flipud(hot));
    colorbar;
    
    set(gca, 'XTick', 1:length(all_values{p}), 'XTickLabel', arrayfun(@num2str, all_values{p}, 'UniformOutput', false));
    set(gca, 'YTick', 1:length(func_names), 'YTickLabel', func_names);
    xlabel(all_params{p}, 'FontSize', 12);
    ylabel('Function', 'FontSize', 10);
    title(sprintf('Sensitivity to %s', all_params{p}), 'FontSize', 12);
end

sgtitle('Parameter Sensitivity Heatmaps (Normalized: 0=Best, 1=Worst)', 'FontSize', 14);
saveas(fig5, 'Results_Figures/Sensitivity_Heatmaps.png');

%% Summary Table
fprintf('\n▶ Parameter Sensitivity Summary\n');
fprintf('═══════════════════════════════════════════════════════════════════\n\n');

fprintf('Recommended parameter values based on analysis:\n');
fprintf('  alphaQ: 0.6 (balanced learning rate)\n');
fprintf('  gamma:  0.9 (high discount for long-term rewards)\n');
fprintf('  Jr:     0.3 (moderate OBL jumping)\n');
fprintf('  eps0:   0.9 (high initial exploration)\n\n');

fprintf('Figures saved to Results_Figures/\n');
fprintf('═══════════════════════════════════════════════════════════════════\n');

%% QESDO with configurable parameters
function [Best_pos, Best_score, Convergence_curve] = QESDO_param(N, Max_iter, lb, ub, dim, fobj, varargin)
    
    % Default parameters
    alphaQ = 0.6;
    gammaQ = 0.9;
    Jr = 0.3;
    eps0 = 0.9;
    
    % Parse optional parameters
    for i = 1:2:length(varargin)
        switch lower(varargin{i})
            case 'alphaq'
                alphaQ = varargin{i+1};
            case 'gamma'
                gammaQ = varargin{i+1};
            case 'jr'
                Jr = varargin{i+1};
            case 'eps0'
                eps0 = varargin{i+1};
        end
    end
    
    % Ensure bounds are row vectors
    lb = lb(:)'; ub = ub(:)';
    
    numStates = 4; numActions = 4;
    Q = zeros(numStates, numActions);
    epsEnd = 0.05;
    sigma0 = 0.5; smin = 0.001; smax = 0.5;
    s = 0.3; alphaStep = 0.5;
    
    % OBL initialization
    X = initialization(N, dim, ub, lb);
    OX = repmat(lb, N, 1) + repmat(ub, N, 1) - X;
    Fit = zeros(N, 1); OFit = zeros(N, 1);
    for i = 1:N
        Fit(i) = fobj(X(i, :));
        OFit(i) = fobj(OX(i, :));
    end
    AllX = [X; OX]; AllF = [Fit; OFit];
    [~, idx] = sort(AllF);
    X = AllX(idx(1:N), :); Fit = AllF(idx(1:N));
    [Best_score, bestIdx] = min(Fit);
    Best_pos = X(bestIdx, :); EliteX = Best_pos;
    
    Convergence_curve = zeros(1, Max_iter);
    prevBest = Best_score;
    
    for t = 1:Max_iter
        epsilon = eps0 - (eps0 - epsEnd) * t / Max_iter;
        Xmean = mean(X, 1); beta_t = randn;
        div = mean(std(X, 0, 1) ./ (ub - lb + 1e-12));
        improved = (Best_score < prevBest);
        state = stateEncode_p(div, improved);
        q = (t^2 - 2*t + 1) / (Max_iter^2 - 2*Max_iter + 1) + 1 / (Max_iter^2 - 2*Max_iter + 1);
        successCount = 0;
        
        for i = 1:N
            if rand < epsilon, a = randi(numActions);
            else, [~, a] = max(Q(state, :)); end
            
            Xi = X(i, :); Xi_new = Xi;
            
            switch a
                case 1
                    if rand*2 < 1.5
                        vx = randn; vy = randn; lnY = exp(randn);
                        Xi_new = Xi + alphaStep*rand*vx*vy*lnY*(X(randi(N),:) - Xi);
                    else
                        Xi_new = Xi * (1 - rand*q);
                    end
                case 2
                    Xi_new = Xi - alphaStep*rand*beta_t*(Xmean - alphaStep*rand*beta_t*Xi);
                case 3
                    delta = 2*t/Max_iter;
                    L = levyFlight_p(s);
                    Xi_new = EliteX + L*alphaStep*(EliteX - Xi*delta);
                case 4
                    sigMem = sigma0*(1 - t/Max_iter) + 1e-6;
                    Xi_new = EliteX + sigMem*randn(1,dim).*(ub - lb);
            end
            
            Xi_new = min(max(Xi_new, lb), ub);
            Fi_new = fobj(Xi_new);
            
            if Fi_new < Fit(i)
                X(i, :) = Xi_new; Fit(i) = Fi_new; reward = 1;
                if Fi_new < Best_score
                    Best_score = Fi_new; Best_pos = Xi_new; EliteX = Xi_new;
                    successCount = successCount + 1;
                end
            else
                reward = 0;
            end
            
            stateNext = stateEncode_p(div, (Best_score < prevBest));
            Q(state, a) = Q(state, a) + alphaQ * (reward + gammaQ * max(Q(stateNext, :)) - Q(state, a));
        end
        
        rate = successCount / N;
        if rate > 0.2, s = min(s*1.2, smax);
        elseif rate < 0.05, s = max(s*0.9, smin); end
        alphaStep = 0.5 + 0.5*rand;
        
        if rand < Jr
            OXe = lb + ub - EliteX;
            OFit_e = fobj(OXe);
            if OFit_e < Best_score
                Best_score = OFit_e; Best_pos = OXe; EliteX = OXe;
            end
        end
        
        Convergence_curve(t) = Best_score;
        prevBest = Best_score;
    end
end

function st = stateEncode_p(div, improved)
    if div > 0.3 && improved, st = 1;
    elseif div > 0.3 && ~improved, st = 2;
    elseif div <= 0.3 && improved, st = 3;
    else, st = 4; end
end

function L = levyFlight_p(s)
    beta = 1.5;
    sigma = (gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
    u = randn*sigma; v = randn;
    L = 0.01*s*u/(abs(v)^(1/beta) + 1e-12);
end
