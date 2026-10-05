%___________________________________________________________________%
%  Save Ranking Images                                              %
%                                                                   %
%  This function generates and saves ranking visualization images:  %
%  - Ranking bar charts                                             %
%  - Ranking heatmaps                                               %
%  - Win/Tie/Loss charts                                            %
%  - Radar/Spider charts                                            %
%___________________________________________________________________%

function SaveRankingImages(Results_Mean, All_Fitness, Algorithm_Names, Function_IDs, Dimensions)
    
    % Create output directory
    if ~exist('Results_Rankings', 'dir')
        mkdir('Results_Rankings');
    end
    
    num_functions = length(Function_IDs);
    num_algorithms = length(Algorithm_Names);
    num_dims = length(Dimensions);
    
    % Define colors for each algorithm
    colors = [
        0.0000, 0.4470, 0.7410;  % Blue (QESDO)
        0.8500, 0.3250, 0.0980;  % Orange (DO)
        0.9290, 0.6940, 0.1250;  % Yellow (GWO)
        0.4940, 0.1840, 0.5560;  % Purple (PSO)
        0.4660, 0.6740, 0.1880;  % Green (DE)
        0.3010, 0.7450, 0.9330;  % Cyan (GA)
    ];
    
    % Ensure enough colors
    while size(colors, 1) < num_algorithms
        colors = [colors; rand(1, 3)];
    end
    
    fprintf('Generating ranking images...\n');
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        % Create dimension-specific subdirectory
        dim_folder = sprintf('Results_Rankings/D%d', dim);
        if ~exist(dim_folder, 'dir')
            mkdir(dim_folder);
        end
        
        fprintf('  Dimension D = %d:\n', dim);
        
        %% Calculate Rankings
        Rankings = zeros(num_functions, num_algorithms);
        for func_idx = 1:num_functions
            [~, sorted_idx] = sort(Results_Mean(func_idx, :, dim_idx));
            for rank = 1:num_algorithms
                Rankings(func_idx, sorted_idx(rank)) = rank;
            end
        end
        
        Avg_Rank = mean(Rankings, 1);
        [sorted_rank, sorted_alg] = sort(Avg_Rank);
        
        %% 1. Average Ranking Bar Chart
        fig1 = figure('Position', [100, 100, 900, 600], 'Color', 'w', 'Visible', 'off');
        
        % Create bar chart with custom colors
        bar_data = sorted_rank;
        b = bar(bar_data, 'FaceColor', 'flat', 'EdgeColor', 'k', 'LineWidth', 1.5);
        
        % Set colors for each bar
        for i = 1:num_algorithms
            b.CData(i, :) = colors(sorted_alg(i), :);
        end
        
        % Add value labels on top of bars
        for i = 1:num_algorithms
            text(i, sorted_rank(i) + 0.1, sprintf('%.3f', sorted_rank(i)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', ...
                'FontSize', 12, 'FontWeight', 'bold');
        end
        
        % Formatting
        set(gca, 'XTickLabel', Algorithm_Names(sorted_alg), 'FontSize', 12);
        xtickangle(30);
        xlabel('Algorithm', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Average Rank', 'FontSize', 14, 'FontWeight', 'bold');
        title(sprintf('Algorithm Rankings (D=%d) - Lower is Better', dim), 'FontSize', 16, 'FontWeight', 'bold');
        grid on;
        box on;
        ylim([0, max(sorted_rank) + 0.8]);
        
        % Add rank position labels
        for i = 1:num_algorithms
            text(i, 0.2, sprintf('#%d', i), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 11, 'FontWeight', 'bold', 'Color', 'w');
        end
        
        % Save
        base_filename = sprintf('%s/Ranking_BarChart', dim_folder);
        print(fig1, [base_filename, '.png'], '-dpng', '-r300');
        savefig(fig1, [base_filename, '.fig']);
        print(fig1, [base_filename, '.eps'], '-depsc2');
        close(fig1);
        fprintf('    Saved: Ranking_BarChart\n');
        
        %% 2. Ranking Heatmap
        fig2 = figure('Position', [100, 100, 1000, 700], 'Color', 'w', 'Visible', 'off');
        
        % Create heatmap
        imagesc(Rankings);
        
        % Custom colormap (green = good/rank 1, red = bad/high rank)
        custom_cmap = zeros(num_algorithms, 3);
        for i = 1:num_algorithms
            ratio = (i - 1) / (num_algorithms - 1);
            custom_cmap(i, :) = [ratio, 1-ratio, 0.2];  % Red to green
        end
        colormap(custom_cmap);
        colorbar('Ticks', 1:num_algorithms, 'TickLabels', arrayfun(@num2str, 1:num_algorithms, 'UniformOutput', false));
        
        % Add text annotations
        for i = 1:num_functions
            for j = 1:num_algorithms
                rank_val = Rankings(i, j);
                if rank_val <= 2
                    text_color = 'w';
                else
                    text_color = 'k';
                end
                text(j, i, sprintf('%d', rank_val), ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', ...
                    'FontSize', 10, 'FontWeight', 'bold', 'Color', text_color);
            end
        end
        
        % Formatting
        set(gca, 'XTick', 1:num_algorithms, 'XTickLabel', Algorithm_Names, 'FontSize', 11);
        set(gca, 'YTick', 1:num_functions, 'YTickLabel', arrayfun(@(x) sprintf('F%d', x), Function_IDs, 'UniformOutput', false), 'FontSize', 11);
        xtickangle(30);
        xlabel('Algorithm', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Function', 'FontSize', 14, 'FontWeight', 'bold');
        title(sprintf('Ranking Heatmap (D=%d) - Lower Rank = Better', dim), 'FontSize', 16, 'FontWeight', 'bold');
        
        % Save
        base_filename = sprintf('%s/Ranking_Heatmap', dim_folder);
        print(fig2, [base_filename, '.png'], '-dpng', '-r300');
        savefig(fig2, [base_filename, '.fig']);
        print(fig2, [base_filename, '.eps'], '-depsc2');
        close(fig2);
        fprintf('    Saved: Ranking_Heatmap\n');
        
        %% 3. Win/Tie/Loss Chart (QESDO vs Others)
        fig3 = figure('Position', [100, 100, 1000, 600], 'Color', 'w', 'Visible', 'off');
        
        qesdo_idx = 1;  % Assuming QESDO is first
        wins = zeros(1, num_algorithms - 1);
        ties = zeros(1, num_algorithms - 1);
        losses = zeros(1, num_algorithms - 1);
        
        for alg_idx = 2:num_algorithms
            for func_idx = 1:num_functions
                qesdo_mean = Results_Mean(func_idx, qesdo_idx, dim_idx);
                other_mean = Results_Mean(func_idx, alg_idx, dim_idx);
                
                tol = 1e-10 * max(abs(qesdo_mean), abs(other_mean));
                if abs(tol) < 1e-50
                    tol = 1e-50;
                end
                
                if qesdo_mean < other_mean - tol
                    wins(alg_idx - 1) = wins(alg_idx - 1) + 1;
                elseif qesdo_mean > other_mean + tol
                    losses(alg_idx - 1) = losses(alg_idx - 1) + 1;
                else
                    ties(alg_idx - 1) = ties(alg_idx - 1) + 1;
                end
            end
        end
        
        % Create grouped bar chart
        wtl_data = [wins; ties; losses]';
        b = bar(wtl_data, 'grouped');
        b(1).FaceColor = [0.2, 0.7, 0.2];  % Green for wins
        b(2).FaceColor = [0.9, 0.9, 0.2];  % Yellow for ties
        b(3).FaceColor = [0.8, 0.2, 0.2];  % Red for losses
        
        % Add value labels
        for i = 1:3
            xtips = b(i).XEndPoints;
            ytips = b(i).YEndPoints;
            labels = string(b(i).YData);
            text(xtips, ytips, labels, 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', 'FontSize', 10, 'FontWeight', 'bold');
        end
        
        % Formatting
        set(gca, 'XTickLabel', Algorithm_Names(2:end), 'FontSize', 12);
        xtickangle(30);
        xlabel('Competitor Algorithm', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Number of Functions', 'FontSize', 14, 'FontWeight', 'bold');
        title(sprintf('QESDO Win/Tie/Loss Analysis (D=%d)', dim), 'FontSize', 16, 'FontWeight', 'bold');
        legend({'Win', 'Tie', 'Loss'}, 'Location', 'northeast', 'FontSize', 12);
        grid on;
        box on;
        ylim([0, num_functions + 2]);
        
        % Save
        base_filename = sprintf('%s/WinTieLoss_Chart', dim_folder);
        print(fig3, [base_filename, '.png'], '-dpng', '-r300');
        savefig(fig3, [base_filename, '.fig']);
        print(fig3, [base_filename, '.eps'], '-depsc2');
        close(fig3);
        fprintf('    Saved: WinTieLoss_Chart\n');
        
        %% 4. Ranking by Function Type
        fig4 = figure('Position', [100, 100, 1200, 500], 'Color', 'w', 'Visible', 'off');
        
        % Separate by function type
        unimodal_idx = find(Function_IDs >= 1 & Function_IDs <= 7);
        multimodal_idx = find(Function_IDs >= 8 & Function_IDs <= 13);
        fixeddim_idx = find(Function_IDs >= 14 & Function_IDs <= 23);
        
        subplot_count = 0;
        if ~isempty(unimodal_idx), subplot_count = subplot_count + 1; end
        if ~isempty(multimodal_idx), subplot_count = subplot_count + 1; end
        if ~isempty(fixeddim_idx), subplot_count = subplot_count + 1; end
        
        current_subplot = 1;
        
        % Unimodal
        if ~isempty(unimodal_idx)
            subplot(1, subplot_count, current_subplot);
            uni_rankings = Rankings(unimodal_idx, :);
            uni_avg = mean(uni_rankings, 1);
            [uni_sorted, uni_order] = sort(uni_avg);
            
            barh(uni_sorted, 'FaceColor', [0.2, 0.6, 0.9]);
            set(gca, 'YTickLabel', Algorithm_Names(uni_order), 'FontSize', 10);
            xlabel('Average Rank', 'FontSize', 12);
            title('Unimodal (F1-F7)', 'FontSize', 12, 'FontWeight', 'bold');
            grid on;
            xlim([0, num_algorithms + 0.5]);
            current_subplot = current_subplot + 1;
        end
        
        % Multimodal
        if ~isempty(multimodal_idx)
            subplot(1, subplot_count, current_subplot);
            multi_rankings = Rankings(multimodal_idx, :);
            multi_avg = mean(multi_rankings, 1);
            [multi_sorted, multi_order] = sort(multi_avg);
            
            barh(multi_sorted, 'FaceColor', [0.9, 0.5, 0.2]);
            set(gca, 'YTickLabel', Algorithm_Names(multi_order), 'FontSize', 10);
            xlabel('Average Rank', 'FontSize', 12);
            title('Multimodal (F8-F13)', 'FontSize', 12, 'FontWeight', 'bold');
            grid on;
            xlim([0, num_algorithms + 0.5]);
            current_subplot = current_subplot + 1;
        end
        
        % Fixed-dimension
        if ~isempty(fixeddim_idx)
            subplot(1, subplot_count, current_subplot);
            fixed_rankings = Rankings(fixeddim_idx, :);
            fixed_avg = mean(fixed_rankings, 1);
            [fixed_sorted, fixed_order] = sort(fixed_avg);
            
            barh(fixed_sorted, 'FaceColor', [0.5, 0.8, 0.4]);
            set(gca, 'YTickLabel', Algorithm_Names(fixed_order), 'FontSize', 10);
            xlabel('Average Rank', 'FontSize', 12);
            title('Fixed-Dim (F14-F23)', 'FontSize', 12, 'FontWeight', 'bold');
            grid on;
            xlim([0, num_algorithms + 0.5]);
        end
        
        sgtitle(sprintf('Rankings by Function Type (D=%d)', dim), 'FontSize', 14, 'FontWeight', 'bold');
        
        % Save
        base_filename = sprintf('%s/Ranking_ByType', dim_folder);
        print(fig4, [base_filename, '.png'], '-dpng', '-r300');
        savefig(fig4, [base_filename, '.fig']);
        print(fig4, [base_filename, '.eps'], '-depsc2');
        close(fig4);
        fprintf('    Saved: Ranking_ByType\n');
        
        %% 5. Radar/Spider Chart
        fig5 = figure('Position', [100, 100, 800, 800], 'Color', 'w', 'Visible', 'off');
        
        % Normalize rankings (invert so higher is better for visualization)
        norm_rankings = (num_algorithms + 1 - Avg_Rank) / num_algorithms;
        
        % Create radar chart
        theta = linspace(0, 2*pi, num_algorithms + 1);
        
        % Draw radar background
        hold on;
        for r = 0.2:0.2:1
            x_circle = r * cos(theta);
            y_circle = r * sin(theta);
            plot(x_circle, y_circle, 'Color', [0.8, 0.8, 0.8], 'LineWidth', 0.5);
        end
        
        % Draw spokes
        for i = 1:num_algorithms
            plot([0, cos(theta(i))], [0, sin(theta(i))], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
        end
        
        % Plot data
        radar_data = norm_rankings([1:end, 1]);  % Close the polygon
        x_data = radar_data .* cos(theta);
        y_data = radar_data .* sin(theta);
        
        fill(x_data, y_data, colors(1, :), 'FaceAlpha', 0.3, 'EdgeColor', colors(1, :), 'LineWidth', 2);
        plot(x_data, y_data, 'o', 'MarkerSize', 8, 'MarkerFaceColor', colors(1, :), 'MarkerEdgeColor', 'k');
        
        % Add labels
        label_radius = 1.15;
        for i = 1:num_algorithms
            text(label_radius * cos(theta(i)), label_radius * sin(theta(i)), ...
                sprintf('%s\n(%.2f)', Algorithm_Names{i}, Avg_Rank(i)), ...
                'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
        end
        
        hold off;
        axis equal;
        axis off;
        title(sprintf('Algorithm Performance Radar (D=%d)', dim), 'FontSize', 16, 'FontWeight', 'bold');
        
        % Save
        base_filename = sprintf('%s/Ranking_Radar', dim_folder);
        print(fig5, [base_filename, '.png'], '-dpng', '-r300');
        savefig(fig5, [base_filename, '.fig']);
        close(fig5);
        fprintf('    Saved: Ranking_Radar\n');
        
        %% 6. Detailed Ranking Table Image
        fig6 = figure('Position', [100, 100, 1200, 800], 'Color', 'w', 'Visible', 'off');
        axis off;
        
        % Create table data
        table_data = cell(num_functions + 2, num_algorithms + 1);
        table_data{1, 1} = 'Function';
        for j = 1:num_algorithms
            table_data{1, j + 1} = Algorithm_Names{j};
        end
        
        for i = 1:num_functions
            table_data{i + 1, 1} = sprintf('F%d', Function_IDs(i));
            for j = 1:num_algorithms
                table_data{i + 1, j + 1} = sprintf('%d', Rankings(i, j));
            end
        end
        
        table_data{num_functions + 2, 1} = 'Avg Rank';
        for j = 1:num_algorithms
            table_data{num_functions + 2, j + 1} = sprintf('%.3f', Avg_Rank(j));
        end
        
        % Draw table
        uitable('Data', table_data, ...
            'Position', [50, 50, 1100, 700], ...
            'ColumnWidth', repmat({90}, 1, num_algorithms + 1), ...
            'FontSize', 10);
        
        title(sprintf('Complete Ranking Table (D=%d)', dim), 'FontSize', 16, 'FontWeight', 'bold', 'Position', [0.5, 0.95]);
        
        % Save
        base_filename = sprintf('%s/Ranking_Table', dim_folder);
        print(fig6, [base_filename, '.png'], '-dpng', '-r300');
        close(fig6);
        fprintf('    Saved: Ranking_Table\n');
    end
    
    fprintf('\nAll ranking images saved to: Results_Rankings/\n');
end
