%___________________________________________________________________%
%  Save Individual Box Plots for Every Function                     %
%                                                                   %
%  This function generates and saves individual box plot figures    %
%  for each benchmark function comparing all algorithms:            %
%  - PNG (high resolution)                                          %
%  - FIG (MATLAB figure file)                                       %
%  - EPS (for LaTeX publications)                                   %
%___________________________________________________________________%

function SaveBoxPlots(All_Fitness, Algorithm_Names, Function_IDs, Dimensions)
    
    % Create output directory
    if ~exist('Results_BoxPlots', 'dir')
        mkdir('Results_BoxPlots');
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
    
    % Function names for titles
    func_names = {
        'F1: Sphere', 'F2: Schwefel 2.22', 'F3: Schwefel 1.2', 'F4: Schwefel 2.21', ...
        'F5: Rosenbrock', 'F6: Step', 'F7: Quartic', 'F8: Schwefel 2.26', ...
        'F9: Rastrigin', 'F10: Ackley', 'F11: Griewank', 'F12: Penalized 1', ...
        'F13: Penalized 2', 'F14: Shekel Foxholes', 'F15: Kowalik', 'F16: Six-Hump Camel', ...
        'F17: Branin', 'F18: Goldstein-Price', 'F19: Hartmann 3D', 'F20: Hartmann 6D', ...
        'F21: Shekel 5', 'F22: Shekel 7', 'F23: Shekel 10'
    };
    
    fprintf('Generating individual box plots...\n');
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        % Create dimension-specific subdirectory
        dim_folder = sprintf('Results_BoxPlots/D%d', dim);
        if ~exist(dim_folder, 'dir')
            mkdir(dim_folder);
        end
        
        fprintf('  Dimension D = %d:\n', dim);
        
        for func_idx = 1:num_functions
            func_id = Function_IDs(func_idx);
            
            % Get function name
            if func_id <= length(func_names)
                func_name = func_names{func_id};
            else
                func_name = sprintf('F%d', func_id);
            end
            
            % Create figure
            fig = figure('Position', [100, 100, 900, 600], 'Color', 'w', 'Visible', 'off');
            
            % Prepare data for boxplot
            all_data = [];
            group_labels = [];
            
            for alg_idx = 1:num_algorithms
                fitness_data = All_Fitness{func_idx, alg_idx, dim_idx};
                fitness_data = fitness_data(:);  % Ensure column vector
                all_data = [all_data; fitness_data];
                group_labels = [group_labels; repmat(alg_idx, length(fitness_data), 1)];
            end
            
            % Create boxplot
            h = boxplot(all_data, group_labels, ...
                'Labels', Algorithm_Names, ...
                'Colors', colors(1:num_algorithms, :), ...
                'Symbol', 'r+', ...
                'Widths', 0.6);
            
            % Customize box colors
            boxes = findobj(gca, 'Tag', 'Box');
            for j = 1:length(boxes)
                alg_idx = num_algorithms - j + 1;  % Reverse order
                patch(get(boxes(j), 'XData'), get(boxes(j), 'YData'), ...
                    colors(alg_idx, :), 'FaceAlpha', 0.4);
            end
            
            % Set box line properties
            set(findobj(gca, 'Type', 'Line'), 'LineWidth', 1.5);
            
            % Formatting
            xlabel('Algorithm', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel('Fitness Value', 'FontSize', 14, 'FontWeight', 'bold');
            
            % Determine actual dimension for title
            if func_id >= 14
                [~, ~, actual_dim, ~] = Get_Functions_details(func_id);
                title_str = sprintf('%s (D=%d) - Box Plot Comparison', func_name, actual_dim);
            else
                title_str = sprintf('%s (D=%d) - Box Plot Comparison', func_name, dim);
            end
            title(title_str, 'FontSize', 16, 'FontWeight', 'bold');
            
            % Rotate x-axis labels
            xtickangle(30);
            
            % Grid
            grid on;
            box on;
            set(gca, 'FontSize', 12, 'LineWidth', 1.2);
            
            % Add statistical annotation (best algorithm)
            means = zeros(1, num_algorithms);
            for alg_idx = 1:num_algorithms
                means(alg_idx) = mean(All_Fitness{func_idx, alg_idx, dim_idx});
            end
            [~, best_idx] = min(means);
            
            % Add text annotation for best algorithm
            annotation('textbox', [0.15, 0.85, 0.3, 0.08], ...
                'String', sprintf('Best: %s', Algorithm_Names{best_idx}), ...
                'FontSize', 12, 'FontWeight', 'bold', ...
                'BackgroundColor', [0.9, 1, 0.9], ...
                'EdgeColor', [0, 0.5, 0], ...
                'FitBoxToText', 'on');
            
            % Save in multiple formats
            base_filename = sprintf('%s/F%d_BoxPlot', dim_folder, func_id);
            
            % PNG (high resolution)
            print(fig, [base_filename, '.png'], '-dpng', '-r300');
            
            % FIG (MATLAB figure)
            savefig(fig, [base_filename, '.fig']);
            
            % EPS (for LaTeX)
            print(fig, [base_filename, '.eps'], '-depsc2');
            
            % Close figure to free memory
            close(fig);
            
            fprintf('    Saved: F%d\n', func_id);
        end
        
        %% Create combined box plot figures
        fprintf('  Creating combined box plots...\n');
        
        % Unimodal functions (F1-F7)
        unimodal_idx = find(Function_IDs >= 1 & Function_IDs <= 7);
        if ~isempty(unimodal_idx)
            createCombinedBoxPlot(All_Fitness, Algorithm_Names, Function_IDs, unimodal_idx, ...
                dim_idx, dim, colors, func_names, ...
                [dim_folder, '/Combined_BoxPlot_Unimodal'], 'Unimodal Functions');
            fprintf('    Saved: Combined_BoxPlot_Unimodal\n');
        end
        
        % Multimodal functions (F8-F13)
        multimodal_idx = find(Function_IDs >= 8 & Function_IDs <= 13);
        if ~isempty(multimodal_idx)
            createCombinedBoxPlot(All_Fitness, Algorithm_Names, Function_IDs, multimodal_idx, ...
                dim_idx, dim, colors, func_names, ...
                [dim_folder, '/Combined_BoxPlot_Multimodal'], 'Multimodal Functions');
            fprintf('    Saved: Combined_BoxPlot_Multimodal\n');
        end
        
        % Fixed-dimension functions (F14-F23)
        fixeddim_idx = find(Function_IDs >= 14 & Function_IDs <= 23);
        if ~isempty(fixeddim_idx)
            createCombinedBoxPlot(All_Fitness, Algorithm_Names, Function_IDs, fixeddim_idx, ...
                dim_idx, dim, colors, func_names, ...
                [dim_folder, '/Combined_BoxPlot_FixedDim'], 'Fixed-Dimension Functions');
            fprintf('    Saved: Combined_BoxPlot_FixedDim\n');
        end
        
        % All functions
        createCombinedBoxPlot(All_Fitness, Algorithm_Names, Function_IDs, 1:num_functions, ...
            dim_idx, dim, colors, func_names, ...
            [dim_folder, '/Combined_BoxPlot_All'], 'All Functions');
        fprintf('    Saved: Combined_BoxPlot_All\n');
    end
    
    fprintf('\nAll box plots saved to: Results_BoxPlots/\n');
end

%% Helper function to create combined box plot figures
function createCombinedBoxPlot(All_Fitness, Algorithm_Names, Function_IDs, func_indices, dim_idx, dim, colors, func_names, filename, title_text)
    
    num_funcs = length(func_indices);
    num_algorithms = length(Algorithm_Names);
    
    % Determine subplot layout
    if num_funcs <= 4
        num_rows = 2; num_cols = 2;
    elseif num_funcs <= 6
        num_rows = 2; num_cols = 3;
    elseif num_funcs <= 9
        num_rows = 3; num_cols = 3;
    elseif num_funcs <= 12
        num_rows = 3; num_cols = 4;
    else
        num_rows = 4; num_cols = 4;
    end
    
    % Create figure
    fig = figure('Position', [50, 50, 320*num_cols, 260*num_rows], 'Color', 'w', 'Visible', 'off');
    
    for i = 1:min(num_funcs, num_rows * num_cols)
        subplot(num_rows, num_cols, i);
        
        func_idx = func_indices(i);
        func_id = Function_IDs(func_idx);
        
        % Prepare data
        all_data = [];
        group_labels = [];
        
        for alg_idx = 1:num_algorithms
            fitness_data = All_Fitness{func_idx, alg_idx, dim_idx};
            fitness_data = fitness_data(:);
            all_data = [all_data; fitness_data];
            group_labels = [group_labels; repmat(alg_idx, length(fitness_data), 1)];
        end
        
        % Create boxplot
        boxplot(all_data, group_labels, ...
            'Labels', Algorithm_Names, ...
            'Colors', colors(1:num_algorithms, :), ...
            'Symbol', 'r+', ...
            'Widths', 0.5);
        
        % Get function name
        if func_id <= length(func_names)
            short_name = func_names{func_id};
        else
            short_name = sprintf('F%d', func_id);
        end
        
        title(short_name, 'FontSize', 9);
        xtickangle(45);
        set(gca, 'FontSize', 7);
        grid on;
        box on;
    end
    
    % Add overall title
    sgtitle(sprintf('%s (D=%d) - Box Plot Comparison', title_text, dim), 'FontSize', 14, 'FontWeight', 'bold');
    
    % Save
    print(fig, [filename, '.png'], '-dpng', '-r300');
    savefig(fig, [filename, '.fig']);
    
    close(fig);
end
