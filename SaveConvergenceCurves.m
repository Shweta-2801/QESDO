%___________________________________________________________________%
%  Save Separate Convergence Curves for Every Function              %
%                                                                   %
%  This function generates and saves individual convergence curve   %
%  figures for each benchmark function in multiple formats:         %
%  - PNG (high resolution)                                          %
%  - FIG (MATLAB figure file)                                       %
%  - EPS (for LaTeX publications)                                   %
%___________________________________________________________________%

function SaveConvergenceCurves(Convergence_Curves, Algorithm_Names, Function_IDs, Dimensions, Max_iteration)
    
    % Create output directory
    if ~exist('Results_Convergence', 'dir')
        mkdir('Results_Convergence');
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
    
    % Define line styles and markers
    lineStyles = {'-', '--', '-.', ':', '-', '--', '-.'};
    markers = {'o', 's', 'd', '^', 'v', '<', '>', 'p', 'h'};
    
    % Function names for titles
    func_names = {
        'F1: Sphere', 'F2: Schwefel 2.22', 'F3: Schwefel 1.2', 'F4: Schwefel 2.21', ...
        'F5: Rosenbrock', 'F6: Step', 'F7: Quartic', 'F8: Schwefel 2.26', ...
        'F9: Rastrigin', 'F10: Ackley', 'F11: Griewank', 'F12: Penalized 1', ...
        'F13: Penalized 2', 'F14: Shekel Foxholes', 'F15: Kowalik', 'F16: Six-Hump Camel', ...
        'F17: Branin', 'F18: Goldstein-Price', 'F19: Hartmann 3D', 'F20: Hartmann 6D', ...
        'F21: Shekel 5', 'F22: Shekel 7', 'F23: Shekel 10'
    };
    
    fprintf('Generating individual convergence curves...\n');
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        % Create dimension-specific subdirectory
        dim_folder = sprintf('Results_Convergence/D%d', dim);
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
            fig = figure('Position', [100, 100, 800, 600], 'Color', 'w', 'Visible', 'off');
            
            hold on;
            
            % Plot each algorithm
            plot_handles = zeros(1, num_algorithms);
            for alg_idx = 1:num_algorithms
                curve = Convergence_Curves{func_idx, alg_idx, dim_idx};
                
                % Ensure curve has correct length
                if length(curve) ~= Max_iteration
                    % Interpolate if needed
                    x_old = linspace(1, Max_iteration, length(curve));
                    x_new = 1:Max_iteration;
                    curve = interp1(x_old, curve, x_new, 'linear', 'extrap');
                end
                
                % Calculate marker positions (10 markers evenly distributed)
                num_markers = 10;
                marker_idx = round(linspace(1, Max_iteration, num_markers));
                
                % Plot line
                h = semilogy(1:Max_iteration, curve, ...
                    'Color', colors(alg_idx, :), ...
                    'LineWidth', 2, ...
                    'LineStyle', lineStyles{mod(alg_idx-1, length(lineStyles)) + 1});
                plot_handles(alg_idx) = h;
                
                % Add markers
                semilogy(marker_idx, curve(marker_idx), ...
                    'Color', colors(alg_idx, :), ...
                    'LineStyle', 'none', ...
                    'Marker', markers{mod(alg_idx-1, length(markers)) + 1}, ...
                    'MarkerSize', 8, ...
                    'MarkerFaceColor', colors(alg_idx, :), ...
                    'HandleVisibility', 'off');
            end
            
            hold off;
            
            % Formatting
            xlabel('Iteration', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel('Best Fitness (log scale)', 'FontSize', 14, 'FontWeight', 'bold');
            
            % Determine actual dimension for title
            if func_id >= 14
                [~, ~, actual_dim, ~] = Get_Functions_details(func_id);
                title_str = sprintf('%s (D=%d)', func_name, actual_dim);
            else
                title_str = sprintf('%s (D=%d)', func_name, dim);
            end
            title(title_str, 'FontSize', 16, 'FontWeight', 'bold');
            
            % Legend
            legend(plot_handles, Algorithm_Names, ...
                'Location', 'northeast', ...
                'FontSize', 11, ...
                'Box', 'on');
            
            % Grid and box
            grid on;
            box on;
            set(gca, 'FontSize', 12, 'LineWidth', 1.2);
            
            % Tight axis
            axis tight;
            
            % Save in multiple formats
            base_filename = sprintf('%s/F%d_Convergence', dim_folder, func_id);
            
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
    end
    
    %% ==================== CREATE COMBINED FIGURES ====================
    fprintf('\n  Creating combined figures...\n');
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        dim_folder = sprintf('Results_Convergence/D%d', dim);
        
        % Unimodal functions (F1-F7) - if available
        unimodal_funcs = Function_IDs(Function_IDs >= 1 & Function_IDs <= 7);
        if ~isempty(unimodal_funcs)
            createCombinedFigure(Convergence_Curves, Algorithm_Names, unimodal_funcs, ...
                dim_idx, dim, Max_iteration, colors, lineStyles, func_names, ...
                [dim_folder, '/Combined_Unimodal'], 'Unimodal Functions');
            fprintf('    Saved: Combined_Unimodal\n');
        end
        
        % Multimodal functions (F8-F13) - if available
        multimodal_funcs = Function_IDs(Function_IDs >= 8 & Function_IDs <= 13);
        if ~isempty(multimodal_funcs)
            createCombinedFigure(Convergence_Curves, Algorithm_Names, multimodal_funcs, ...
                dim_idx, dim, Max_iteration, colors, lineStyles, func_names, ...
                [dim_folder, '/Combined_Multimodal'], 'Multimodal Functions');
            fprintf('    Saved: Combined_Multimodal\n');
        end
        
        % Fixed-dimension functions (F14-F23) - if available
        fixeddim_funcs = Function_IDs(Function_IDs >= 14 & Function_IDs <= 23);
        if ~isempty(fixeddim_funcs)
            createCombinedFigure(Convergence_Curves, Algorithm_Names, fixeddim_funcs, ...
                dim_idx, dim, Max_iteration, colors, lineStyles, func_names, ...
                [dim_folder, '/Combined_FixedDim'], 'Fixed-Dimension Functions');
            fprintf('    Saved: Combined_FixedDim\n');
        end
        
        % All functions combined
        createCombinedFigure(Convergence_Curves, Algorithm_Names, Function_IDs, ...
            dim_idx, dim, Max_iteration, colors, lineStyles, func_names, ...
            [dim_folder, '/Combined_All'], 'All Benchmark Functions');
        fprintf('    Saved: Combined_All\n');
    end
    
    fprintf('\nAll convergence curves saved to: Results_Convergence/\n');
end

%% Helper function to create combined subplot figures
function createCombinedFigure(Convergence_Curves, Algorithm_Names, func_ids, dim_idx, dim, Max_iteration, colors, lineStyles, func_names, filename, title_text)
    
    num_funcs = length(func_ids);
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
    fig = figure('Position', [50, 50, 350*num_cols, 280*num_rows], 'Color', 'w', 'Visible', 'off');
    
    for i = 1:min(num_funcs, num_rows * num_cols)
        subplot(num_rows, num_cols, i);
        hold on;
        
        func_id = func_ids(i);
        
        % Find index in original Function_IDs array
        % We need to find which index in Convergence_Curves corresponds to this func_id
        % This assumes func_ids are a subset of the original Function_IDs
        func_idx = find(func_ids == func_id, 1);
        
        for alg_idx = 1:num_algorithms
            curve = Convergence_Curves{func_idx, alg_idx, dim_idx};
            
            if length(curve) ~= Max_iteration
                x_old = linspace(1, Max_iteration, length(curve));
                x_new = 1:Max_iteration;
                curve = interp1(x_old, curve, x_new, 'linear', 'extrap');
            end
            
            semilogy(1:Max_iteration, curve, ...
                'Color', colors(alg_idx, :), ...
                'LineWidth', 1.5, ...
                'LineStyle', lineStyles{mod(alg_idx-1, length(lineStyles)) + 1});
        end
        
        hold off;
        
        % Get function name
        if func_id <= length(func_names)
            short_name = func_names{func_id};
        else
            short_name = sprintf('F%d', func_id);
        end
        
        title(short_name, 'FontSize', 10);
        xlabel('Iteration', 'FontSize', 9);
        ylabel('Fitness', 'FontSize', 9);
        grid on;
        box on;
        set(gca, 'FontSize', 8);
    end
    
    % Add overall title
    sgtitle(sprintf('%s (D=%d)', title_text, dim), 'FontSize', 14, 'FontWeight', 'bold');
    
    % Add legend to the last subplot or create separate legend
    if num_funcs < num_rows * num_cols
        subplot(num_rows, num_cols, num_funcs + 1);
        axis off;
        for alg_idx = 1:num_algorithms
            plot(NaN, NaN, 'Color', colors(alg_idx, :), 'LineWidth', 2, ...
                'LineStyle', lineStyles{mod(alg_idx-1, length(lineStyles)) + 1});
            hold on;
        end
        legend(Algorithm_Names, 'Location', 'best', 'FontSize', 10);
    end
    
    % Save
    print(fig, [filename, '.png'], '-dpng', '-r300');
    savefig(fig, [filename, '.fig']);
    
    close(fig);
end
