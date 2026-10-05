%___________________________________________________________________%
%  Save Results to Excel                                            %
%                                                                   %
%  This function exports all experimental results to Excel files:   %
%  - Complete results with Mean, Std, Best, Worst, Median           %
%  - Separate sheets for each dimension                             %
%  - Summary statistics and rankings                                %
%___________________________________________________________________%

function SaveResultsToExcel(Results_Best, Results_Mean, Results_Std, Results_Worst, Results_Median, ...
    All_Fitness, Algorithm_Names, Function_IDs, Dimensions)
    
    % Create output directory
    if ~exist('Results_Excel', 'dir')
        mkdir('Results_Excel');
    end
    
    num_functions = length(Function_IDs);
    num_algorithms = length(Algorithm_Names);
    num_dims = length(Dimensions);
    
    fprintf('Saving results to Excel...\n');
    
    %% ==================== MAIN RESULTS FILE ====================
    excel_file = 'Results_Excel/QESDO_Complete_Results.xlsx';
    
    % Delete existing file if present
    if exist(excel_file, 'file')
        delete(excel_file);
    end
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        sheet_name = sprintf('D=%d', dim);
        
        %% Create header row
        header = {'Function'};
        for alg_idx = 1:num_algorithms
            header = [header, {sprintf('%s_Mean', Algorithm_Names{alg_idx}), ...
                              sprintf('%s_Std', Algorithm_Names{alg_idx}), ...
                              sprintf('%s_Best', Algorithm_Names{alg_idx}), ...
                              sprintf('%s_Worst', Algorithm_Names{alg_idx}), ...
                              sprintf('%s_Median', Algorithm_Names{alg_idx})}];
        end
        
        %% Create data matrix
        data = cell(num_functions + 1, 1 + 5*num_algorithms);
        data(1, :) = header;
        
        for func_idx = 1:num_functions
            data{func_idx + 1, 1} = sprintf('F%d', Function_IDs(func_idx));
            
            for alg_idx = 1:num_algorithms
                col_start = 2 + (alg_idx - 1) * 5;
                data{func_idx + 1, col_start} = Results_Mean(func_idx, alg_idx, dim_idx);
                data{func_idx + 1, col_start + 1} = Results_Std(func_idx, alg_idx, dim_idx);
                data{func_idx + 1, col_start + 2} = Results_Best(func_idx, alg_idx, dim_idx);
                data{func_idx + 1, col_start + 3} = Results_Worst(func_idx, alg_idx, dim_idx);
                data{func_idx + 1, col_start + 4} = Results_Median(func_idx, alg_idx, dim_idx);
            end
        end
        
        %% Write to Excel
        writecell(data, excel_file, 'Sheet', sheet_name);
        fprintf('  Saved sheet: %s\n', sheet_name);
    end
    
    %% ==================== RANKINGS SHEET ====================
    sheet_name = 'Rankings';
    
    % Calculate rankings for each dimension
    all_rankings = {};
    row = 1;
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        % Add dimension header
        all_rankings{row, 1} = sprintf('Dimension D = %d', dim);
        row = row + 1;
        
        % Add column headers
        all_rankings{row, 1} = 'Function';
        for alg_idx = 1:num_algorithms
            all_rankings{row, alg_idx + 1} = Algorithm_Names{alg_idx};
        end
        row = row + 1;
        
        % Calculate rankings for each function
        Rankings = zeros(num_functions, num_algorithms);
        for func_idx = 1:num_functions
            [~, sorted_idx] = sort(Results_Mean(func_idx, :, dim_idx));
            for rank = 1:num_algorithms
                Rankings(func_idx, sorted_idx(rank)) = rank;
            end
            
            all_rankings{row, 1} = sprintf('F%d', Function_IDs(func_idx));
            for alg_idx = 1:num_algorithms
                all_rankings{row, alg_idx + 1} = Rankings(func_idx, alg_idx);
            end
            row = row + 1;
        end
        
        % Add average rank
        all_rankings{row, 1} = 'Average Rank';
        Avg_Rank = mean(Rankings, 1);
        for alg_idx = 1:num_algorithms
            all_rankings{row, alg_idx + 1} = Avg_Rank(alg_idx);
        end
        row = row + 2;  % Extra blank row between dimensions
    end
    
    writecell(all_rankings, excel_file, 'Sheet', sheet_name);
    fprintf('  Saved sheet: %s\n', sheet_name);
    
    %% ==================== MEAN ONLY SHEET (for easy comparison) ====================
    sheet_name = 'Mean_Comparison';
    
    mean_data = cell(num_functions * num_dims + num_dims + 1, num_algorithms + 2);
    row = 1;
    
    % Header
    mean_data{row, 1} = 'Dimension';
    mean_data{row, 2} = 'Function';
    for alg_idx = 1:num_algorithms
        mean_data{row, alg_idx + 2} = Algorithm_Names{alg_idx};
    end
    row = row + 1;
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        for func_idx = 1:num_functions
            mean_data{row, 1} = dim;
            mean_data{row, 2} = sprintf('F%d', Function_IDs(func_idx));
            
            for alg_idx = 1:num_algorithms
                mean_data{row, alg_idx + 2} = Results_Mean(func_idx, alg_idx, dim_idx);
            end
            row = row + 1;
        end
    end
    
    writecell(mean_data, excel_file, 'Sheet', sheet_name);
    fprintf('  Saved sheet: %s\n', sheet_name);
    
    %% ==================== STD ONLY SHEET ====================
    sheet_name = 'Std_Comparison';
    
    std_data = cell(num_functions * num_dims + num_dims + 1, num_algorithms + 2);
    row = 1;
    
    % Header
    std_data{row, 1} = 'Dimension';
    std_data{row, 2} = 'Function';
    for alg_idx = 1:num_algorithms
        std_data{row, alg_idx + 2} = Algorithm_Names{alg_idx};
    end
    row = row + 1;
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        for func_idx = 1:num_functions
            std_data{row, 1} = dim;
            std_data{row, 2} = sprintf('F%d', Function_IDs(func_idx));
            
            for alg_idx = 1:num_algorithms
                std_data{row, alg_idx + 2} = Results_Std(func_idx, alg_idx, dim_idx);
            end
            row = row + 1;
        end
    end
    
    writecell(std_data, excel_file, 'Sheet', sheet_name);
    fprintf('  Saved sheet: %s\n', sheet_name);
    
    %% ==================== ALL RUNS DATA ====================
    % Save all 30 runs for each function/algorithm combination
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        sheet_name = sprintf('AllRuns_D%d', dim);
        
        % Determine number of runs from data
        sample_data = All_Fitness{1, 1, dim_idx};
        num_runs = length(sample_data);
        
        % Create header
        all_runs_data = cell(num_functions * num_runs + num_functions + 1, num_algorithms + 2);
        row = 1;
        
        all_runs_data{row, 1} = 'Function';
        all_runs_data{row, 2} = 'Run';
        for alg_idx = 1:num_algorithms
            all_runs_data{row, alg_idx + 2} = Algorithm_Names{alg_idx};
        end
        row = row + 1;
        
        for func_idx = 1:num_functions
            for run = 1:num_runs
                all_runs_data{row, 1} = sprintf('F%d', Function_IDs(func_idx));
                all_runs_data{row, 2} = run;
                
                for alg_idx = 1:num_algorithms
                    fitness_data = All_Fitness{func_idx, alg_idx, dim_idx};
                    all_runs_data{row, alg_idx + 2} = fitness_data(run);
                end
                row = row + 1;
            end
        end
        
        writecell(all_runs_data, excel_file, 'Sheet', sheet_name);
        fprintf('  Saved sheet: %s\n', sheet_name);
    end
    
    fprintf('Excel file saved to: %s\n\n', excel_file);
    
    %% ==================== SEPARATE CSV FILES ====================
    fprintf('Saving CSV files...\n');
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        % Mean results CSV
        csv_file = sprintf('Results_Excel/Mean_Results_D%d.csv', dim);
        fid = fopen(csv_file, 'w');
        
        % Header
        fprintf(fid, 'Function');
        for alg_idx = 1:num_algorithms
            fprintf(fid, ',%s', Algorithm_Names{alg_idx});
        end
        fprintf(fid, '\n');
        
        % Data
        for func_idx = 1:num_functions
            fprintf(fid, 'F%d', Function_IDs(func_idx));
            for alg_idx = 1:num_algorithms
                fprintf(fid, ',%e', Results_Mean(func_idx, alg_idx, dim_idx));
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
        fprintf('  Saved: %s\n', csv_file);
        
        % Std results CSV
        csv_file = sprintf('Results_Excel/Std_Results_D%d.csv', dim);
        fid = fopen(csv_file, 'w');
        
        % Header
        fprintf(fid, 'Function');
        for alg_idx = 1:num_algorithms
            fprintf(fid, ',%s', Algorithm_Names{alg_idx});
        end
        fprintf(fid, '\n');
        
        % Data
        for func_idx = 1:num_functions
            fprintf(fid, 'F%d', Function_IDs(func_idx));
            for alg_idx = 1:num_algorithms
                fprintf(fid, ',%e', Results_Std(func_idx, alg_idx, dim_idx));
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
        fprintf('  Saved: %s\n', csv_file);
    end
    
    fprintf('\nAll Excel and CSV files saved successfully!\n');
end
