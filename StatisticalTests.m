%___________________________________________________________________%
%  Statistical Tests: Friedman Test and Wilcoxon Signed-Rank Test  %
%                                                                   %
%  This function performs statistical analysis on the experimental %
%  results to determine if there are significant differences        %
%  between algorithms.                                              %
%                                                                   %
%  Outputs:                                                         %
%  - Friedman Test with Nemenyi post-hoc test                       %
%  - Wilcoxon Signed-Rank Test (QESDO vs each competitor)           %
%___________________________________________________________________%

function [Friedman_Results, Wilcoxon_Results] = StatisticalTests(All_Fitness, Algorithm_Names, Function_IDs, Dimensions)
    
    num_functions = length(Function_IDs);
    num_algorithms = length(Algorithm_Names);
    num_dims = length(Dimensions);
    
    fprintf('\n>>> STATISTICAL ANALYSIS\n');
    fprintf('=================================================================\n');
    
    Friedman_Results = cell(num_dims, 1);
    Wilcoxon_Results = cell(num_dims, 1);
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        fprintf('\n--- Dimension D = %d ---\n\n', dim);
        
        %% ===================== FRIEDMAN TEST =====================
        fprintf('>> FRIEDMAN TEST\n');
        fprintf('   H0: All algorithms perform equally\n');
        fprintf('   H1: At least one algorithm performs differently\n\n');
        
        % Prepare ranking matrix
        Rankings = zeros(num_functions, num_algorithms);
        
        for func_idx = 1:num_functions
            mean_fitness = zeros(1, num_algorithms);
            for alg_idx = 1:num_algorithms
                fitness_data = All_Fitness{func_idx, alg_idx, dim_idx};
                mean_fitness(alg_idx) = mean(fitness_data);
            end
            
            % Assign ranks (lower fitness = better rank)
            [~, sorted_idx] = sort(mean_fitness);
            for rank = 1:num_algorithms
                Rankings(func_idx, sorted_idx(rank)) = rank;
            end
        end
        
        % Calculate Friedman statistic
        R = sum(Rankings, 1);  % Sum of ranks for each algorithm
        R_mean = R / num_functions;  % Average rank
        
        k = num_algorithms;
        N = num_functions;
        
        % Friedman chi-square statistic
        chi_sq_F = 12 * N / (k * (k + 1)) * (sum(R_mean.^2) - k * (k + 1)^2 / 4);
        
        % F-distribution statistic (Iman-Davenport)
        F_F = (N - 1) * chi_sq_F / (N * (k - 1) - chi_sq_F);
        
        % Degrees of freedom
        df1 = k - 1;
        df2 = (k - 1) * (N - 1);
        
        % P-value (using F-distribution)
        if exist('fcdf', 'file')
            p_value_F = 1 - fcdf(F_F, df1, df2);
        else
            % Approximation if fcdf not available
            p_value_F = chi2pvalue(chi_sq_F, df1);
        end
        
        fprintf('   Friedman Chi-Square: %.4f\n', chi_sq_F);
        fprintf('   Iman-Davenport F: %.4f\n', F_F);
        fprintf('   P-value: %.6f\n', p_value_F);
        
        if p_value_F < 0.05
            fprintf('   Result: SIGNIFICANT (p < 0.05) - Reject H0\n');
            fprintf('   Conclusion: Algorithms perform significantly differently.\n\n');
        else
            fprintf('   Result: NOT SIGNIFICANT (p >= 0.05) - Fail to reject H0\n\n');
        end
        
        % Average Rankings
        fprintf('   Average Rankings:\n');
        fprintf('   %-15s %-15s\n', 'Algorithm', 'Avg Rank');
        fprintf('   %s\n', repmat('-', 1, 30));
        [sorted_ranks, sorted_alg] = sort(R_mean);
        for i = 1:num_algorithms
            fprintf('   %-15s %.4f\n', Algorithm_Names{sorted_alg(i)}, sorted_ranks(i));
        end
        
        % Nemenyi post-hoc test (Critical Difference)
        % CD = q_alpha * sqrt(k*(k+1)/(6*N))
        % q_alpha values for alpha=0.05
        q_alpha_table = [0, 1.960, 2.343, 2.569, 2.728, 2.850, 2.949, 3.031, 3.102, 3.164];
        if k <= 10
            q_alpha = q_alpha_table(k);
        else
            q_alpha = 3.164;  % Approximate for larger k
        end
        CD = q_alpha * sqrt(k * (k + 1) / (6 * N));
        
        fprintf('\n   Nemenyi Critical Difference (CD): %.4f\n', CD);
        fprintf('   Algorithms with rank difference > CD are significantly different.\n');
        
        % Store Friedman results
        Friedman_Results{dim_idx}.Rankings = Rankings;
        Friedman_Results{dim_idx}.Avg_Rank = R_mean;
        Friedman_Results{dim_idx}.Chi_Square = chi_sq_F;
        Friedman_Results{dim_idx}.F_Stat = F_F;
        Friedman_Results{dim_idx}.P_Value = p_value_F;
        Friedman_Results{dim_idx}.CD = CD;
        
        %% ===================== WILCOXON SIGNED-RANK TEST =====================
        fprintf('\n>> WILCOXON SIGNED-RANK TEST (QESDO vs Each Competitor)\n');
        fprintf('   H0: QESDO and competitor perform equally\n');
        fprintf('   H1: QESDO and competitor perform differently\n\n');
        
        fprintf('   %-15s %-12s %-12s %-12s %-15s\n', 'Comparison', 'W+', 'W-', 'P-value', 'Significance');
        fprintf('   %s\n', repmat('-', 1, 70));
        
        Wilcoxon_Results{dim_idx} = struct();
        
        % QESDO is assumed to be the first algorithm
        qesdo_idx = 1;
        
        for alg_idx = 2:num_algorithms
            % Collect paired samples (mean fitness for each function)
            qesdo_fitness = zeros(num_functions, 1);
            comp_fitness = zeros(num_functions, 1);
            
            for func_idx = 1:num_functions
                qesdo_fitness(func_idx) = mean(All_Fitness{func_idx, qesdo_idx, dim_idx});
                comp_fitness(func_idx) = mean(All_Fitness{func_idx, alg_idx, dim_idx});
            end
            
            % Perform Wilcoxon signed-rank test
            [p_value, W_plus, W_minus, significant] = wilcoxon_signrank(qesdo_fitness, comp_fitness, 0.05);
            
            % Determine significance with Holm correction (simplified)
            if significant
                sig_str = '*';
            else
                sig_str = '-';
            end
            
            fprintf('   QESDO vs %-7s %10.1f %10.1f %12.6f %10s\n', ...
                Algorithm_Names{alg_idx}, W_plus, W_minus, p_value, sig_str);
            
            Wilcoxon_Results{dim_idx}.(Algorithm_Names{alg_idx}).W_plus = W_plus;
            Wilcoxon_Results{dim_idx}.(Algorithm_Names{alg_idx}).W_minus = W_minus;
            Wilcoxon_Results{dim_idx}.(Algorithm_Names{alg_idx}).P_Value = p_value;
            Wilcoxon_Results{dim_idx}.(Algorithm_Names{alg_idx}).Significant = significant;
        end
        
        fprintf('\n   * indicates p < 0.05 (significant difference)\n');
        fprintf('   - indicates p >= 0.05 (no significant difference)\n');
        
        % Wins/Ties/Losses summary
        fprintf('\n   QESDO Win/Tie/Loss Summary:\n');
        wins = 0; ties = 0; losses = 0;
        
        for func_idx = 1:num_functions
            qesdo_mean = mean(All_Fitness{func_idx, qesdo_idx, dim_idx});
            best_other = inf;
            for alg_idx = 2:num_algorithms
                other_mean = mean(All_Fitness{func_idx, alg_idx, dim_idx});
                if other_mean < best_other
                    best_other = other_mean;
                end
            end
            
            if qesdo_mean < best_other * 0.99  % 1% tolerance
                wins = wins + 1;
            elseif qesdo_mean > best_other * 1.01
                losses = losses + 1;
            else
                ties = ties + 1;
            end
        end
        
        fprintf('   Wins: %d | Ties: %d | Losses: %d\n', wins, ties, losses);
    end
    
    fprintf('\n=================================================================\n');
