%___________________________________________________________________%
%  QESDO Demo Script                                               %
%                                                                   %
%  A quick demonstration of the QESDO algorithm on selected         %
%  benchmark functions. This script runs a minimal comparison       %
%  and generates sample plots.                                      %
%___________________________________________________________________%

clear all; clc; close all;

fprintf('=================================================================\n');
fprintf('  QESDO: Q-learning Enhanced Self-adaptive Dandelion Optimizer\n');
fprintf('  Quick Demonstration\n');
fprintf('=================================================================\n\n');

%% Settings
SearchAgents_no = 30;   % Population size
Max_iteration = 200;    % Maximum iterations
dim = 10;               % Problem dimension
num_runs = 5;           % Number of runs (reduced for demo)

%% Test on Sphere function (F1)
fprintf('Testing on Sphere function (F1)...\n');
[lb, ub, ~, fobj] = Get_Functions_details(1);
lb = lb * ones(1, dim);
ub = ub * ones(1, dim);

% Run QESDO
fprintf('  Running QESDO...\n');
tic;
[bestX_QESDO, bestF_QESDO, curve_QESDO] = QESDO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
time_QESDO = toc;
fprintf('    Best fitness: %.6e (Time: %.2fs)\n', bestF_QESDO, time_QESDO);

% Run DO
fprintf('  Running DO...\n');
tic;
[bestX_DO, bestF_DO, curve_DO] = DO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
time_DO = toc;
fprintf('    Best fitness: %.6e (Time: %.2fs)\n', bestF_DO, time_DO);

% Run GWO
fprintf('  Running GWO...\n');
tic;
[bestX_GWO, bestF_GWO, curve_GWO] = GWO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
time_GWO = toc;
fprintf('    Best fitness: %.6e (Time: %.2fs)\n', bestF_GWO, time_GWO);

% Run PSO
fprintf('  Running PSO...\n');
tic;
[bestX_PSO, bestF_PSO, curve_PSO] = PSO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
time_PSO = toc;
fprintf('    Best fitness: %.6e (Time: %.2fs)\n', bestF_PSO, time_PSO);

%% Plot convergence curves
fprintf('\nGenerating convergence plot...\n');

figure('Position', [100, 100, 700, 500], 'Color', 'w');
semilogy(curve_QESDO, 'b-', 'LineWidth', 2, 'DisplayName', 'QESDO');
hold on;
semilogy(curve_DO, 'r--', 'LineWidth', 2, 'DisplayName', 'DO');
semilogy(curve_GWO, 'g-.', 'LineWidth', 2, 'DisplayName', 'GWO');
semilogy(curve_PSO, 'm:', 'LineWidth', 2, 'DisplayName', 'PSO');
hold off;

xlabel('Iteration', 'FontSize', 14);
ylabel('Best Fitness (log scale)', 'FontSize', 14);
title(sprintf('Convergence Curve - Sphere Function (D=%d)', dim), 'FontSize', 14);
legend('Location', 'northeast', 'FontSize', 12);
grid on;
box on;

%% Test on Rastrigin function (F9)
fprintf('\nTesting on Rastrigin function (F9)...\n');
[lb, ub, ~, fobj] = Get_Functions_details(9);
lb = lb * ones(1, dim);
ub = ub * ones(1, dim);

% Run QESDO
fprintf('  Running QESDO...\n');
[~, bestF_QESDO_R, curve_QESDO_R] = QESDO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
fprintf('    Best fitness: %.6e\n', bestF_QESDO_R);

% Run DO
fprintf('  Running DO...\n');
[~, bestF_DO_R, curve_DO_R] = DO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
fprintf('    Best fitness: %.6e\n', bestF_DO_R);

% Run GWO
fprintf('  Running GWO...\n');
[~, bestF_GWO_R, curve_GWO_R] = GWO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
fprintf('    Best fitness: %.6e\n', bestF_GWO_R);

% Run PSO
fprintf('  Running PSO...\n');
[~, bestF_PSO_R, curve_PSO_R] = PSO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
fprintf('    Best fitness: %.6e\n', bestF_PSO_R);

%% Plot convergence curves for Rastrigin
figure('Position', [100, 100, 700, 500], 'Color', 'w');
semilogy(curve_QESDO_R, 'b-', 'LineWidth', 2, 'DisplayName', 'QESDO');
hold on;
semilogy(curve_DO_R, 'r--', 'LineWidth', 2, 'DisplayName', 'DO');
semilogy(curve_GWO_R, 'g-.', 'LineWidth', 2, 'DisplayName', 'GWO');
semilogy(curve_PSO_R, 'm:', 'LineWidth', 2, 'DisplayName', 'PSO');
hold off;

xlabel('Iteration', 'FontSize', 14);
ylabel('Best Fitness (log scale)', 'FontSize', 14);
title(sprintf('Convergence Curve - Rastrigin Function (D=%d)', dim), 'FontSize', 14);
legend('Location', 'northeast', 'FontSize', 12);
grid on;
box on;

%% Summary
fprintf('\n=================================================================\n');
fprintf('  DEMONSTRATION COMPLETED\n');
fprintf('=================================================================\n');
fprintf('\n  Summary:\n');
fprintf('  %-10s %-20s %-20s\n', 'Algorithm', 'Sphere (F1)', 'Rastrigin (F9)');
fprintf('  %s\n', repmat('-', 1, 50));
fprintf('  %-10s %.6e       %.6e\n', 'QESDO', bestF_QESDO, bestF_QESDO_R);
fprintf('  %-10s %.6e       %.6e\n', 'DO', bestF_DO, bestF_DO_R);
fprintf('  %-10s %.6e       %.6e\n', 'GWO', bestF_GWO, bestF_GWO_R);
fprintf('  %-10s %.6e       %.6e\n', 'PSO', bestF_PSO, bestF_PSO_R);
fprintf('\n');
fprintf('  For full experimental comparison, run main.m\n');
fprintf('=================================================================\n');
