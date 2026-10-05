%___________________________________________________________________%
%  Plot Results: Convergence Curves and Box Plots                  %
%                                                                   %
%  This function generates graphical comparisons:                   %
%  - Convergence curves (log-scale fitness vs iteration)            %
%  - Box plots of final fitness distributions                       %
%___________________________________________________________________%

function PlotResults(Convergence_Curves, All_Fitness, Algorithm_Names, Function_IDs, Dimensions, Max_iteration)
    
    num_functions = length(Function_IDs);
    num_algorithms = length(Algorithm_Names);
    num_dims = length(Dimensions);
    
    % Create output directory
    if ~exist('Results_Figures', 'dir')
        mkdir('Results_Figures');
    end
    
    % Define colors for each algorithm
    colors = [
        0.0000, 0.4470, 0.7410;  % Blue (QESDO)
        0.8500, 0.3250, 0.0980;  % Orange (DO)
        0.9290, 0.6940, 0.1250;  % Yellow (GWO)
        0.4940, 0.1840, 0.5560;  % Purple (PSO)
        0.4660, 0.6740, 0.1880;  % Green (DE)
        0.3010, 0.7450, 0.9330;  % Cyan (GA)
    ];
    
    % Define line styles
    lineStyles = {'-', '--', '-.', ':', '-', '--'};
    markers = {'o', 's', 'd', '^', 'v', '<'};
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        %% ===================== CONVERGENCE CURVES =====================
        fprintf('   Generating convergence curves (D=%d)...\n', dim);
        
        % Create subplot figure for all functions
        num_cols = min(4, num_functions);
        num_rows = ceil(num_functions / num_cols);
        
        fig1 = figure('Position', [100, 100, 400*num_cols, 300*num_rows], 'Color', 'w');
        
        for func_idx = 1:num_functions
            subplot(num_rows, num_cols, func_idx);
            hold on;
            
            for alg_idx = 1:num_algorithms
                curve = Convergence_Curves{func_idx, alg_idx, dim_idx};
                
                % Plot with markers at intervals
                marker_interval = floor(Max_iteration / 10);
                plot(1:Max_iteration, curve, ...
                    'Color', colors(alg_idx, :), ...
                    'LineWidth', 1.5, ...
                    'LineStyle', lineStyles{alg_idx});
            end
            
            hold off;
            
            set(gca, 'YScale', 'log');
            xlabel('Iteration', 'FontSize', 10);
            ylabel('Best Fitness (log)', 'FontSize', 10);
            title(sprintf('F%d (D=%d)', Function_IDs(func_idx), dim), 'FontSize', 11);
            grid on;
            box on;
            
            if func_idx == num_functions
                legend(Algorithm_Names, 'Location', 'best', 'FontSize', 8);
            end
        end
        
        sgtitle(sprintf('Convergence Curves Comparison (D=%d)', dim), 'FontSize', 14, 'FontWeight', 'bold');
        
        % Save figure
        saveas(fig1, sprintf('Results_Figures/Convergence_Curves_D%d.png', dim));
        saveas(fig1, sprintf('Results_Figures/Convergence_Curves_D%d.fig', dim));
        
        %% ===================== BOX PLOTS =====================
        fprintf('   Generating box plots (D=%d)...\n', dim);
        
        fig2 = figure('Position', [100, 100, 400*num_cols, 300*num_rows], 'Color', 'w');
        
        for func_idx = 1:num_functions
            subplot(num_rows, num_cols, func_idx);
            
            % Prepare data for boxplot
            all_data = [];
            group_labels = {};
            
            for alg_idx = 1:num_algorithms
                fitness_data = All_Fitness{func_idx, alg_idx, dim_idx};
                all_data = [all_data; fitness_data(:)];
                group_labels = [group_labels; repmat(Algorithm_Names(alg_idx), length(fitness_data), 1)];
            end
            
            % Create boxplot
            boxplot(all_data, group_labels, 'Colors', colors, 'Symbol', 'r+');
            
            ylabel('Fitness', 'FontSize', 10);
            title(sprintf('F%d (D=%d)', Function_IDs(func_idx), dim), 'FontSize', 11);
            
            % Rotate x-labels
            xtickangle(45);
            grid on;
            box on;
        end
        
        sgtitle(sprintf('Box Plots Comparison (D=%d)', dim), 'FontSize', 14, 'FontWeight', 'bold');
        
        % Save figure
        saveas(fig2, sprintf('Results_Figures/BoxPlots_D%d.png', dim));
        saveas(fig2, sprintf('Results_Figures/BoxPlots_D%d.fig', dim));
        
        %% ===================== INDIVIDUAL CONVERGENCE CURVES =====================
        % Generate individual high-quality figures for selected functions
        selected_functions = [1, 5, 9, 10];  % Sphere, Rosenbrock, Rastrigin, Ackley
        
        for i = 1:length(selected_functions)
            func_idx = selected_functions(i);
            if func_idx > num_functions
                continue;
            end
            
            fig3 = figure('Position', [100, 100, 600, 450], 'Color', 'w');
            hold on;
            
            for alg_idx = 1:num_algorithms
                curve = Convergence_Curves{func_idx, alg_idx, dim_idx};
                
                % Add markers at regular intervals
                marker_idx = 1:floor(Max_iteration/10):Max_iteration;
                
                plot(1:Max_iteration, curve, ...
                    'Color', colors(alg_idx, :), ...
                    'LineWidth', 2, ...
                    'LineStyle', '-');
                
                plot(marker_idx, curve(marker_idx), ...
                    'Color', colors(alg_idx, :), ...
                    'LineStyle', 'none', ...
                    'Marker', markers{alg_idx}, ...
                    'MarkerSize', 8, ...
                    'MarkerFaceColor', colors(alg_idx, :));
            end
            
            hold off;
            
            set(gca, 'YScale', 'log', 'FontSize', 12);
            xlabel('Iteration', 'FontSize', 14);
            ylabel('Best Fitness (log)', 'FontSize', 14);
            title(sprintf('Convergence Curve - F%d (D=%d)', Function_IDs(func_idx), dim), 'FontSize', 14);
            legend(Algorithm_Names, 'Location', 'northeast', 'FontSize', 10);
            grid on;
            box on;
            
            saveas(fig3, sprintf('Results_Figures/Convergence_F%d_D%d.png', Function_IDs(func_idx), dim));
            saveas(fig3, sprintf('Results_Figures/Convergence_F%d_D%d.fig', Function_IDs(func_idx), dim));
            close(fig3);
        end
        
        %% ===================== RANKING BAR CHART =====================
        fprintf('   Generating ranking bar chart (D=%d)...\n', dim);
        
        % Calculate average rankings
        Rankings = zeros(num_functions, num_algorithms);
        for func_idx = 1:num_functions
            mean_fitness = zeros(1, num_algorithms);
            for alg_idx = 1:num_algorithms
                mean_fitness(alg_idx) = mean(All_Fitness{func_idx, alg_idx, dim_idx});
            end
            [~, sorted_idx] = sort(mean_fitness);
            for rank = 1:num_algorithms
                Rankings(func_idx, sorted_idx(rank)) = rank;
            end
        end
        
        Avg_Rank = mean(Rankings, 1);
        [sorted_rank, sorted_alg] = sort(Avg_Rank);
        
        fig4 = figure('Position', [100, 100, 700, 400], 'Color', 'w');
        
        bar_colors = zeros(num_algorithms, 3);
        for i = 1:num_algorithms
            bar_colors(i, :) = colors(sorted_alg(i), :);
        end
        
        b = bar(sorted_rank, 'FaceColor', 'flat');
        b.CData = bar_colors;
        
        set(gca, 'XTickLabel', Algorithm_Names(sorted_alg), 'FontSize', 12);
        xtickangle(45);
        xlabel('Algorithm', 'FontSize', 14);
        ylabel('Average Rank', 'FontSize', 14);
        title(sprintf('Algorithm Rankings (D=%d) - Lower is Better', dim), 'FontSize', 14);
        grid on;
        box on;
        
        % Add value labels on bars
        for i = 1:num_algorithms
            text(i, sorted_rank(i) + 0.1, sprintf('%.2f', sorted_rank(i)), ...
                'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
        end
        
        saveas(fig4, sprintf('Results_Figures/Rankings_D%d.png', dim));
        saveas(fig4, sprintf('Results_Figures/Rankings_D%d.fig', dim));
        
        %% ===================== HEATMAP OF RANKINGS =====================
        fprintf('   Generating ranking heatmap (D=%d)...\n', dim);
        
        fig5 = figure('Position', [100, 100, 800, 500], 'Color', 'w');
        
        % Create heatmap
        imagesc(Rankings);
        colormap(flipud(hot));
        colorbar;
        
        set(gca, 'XTick', 1:num_algorithms, 'XTickLabel', Algorithm_Names, 'FontSize', 10);
        set(gca, 'YTick', 1:num_functions, 'YTickLabel', arrayfun(@(x) sprintf('F%d', x), Function_IDs, 'UniformOutput', false), 'FontSize', 10);
        xtickangle(45);
        
        xlabel('Algorithm', 'FontSize', 12);
        ylabel('Function', 'FontSize', 12);
        title(sprintf('Ranking Heatmap (D=%d) - Lower Rank = Better', dim), 'FontSize', 14);
        
        % Add text annotations
        for i = 1:num_functions
            for j = 1:num_algorithms
                text(j, i, sprintf('%d', Rankings(i, j)), ...
                    'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
            end
        end
        
        saveas(fig5, sprintf('Results_Figures/RankingHeatmap_D%d.png', dim));
        saveas(fig5, sprintf('Results_Figures/RankingHeatmap_D%d.fig', dim));
    end
    
    fprintf('   All figures saved to Results_Figures/\n');
end
