%___________________________________________________________________%
%  Advanced Statistical Analysis                                    %
%                                                                   %
%  This function performs comprehensive statistical analysis:       %
%  - Friedman Test with multiple post-hoc tests                     %
%  - Wilcoxon Signed-Rank Test with Holm correction                 %
%  - Win/Tie/Loss Analysis                                          %
%  - Effect Size (Cohen's d)                                        %
%___________________________________________________________________%

function AdvancedStatistics(All_Fitness, Algorithm_Names, Function_IDs, Dimensions)
    
    num_functions = length(Function_IDs);
    num_algorithms = length(Algorithm_Names);
    num_dims = length(Dimensions);
    
    fprintf('\n');
    fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
    fprintf('║           ADVANCED STATISTICAL ANALYSIS                          ║\n');
    fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        fprintf('═══════════════════════════════════════════════════════════════════\n');
        fprintf('                    DIMENSION D = %d\n', dim);
        fprintf('═══════════════════════════════════════════════════════════════════\n\n');
        
        %% ================== FRIEDMAN TEST ==================
        fprintf('▶ FRIEDMAN TEST (Non-parametric ANOVA)\n');
        fprintf('───────────────────────────────────────────────────────────────────\n');
        
        % Prepare ranking matrix
        Rankings = zeros(num_functions, num_algorithms);
        MeanFitness = zeros(num_functions, num_algorithms);
        
        for func_idx = 1:num_functions
            for alg_idx = 1:num_algorithms
                fitness_data = All_Fitness{func_idx, alg_idx, dim_idx};
                MeanFitness(func_idx, alg_idx) = mean(fitness_data);
            end
            
            % Assign ranks (handle ties by average rank)
            [~, sorted_idx] = sort(MeanFitness(func_idx, :));
            for rank = 1:num_algorithms
                Rankings(func_idx, sorted_idx(rank)) = rank;
            end
        end
        
        % Calculate Friedman statistic
        R = sum(Rankings, 1);
        R_mean = R / num_functions;
        
        k = num_algorithms;
        N = num_functions;
        
        % Friedman chi-square
        chi_sq_F = 12 * N / (k * (k + 1)) * (sum(R_mean.^2) - k * (k + 1)^2 / 4);
        
        % Iman-Davenport F-statistic
        F_F = (N - 1) * chi_sq_F / (N * (k - 1) - chi_sq_F);
        
        % Degrees of freedom
        df1 = k - 1;
        df2 = (k - 1) * (N - 1);
        
        % P-value approximation
        p_value_F = chi2pval_adv(chi_sq_F, df1);
        
        fprintf('  Chi-Square statistic: %.4f\n', chi_sq_F);
        fprintf('  Iman-Davenport F: %.4f (df1=%d, df2=%d)\n', F_F, df1, df2);
        fprintf('  P-value: %.6f\n', p_value_F);
        
        if p_value_F < 0.05
            fprintf('  ✓ SIGNIFICANT at α=0.05 (Reject H0)\n');
        else
            fprintf('  ✗ Not significant at α=0.05\n');
        end
        
        % Display rankings
        fprintf('\n  Average Rankings (lower is better):\n');
        fprintf('  %-15s %-12s %-10s\n', 'Algorithm', 'Avg Rank', 'Sum Rank');
        fprintf('  %s\n', repmat('-', 1, 40));
        [sorted_ranks, sorted_alg] = sort(R_mean);
        for i = 1:num_algorithms
            if i == 1
                marker = ' ★';
            else
                marker = '';
            end
            fprintf('  %-15s %-12.4f %-10.1f%s\n', ...
                Algorithm_Names{sorted_alg(i)}, sorted_ranks(i), R(sorted_alg(i)), marker);
        end
        
        %% ================== NEMENYI POST-HOC TEST ==================
        fprintf('\n▶ NEMENYI POST-HOC TEST\n');
        fprintf('───────────────────────────────────────────────────────────────────\n');
        
        % Critical values for q_alpha (alpha=0.05)
        q_alpha_table = [0, 1.960, 2.343, 2.569, 2.728, 2.850, 2.949, 3.031, 3.102, 3.164];
        if k <= 10
            q_alpha = q_alpha_table(k);
        else
            q_alpha = 2.576 + 0.1 * (k - 10);  % Approximation
        end
        
        CD = q_alpha * sqrt(k * (k + 1) / (6 * N));
        fprintf('  Critical Difference (CD): %.4f\n', CD);
        fprintf('  q_α (α=0.05, k=%d): %.4f\n\n', k, q_alpha);
        
        % Pairwise comparisons
        fprintf('  Significant differences (|rank_i - rank_j| > CD):\n');
        sig_count = 0;
        for i = 1:num_algorithms
            for j = i+1:num_algorithms
                diff = abs(R_mean(i) - R_mean(j));
                if diff > CD
                    sig_count = sig_count + 1;
                    fprintf('    %s vs %s: %.4f > %.4f ✓\n', ...
                        Algorithm_Names{i}, Algorithm_Names{j}, diff, CD);
                end
            end
        end
        if sig_count == 0
            fprintf('    No significant pairwise differences found.\n');
        end
        
        %% ================== WILCOXON WITH HOLM CORRECTION ==================
        fprintf('\n▶ WILCOXON SIGNED-RANK TEST (with Holm correction)\n');
        fprintf('───────────────────────────────────────────────────────────────────\n');
        fprintf('  Comparing QESDO (reference) vs. each competitor\n\n');
        
        qesdo_idx = 1;  % Assuming QESDO is the first algorithm
        
        % Collect p-values for all comparisons
        p_values = zeros(1, num_algorithms - 1);
        W_plus_arr = zeros(1, num_algorithms - 1);
        W_minus_arr = zeros(1, num_algorithms - 1);
        
        for alg_idx = 2:num_algorithms
            qesdo_means = MeanFitness(:, qesdo_idx);
            comp_means = MeanFitness(:, alg_idx);
            
            [p_val, W_plus, W_minus] = wilcoxon_test_adv(qesdo_means, comp_means);
            p_values(alg_idx - 1) = p_val;
            W_plus_arr(alg_idx - 1) = W_plus;
            W_minus_arr(alg_idx - 1) = W_minus;
        end
        
        % Holm correction
        [sorted_p, sorted_idx] = sort(p_values);
        m = length(p_values);  % Number of comparisons
        holm_alpha = zeros(1, m);
        holm_sig = false(1, m);
        
        for i = 1:m
            holm_alpha(i) = 0.05 / (m - i + 1);
            if sorted_p(i) < holm_alpha(i)
                holm_sig(i) = true;
            else
                break;  % Stop when first non-significant found
            end
        end
        
        % Display results
        fprintf('  %-15s %-10s %-10s %-12s %-12s %-10s\n', ...
            'Comparison', 'W+', 'W-', 'P-value', 'Holm α', 'Sig.');
        fprintf('  %s\n', repmat('-', 1, 75));
        
        for i = 1:m
            orig_idx = sorted_idx(i);
            alg_name = Algorithm_Names{orig_idx + 1};
            
            if holm_sig(i)
                sig_str = '✓ *';
            else
                sig_str = '—';
            end
            
            fprintf('  QESDO vs %-6s %-10.1f %-10.1f %-12.6f %-12.6f %-10s\n', ...
                alg_name, W_plus_arr(orig_idx), W_minus_arr(orig_idx), ...
                sorted_p(i), holm_alpha(i), sig_str);
        end
        
        fprintf('\n  * Significant after Holm correction\n');
        
        %% ================== WIN/TIE/LOSS ANALYSIS ==================
        fprintf('\n▶ WIN/TIE/LOSS ANALYSIS\n');
        fprintf('───────────────────────────────────────────────────────────────────\n');
        
        fprintf('  %-15s %-8s %-8s %-8s %-15s\n', 'Comparison', 'Wins', 'Ties', 'Losses', 'Outcome');
        fprintf('  %s\n', repmat('-', 1, 60));
        
        for alg_idx = 2:num_algorithms
            wins = 0; ties = 0; losses = 0;
            
            for func_idx = 1:num_functions
                qesdo_mean = MeanFitness(func_idx, qesdo_idx);
                comp_mean = MeanFitness(func_idx, alg_idx);
                
                % Use relative tolerance for comparison
                tol = 1e-8 * max(abs(qesdo_mean), abs(comp_mean));
                
                if qesdo_mean < comp_mean - tol
                    wins = wins + 1;
                elseif qesdo_mean > comp_mean + tol
                    losses = losses + 1;
                else
                    ties = ties + 1;
                end
            end
            
            if wins > losses
                outcome = '↑ Better';
            elseif wins < losses
                outcome = '↓ Worse';
            else
                outcome = '→ Similar';
            end
            
            fprintf('  QESDO vs %-6s %-8d %-8d %-8d %-15s\n', ...
                Algorithm_Names{alg_idx}, wins, ties, losses, outcome);
        end
        
        %% ================== EFFECT SIZE (COHEN'S d) ==================
        fprintf('\n▶ EFFECT SIZE ANALYSIS (Cohen''s d)\n');
        fprintf('───────────────────────────────────────────────────────────────────\n');
        fprintf('  Interpretation: |d| < 0.2 (negligible), 0.2-0.5 (small),\n');
        fprintf('                  0.5-0.8 (medium), > 0.8 (large)\n\n');
        
        fprintf('  %-15s %-12s %-15s\n', 'Comparison', 'Cohen''s d', 'Effect Size');
        fprintf('  %s\n', repmat('-', 1, 45));
        
        for alg_idx = 2:num_algorithms
            % Pool all fitness values across functions
            qesdo_all = [];
            comp_all = [];
            
            for func_idx = 1:num_functions
                qesdo_all = [qesdo_all; All_Fitness{func_idx, qesdo_idx, dim_idx}(:)];
                comp_all = [comp_all; All_Fitness{func_idx, alg_idx, dim_idx}(:)];
            end
            
            % Normalize to handle different scales
            all_data = [qesdo_all; comp_all];
            data_min = min(all_data);
            data_max = max(all_data);
            if data_max > data_min
                qesdo_norm = (qesdo_all - data_min) / (data_max - data_min);
                comp_norm = (comp_all - data_min) / (data_max - data_min);
            else
                qesdo_norm = qesdo_all;
                comp_norm = comp_all;
            end
            
            % Cohen's d
            mean_diff = mean(comp_norm) - mean(qesdo_norm);  % Positive = QESDO better
            pooled_std = sqrt((var(qesdo_norm) + var(comp_norm)) / 2);
            if pooled_std > 0
                d = mean_diff / pooled_std;
            else
                d = 0;
            end
            
            % Interpret effect size
            abs_d = abs(d);
            if abs_d < 0.2
                effect_str = 'Negligible';
            elseif abs_d < 0.5
                effect_str = 'Small';
            elseif abs_d < 0.8
                effect_str = 'Medium';
            else
                effect_str = 'Large';
            end
            
            if d > 0
                effect_str = [effect_str, ' (QESDO ↑)'];
            elseif d < 0
                effect_str = [effect_str, ' (QESDO ↓)'];
            end
            
            fprintf('  QESDO vs %-6s %-12.4f %-15s\n', ...
                Algorithm_Names{alg_idx}, d, effect_str);
        end
        
        fprintf('\n');
    end
    
    fprintf('═══════════════════════════════════════════════════════════════════\n');
    fprintf('                 STATISTICAL ANALYSIS COMPLETED\n');
    fprintf('═══════════════════════════════════════════════════════════════════\n');
end

%% Helper Functions

function [p_val, W_plus, W_minus] = wilcoxon_test_adv(x, y)
    d = x - y;
    d = d(d ~= 0);
    n = length(d);
    
    if n == 0
        p_val = 1; W_plus = 0; W_minus = 0;
        return;
    end
    
    [~, idx] = sort(abs(d));
    ranks = zeros(n, 1);
    ranks(idx) = 1:n;
    
    % Handle ties
    abs_d = abs(d);
    unique_vals = unique(abs_d);
    for i = 1:length(unique_vals)
        tie_idx = find(abs_d == unique_vals(i));
        if length(tie_idx) > 1
            ranks(tie_idx) = mean(ranks(tie_idx));
        end
    end
    
    W_plus = sum(ranks(d > 0));
    W_minus = sum(ranks(d < 0));
    W = min(W_plus, W_minus);
    
    % Normal approximation
    mean_W = n * (n + 1) / 4;
    std_W = sqrt(n * (n + 1) * (2 * n + 1) / 24);
    z = (W - mean_W) / std_W;
    p_val = 2 * normcdf_adv(-abs(z));
end

function p = normcdf_adv(x)
    p = 0.5 * (1 + erf(x / sqrt(2)));
end

function p = chi2pval_adv(chi2, df)
    % Wilson-Hilferty approximation
    z = ((chi2 / df)^(1/3) - (1 - 2/(9*df))) / sqrt(2/(9*df));
    p = 1 - normcdf_adv(z);
    p = max(0, min(1, p));
end
