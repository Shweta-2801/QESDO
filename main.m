%___________________________________________________________________%
%  QESDO: Q-learning Enhanced Self-adaptive Dandelion Optimizer    %
%                                                                   %
%  Developed in MATLAB R2023a                                       %
%                                                                   %
%  Main Paper:                                                      %
%  QESDO: A Q-learning-driven Self-adaptive Hybrid of the           %
%  Dandelion Optimizer with Opposition-based Learning and           %
%  Memetic Local Search for Global Optimization                     %
%                                                                   %
%  Comparable Algorithms:                                           %
%  DO, GWO, PSO, DE, GA                                             %
%                                                                   %
%  Statistical Tests: Friedman Test, Wilcoxon Signed-Rank Test      %
%  Graphical Analysis: Convergence Curves, Box Plots                %
%___________________________________________________________________%

clear all; clc; close all;

%% ==================== EXPERIMENTAL SETTINGS ====================
SearchAgents_no = 50;       % Population size
Max_iteration = 500;        % Maximum iterations
num_runs = 30;              % Number of independent runs
Function_IDs = 1:23;        % Benchmark functions to test (F1-F10)
Dimensions = [50];          % Problem dimensions to test

% Algorithm names
Algorithm_Names = {'QESDO', 'DO', 'GWO', 'PSO', 'DE', 'GA'};
num_algorithms = length(Algorithm_Names);

%% ==================== INITIALIZATION ====================
% Preallocate results storage
num_functions = length(Function_IDs);
num_dims = length(Dimensions);

% Results matrices
Results_Best = zeros(num_functions, num_algorithms, num_dims);
Results_Mean = zeros(num_functions, num_algorithms, num_dims);
Results_Std = zeros(num_functions, num_algorithms, num_dims);
Results_Worst = zeros(num_functions, num_algorithms, num_dims);
Results_Median = zeros(num_functions, num_algorithms, num_dims);

% Store all fitness values for statistical tests and box plots
All_Fitness = cell(num_functions, num_algorithms, num_dims);

% Store convergence curves
Convergence_Curves = cell(num_functions, num_algorithms, num_dims);

%% ==================== MAIN EXPERIMENTAL LOOP ====================
fprintf('=================================================================\n');
fprintf('  QESDO: Q-learning Enhanced Self-adaptive Dandelion Optimizer\n');
fprintf('  Experimental Comparison Study\n');
fprintf('=================================================================\n\n');

