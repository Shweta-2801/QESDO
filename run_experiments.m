%___________________________________________________________________%
%  QESDO: Complete Experimental Comparison Suite                   %
%                                                                   %
%  This script runs comprehensive experiments comparing QESDO      %
%  against multiple state-of-the-art algorithms with:              %
%  - Multiple benchmark functions (F1-F13)                          %
%  - Multiple dimensions (D = 10, 30, 50)                           %
%  - Statistical tests (Friedman, Wilcoxon with Holm correction)    %
%  - Graphical analysis (Convergence curves, Box plots)             %
%  - LaTeX table export                                             %
%___________________________________________________________________%

clear all; clc; close all;

%% ==================== EXPERIMENTAL SETTINGS ====================
fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
fprintf('║  QESDO: Q-learning Enhanced Self-adaptive Dandelion Optimizer    ║\n');
fprintf('║  Comprehensive Experimental Comparison Suite                     ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');

% Population and iteration settings
SearchAgents_no = 50;       % Population size
Max_iteration = 500;        % Maximum iterations
num_runs = 30;              % Number of independent runs

% Test functions to evaluate
Function_IDs = 1:13;        % F1-F13 (unimodal + multimodal)

% Dimensions to test
Dimensions = [10, 30, 50];  % Multiple dimensions for scalability analysis

% Algorithm names (QESDO must be first for statistical comparison)
Algorithm_Names = {'QESDO', 'DO', 'GWO', 'PSO', 'DE', 'GA'};
num_algorithms = length(Algorithm_Names);

fprintf('Experimental Settings:\n');
fprintf('  Population Size: %d\n', SearchAgents_no);
fprintf('  Max Iterations: %d\n', Max_iteration);
fprintf('  Independent Runs: %d\n', num_runs);
fprintf('  Functions: F%d - F%d (%d functions)\n', Function_IDs(1), Function_IDs(end), length(Function_IDs));
fprintf('  Dimensions: %s\n', mat2str(Dimensions));
fprintf('  Algorithms: %s\n\n', strjoin(Algorithm_Names, ', '));

% Create output directories
if ~exist('Results_Figures', 'dir'), mkdir('Results_Figures'); end
if ~exist('Results_Tables', 'dir'), mkdir('Results_Tables'); end

%% ==================== INITIALIZATION ====================
num_functions = length(Function_IDs);
num_dims = length(Dimensions);

% Results matrices
Results_Best = zeros(num_functions, num_algorithms, num_dims);
Results_Mean = zeros(num_functions, num_algorithms, num_dims);
Results_Std = zeros(num_functions, num_algorithms, num_dims);
Results_Worst = zeros(num_functions, num_algorithms, num_dims);
Results_Median = zeros(num_functions, num_algorithms, num_dims);

% Store all fitness values
All_Fitness = cell(num_functions, num_algorithms, num_dims);

% Store convergence curves
Convergence_Curves = cell(num_functions, num_algorithms, num_dims);

% Timer
total_start = tic;