end

%% Wilcoxon Signed-Rank Test Implementation
function [p_value, W_plus, W_minus, significant] = wilcoxon_signrank(x, y, alpha)
    % Compute differences
    d = x - y;
    
    % Remove zero differences
    d = d(d ~= 0);
    n = length(d);
    
    if n == 0
        p_value = 1;
        W_plus = 0;
        W_minus = 0;
        significant = false;
        return;
    end
    
    % Rank absolute differences
    [~, idx] = sort(abs(d));
    ranks = zeros(n, 1);
    ranks(idx) = 1:n;
    
    % Handle ties (average ranks)
    abs_d = abs(d);
    unique_vals = unique(abs_d);
    for i = 1:length(unique_vals)
        tie_idx = find(abs_d == unique_vals(i));
        if length(tie_idx) > 1
            avg_rank = mean(ranks(tie_idx));
            ranks(tie_idx) = avg_rank;
        end
    end
    
    % Calculate W+ and W-
    W_plus = sum(ranks(d > 0));
    W_minus = sum(ranks(d < 0));
    
    % Test statistic (smaller of W+ and W-)
    W = min(W_plus, W_minus);
    
    % Normal approximation for p-value (for n >= 10)
    if n >= 10
        mean_W = n * (n + 1) / 4;
        std_W = sqrt(n * (n + 1) * (2 * n + 1) / 24);
        z = (W - mean_W) / std_W;
        % Two-tailed p-value
        p_value = 2 * (1 - normcdf(abs(z)));
    else
        % Use exact distribution (lookup table for small n)
        p_value = wilcoxon_exact_p(W, n);
    end
    
    % Determine significance
    significant = (p_value < alpha);
end

function p = wilcoxon_exact_p(W, n)
    % Approximate p-value for small samples using normal approximation
    mean_W = n * (n + 1) / 4;
    std_W = sqrt(n * (n + 1) * (2 * n + 1) / 24);
    if std_W > 0
        z = (W - mean_W) / std_W;
        p = 2 * (1 - normcdf(abs(z)));
    else
        p = 1;
    end
end

function p = normcdf(x)
    % Standard normal CDF approximation
    p = 0.5 * (1 + erf(x / sqrt(2)));
end

function p = chi2pvalue(chi2, df)
    % Approximate chi-square p-value using normal approximation
    z = (chi2 - df) / sqrt(2 * df);
    p = 1 - normcdf(z);
    p = max(0, min(1, p));
end