for dim_idx = 1:num_dims
    dim = Dimensions(dim_idx);
    fprintf('>>> Testing Dimension: D = %d\n', dim);
    fprintf('-----------------------------------------------------------------\n');
    
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
        
        fprintf('\n  Function F%d (D=%d):\n', Function_ID, actual_dim);
        
        % Test each algorithm
        for alg_idx = 1:num_algorithms
            alg_name = Algorithm_Names{alg_idx};
            
            % Storage for this algorithm's runs
            fitness_runs = zeros(1, num_runs);
            convergence_runs = zeros(num_runs, Max_iteration);
            
            fprintf('    Running %s... ', alg_name);
            
            tic;
            for run = 1:num_runs
                % Set random seed for reproducibility (optional)
                rng(run);
                
                % Run the selected algorithm
                switch alg_name
                    case 'QESDO'
                        [~, Best_score, Convergence_curve] = QESDO(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'DO'
                        [~, Best_score, Convergence_curve] = DO(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'GWO'
                        [~, Best_score, Convergence_curve] = GWO(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'PSO'
                        [~, Best_score, Convergence_curve] = PSO(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'DE'
                        [~, Best_score, Convergence_curve] = DE(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                    case 'GA'
                        [~, Best_score, Convergence_curve] = GA(SearchAgents_no, Max_iteration, lb, ub, actual_dim, fobj);
                end
                
                fitness_runs(run) = Best_score;
                convergence_runs(run, :) = Convergence_curve;
            end
            elapsed_time = toc;
            
            % Store results
            All_Fitness{func_idx, alg_idx, dim_idx} = fitness_runs;
            Convergence_Curves{func_idx, alg_idx, dim_idx} = mean(convergence_runs, 1);
            
            Results_Best(func_idx, alg_idx, dim_idx) = min(fitness_runs);
            Results_Mean(func_idx, alg_idx, dim_idx) = mean(fitness_runs);
            Results_Std(func_idx, alg_idx, dim_idx) = std(fitness_runs);
            Results_Worst(func_idx, alg_idx, dim_idx) = max(fitness_runs);
            Results_Median(func_idx, alg_idx, dim_idx) = median(fitness_runs);
            
            fprintf('Done (%.2fs) | Best: %.4e | Mean: %.4e | Std: %.4e\n', ...
                elapsed_time, min(fitness_runs), mean(fitness_runs), std(fitness_runs));
        end
    end
end

%% ==================== SAVE RESULTS ====================
save('QESDO_Results.mat', 'Results_Best', 'Results_Mean', 'Results_Std', ...
    'Results_Worst', 'Results_Median', 'All_Fitness', 'Convergence_Curves', ...
    'Algorithm_Names', 'Function_IDs', 'Dimensions', 'num_runs');

%% ==================== SAVE TO EXCEL ====================
fprintf('\n\n=================================================================\n');
fprintf('  SAVING RESULTS TO EXCEL\n');
fprintf('=================================================================\n');

SaveResultsToExcel(Results_Best, Results_Mean, Results_Std, Results_Worst, Results_Median, ...
    All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== SAVE INDIVIDUAL CONVERGENCE CURVES ====================
fprintf('\n=================================================================\n');
fprintf('  SAVING INDIVIDUAL CONVERGENCE CURVES\n');
fprintf('=================================================================\n');

SaveConvergenceCurves(Convergence_Curves, Algorithm_Names, Function_IDs, Dimensions, Max_iteration);

%% ==================== SAVE INDIVIDUAL BOX PLOTS ====================
fprintf('\n=================================================================\n');
fprintf('  SAVING INDIVIDUAL BOX PLOTS\n');
fprintf('=================================================================\n');

SaveBoxPlots(All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== SAVE RANKING IMAGES ====================
fprintf('\n=================================================================\n');
fprintf('  SAVING RANKING IMAGES\n');
fprintf('=================================================================\n');

SaveRankingImages(Results_Mean, All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== STATISTICAL ANALYSIS ====================
fprintf('\n\n=================================================================\n');
fprintf('  STATISTICAL ANALYSIS\n');
fprintf('=================================================================\n');

% Perform Friedman and Wilcoxon tests
[Friedman_Results, Wilcoxon_Results] = StatisticalTests(All_Fitness, Algorithm_Names, Function_IDs, Dimensions);

%% ==================== GRAPHICAL ANALYSIS ====================
fprintf('\n\n=================================================================\n');
fprintf('  GENERATING PLOTS\n');
fprintf('=================================================================\n');

% Generate convergence curves and box plots
PlotResults(Convergence_Curves, All_Fitness, Algorithm_Names, Function_IDs, Dimensions, Max_iteration);

%% ==================== DISPLAY RESULTS TABLE ====================
fprintf('\n\n=================================================================\n');
fprintf('  NUMERICAL RESULTS TABLE\n');
fprintf('=================================================================\n');

for dim_idx = 1:num_dims
    dim = Dimensions(dim_idx);
    fprintf('\n>>> Dimension D = %d\n', dim);
    fprintf('%-10s', 'Function');
    for alg_idx = 1:num_algorithms
        fprintf('%-20s', Algorithm_Names{alg_idx});
    end
    fprintf('\n');
    fprintf('%s\n', repmat('-', 1, 10 + 20*num_algorithms));
    
    for func_idx = 1:num_functions
        fprintf('F%-9d', Function_IDs(func_idx));
        for alg_idx = 1:num_algorithms
            fprintf('%.4e(%.2e) ', Results_Mean(func_idx, alg_idx, dim_idx), ...
                Results_Std(func_idx, alg_idx, dim_idx));
        end
        fprintf('\n');
    end
end

%% ==================== RANKING SUMMARY ====================
fprintf('\n\n=================================================================\n');
fprintf('  ALGORITHM RANKINGS (Based on Mean Fitness)\n');
fprintf('=================================================================\n');

for dim_idx = 1:num_dims
    fprintf('\n>>> Dimension D = %d\n', Dimensions(dim_idx));
    
    Rankings = zeros(num_functions, num_algorithms);
    for func_idx = 1:num_functions
        [~, sorted_idx] = sort(Results_Mean(func_idx, :, dim_idx));
        for rank = 1:num_algorithms
            Rankings(func_idx, sorted_idx(rank)) = rank;
        end
    end
    
    Avg_Rank = mean(Rankings, 1);
    [sorted_rank, sorted_alg] = sort(Avg_Rank);
    
    fprintf('%-15s %-15s\n', 'Algorithm', 'Average Rank');
    fprintf('%s\n', repmat('-', 1, 30));
    for i = 1:num_algorithms
        fprintf('%-15s %.4f\n', Algorithm_Names{sorted_alg(i)}, sorted_rank(i));
    end
end

fprintf('\n=================================================================\n');
fprintf('  EXPERIMENTS COMPLETED SUCCESSFULLY!\n');
fprintf('=================================================================\n');
fprintf('  Output Files:\n');
fprintf('    - QESDO_Results.mat          (MATLAB data)\n');
fprintf('    - Results_Excel/             (Excel files)\n');
fprintf('    - Results_Convergence/       (Individual convergence curves)\n');
fprintf('    - Results_BoxPlots/          (Individual box plots)\n');
fprintf('    - Results_Rankings/          (Ranking visualizations)\n');
fprintf('    - Results_Figures/           (Combined figures)\n');
fprintf('    - Results_Tables/            (LaTeX tables)\n');
fprintf('=================================================================\n');