%% ==================== MAIN EXPERIMENTAL LOOP ====================
for dim_idx = 1:num_dims
    dim = Dimensions(dim_idx);
    
    fprintf('═══════════════════════════════════════════════════════════════════\n');
    fprintf('                    DIMENSION D = %d\n', dim);
    fprintf('═══════════════════════════════════════════════════════════════════\n\n');
    
    for func_idx = 1:num_functions
        Function_ID = Function_IDs(func_idx);
        
        % Get function details
        [lb, ub, D, fobj] = Get_Functions_details(Function_ID);
        
        % F14-F23 are fixed-dimension functions, use their original dimension
        if Function_ID >= 14
            % Use original dimension from function
            if isscalar(lb)
                lb = lb * ones(1, D);
                ub = ub * ones(1, D);
            end
            % lb and ub may already be vectors for some functions (e.g., F17)
            actual_dim = D;
        else
            % Scalable functions F1-F13: override dimension
            if isscalar(lb)
                lb = lb * ones(1, dim);
                ub = ub * ones(1, dim);
            end
            D = dim;
            actual_dim = dim;
        end
        
        fprintf('Function F%d (D=%d):\n', Function_ID, actual_dim);
        
        % Test each algorithm
        for alg_idx = 1:num_algorithms
            alg_name = Algorithm_Names{alg_idx};
            
            % Storage for runs
            fitness_runs = zeros(1, num_runs);
            convergence_runs = zeros(num_runs, Max_iteration);
            
            fprintf('  %-8s: ', alg_name);
            
            run_start = tic;
            for run = 1:num_runs
                % Set random seed for reproducibility
                rng(run);
                
                % Run algorithm
                switch alg_name
                    case 'QESDO'
                        [~, Best_score, Curve] = QESDO(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'DO'
                        [~, Best_score, Curve] = DO(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'GWO'
                        [~, Best_score, Curve] = GWO(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'PSO'
                        [~, Best_score, Curve] = PSO(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'DE'
                        [~, Best_score, Curve] = DE(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'GA'
                        [~, Best_score, Curve] = GA(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                end
                
                fitness_runs(run) = Best_score;
                convergence_runs(run, :) = Curve;
                
                % Progress indicator
                if mod(run, 10) == 0
                    fprintf('.');
                end
            end
            run_time = toc(run_start);
            
            % Store results
            All_Fitness{func_idx, alg_idx, dim_idx} = fitness_runs;
            Convergence_Curves{func_idx, alg_idx, dim_idx} = mean(convergence_runs, 1);
            
            Results_Best(func_idx, alg_idx, dim_idx) = min(fitness_runs);
            Results_Mean(func_idx, alg_idx, dim_idx) = mean(fitness_runs);
            Results_Std(func_idx, alg_idx, dim_idx) = std(fitness_runs);
            Results_Worst(func_idx, alg_idx, dim_idx) = max(fitness_runs);
            Results_Median(func_idx, alg_idx, dim_idx) = median(fitness_runs);
            
            fprintf(' Mean: %.4e ± %.2e (%.1fs)\n', ...
                mean(fitness_runs), std(fitness_runs), run_time);
        end
        fprintf('\n');
    end
end

total_time = toc(total_start);
fprintf('\nTotal experimental time: %.2f minutes\n\n', total_time/60);

%% ==================== SAVE RESULTS ====================
fprintf('Saving results...\n');
save('QESDO_Results.mat', 'Results_Best', 'Results_Mean', 'Results_Std', ...
    'Results_Worst', 'Results_Median', 'All_Fitness', 'Convergence_Curves', ...
    'Algorithm_Names', 'Function_IDs', 'Dimensions', 'num_runs', ...
    'SearchAgents_no', 'Max_iteration');
fprintf('  Results saved to: QESDO_Results.mat\n\n');

%% ==================== SAVE TO EXCEL ====================
fprintf('Saving results to Excel...\n');
SaveResultsToExcel(Results_Best, Results_Mean, Results_Std, Results_Worst, Results_Median, ...
    All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== SAVE INDIVIDUAL CONVERGENCE CURVES ====================
fprintf('Saving individual convergence curves...\n');
SaveConvergenceCurves(Convergence_Curves, Algorithm_Names, Function_IDs, Dimensions, Max_iteration);

%% ==================== SAVE INDIVIDUAL BOX PLOTS ====================
fprintf('Saving individual box plots...\n');
SaveBoxPlots(All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== SAVE RANKING IMAGES ====================
fprintf('Saving ranking images...\n');
SaveRankingImages(Results_Mean, All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== STATISTICAL ANALYSIS ====================
fprintf('Performing statistical analysis...\n\n');

% Basic statistical tests
[Friedman_Results, Wilcoxon_Results] = StatisticalTests(All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

% Advanced statistical analysis
AdvancedStatistics(All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== GRAPHICAL ANALYSIS ====================
fprintf('\nGenerating plots...\n');
PlotResults(Convergence_Curves, All_Fitness, Algorithm_Names, Function_IDs, Dimensions, Max_iteration);

%% ==================== EXPORT TO LATEX ====================
fprintf('\nExporting to LaTeX...\n');
ExportResultsToLatex(Results_Mean, Results_Std, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== FINAL RESULTS TABLE ====================
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
fprintf('║                    NUMERICAL RESULTS SUMMARY                     ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');

for dim_idx = 1:num_dims
    dim = Dimensions(dim_idx);
    fprintf('Dimension D = %d:\n', dim);
    fprintf('%s\n', repmat('-', 1, 80));
    
    % Print header
    fprintf('%-8s', 'Func');
    for alg_idx = 1:num_algorithms
        fprintf('%-12s', Algorithm_Names{alg_idx});
    end
    fprintf('\n');
    
    % Print results
    for func_idx = 1:num_functions
        fprintf('F%-7d', Function_IDs(func_idx));
        
        % Find best mean
        [best_mean, best_idx] = min(Results_Mean(func_idx, :, dim_idx));
        
        for alg_idx = 1:num_algorithms
            mean_val = Results_Mean(func_idx, alg_idx, dim_idx);
            if alg_idx == best_idx
                fprintf('*%.3e ', mean_val);
            else
                fprintf('%.4e ', mean_val);
            end
        end
        fprintf('\n');
    end
    fprintf('\n* indicates best result\n\n');
end

%% ==================== OVERALL RANKING ====================
fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
fprintf('║                    OVERALL ALGORITHM RANKINGS                    ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');

for dim_idx = 1:num_dims
    dim = Dimensions(dim_idx);
    fprintf('Dimension D = %d:\n', dim);
    
    Rankings = zeros(num_functions, num_algorithms);
    for func_idx = 1:num_functions
        [~, sorted_idx] = sort(Results_Mean(func_idx, :, dim_idx));
        for rank = 1:num_algorithms
            Rankings(func_idx, sorted_idx(rank)) = rank;
        end
    end
    
    Avg_Rank = mean(Rankings, 1);
    [sorted_rank, sorted_alg] = sort(Avg_Rank);
    
    fprintf('  %-5s %-15s %-15s\n', 'Rank', 'Algorithm', 'Average Rank');
    fprintf('  %s\n', repmat('-', 1, 35));
    for i = 1:num_algorithms
        fprintf('  %-5d %-15s %.4f\n', i, Algorithm_Names{sorted_alg(i)}, sorted_rank(i));
    end
    fprintf('\n');
end

%% ==================== COMPLETION ====================
fprintf('═══════════════════════════════════════════════════════════════════\n');
fprintf('                    EXPERIMENTS COMPLETED!\n');
fprintf('═══════════════════════════════════════════════════════════════════\n');
fprintf('\nOutput files:\n');
fprintf('  Data:    QESDO_Results.mat\n');
fprintf('  Figures: Results_Figures/*.png, *.fig\n');
fprintf('  Tables:  Results_Tables/*.tex, *.csv\n');
fprintf('\nTotal time: %.2f minutes\n', total_time/60);
fprintf('═══════════════════════════════════════════════════════════════════\n');
