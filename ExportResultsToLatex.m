%___________________________________________________________________%
%  Export Results to LaTeX Tables                                   %
%                                                                   %
%  This function exports the experimental results to LaTeX format   %
%  suitable for journal publications.                               %
%___________________________________________________________________%

function ExportResultsToLatex(Results_Mean, Results_Std, Algorithm_Names, Function_IDs, Dimensions)
    
    num_functions = length(Function_IDs);
    num_algorithms = length(Algorithm_Names);
    num_dims = length(Dimensions);
    
    % Create output directory
    if ~exist('Results_Tables', 'dir')
        mkdir('Results_Tables');
    end
    
    for dim_idx = 1:num_dims
        dim = Dimensions(dim_idx);
        
        %% Generate LaTeX table
        filename = sprintf('Results_Tables/Results_D%d.tex', dim);
        fid = fopen(filename, 'w');
        
        % Table header
        fprintf(fid, '\\begin{table}[htbp]\n');
        fprintf(fid, '\\centering\n');
        fprintf(fid, '\\caption{Comparison results on benchmark functions (D=%d)}\n', dim);
        fprintf(fid, '\\label{tab:results_d%d}\n', dim);
        fprintf(fid, '\\footnotesize\n');
        fprintf(fid, '\\begin{tabular}{l');
        for i = 1:num_algorithms
            fprintf(fid, 'cc');
        end
        fprintf(fid, '}\n');
        fprintf(fid, '\\hline\n');
        
        % Column headers
        fprintf(fid, '\\multirow{2}{*}{Function} ');
        for i = 1:num_algorithms
            fprintf(fid, '& \\multicolumn{2}{c}{%s} ', strrep(Algorithm_Names{i}, '_', '\\_'));
        end
        fprintf(fid, '\\\\\n');
        
        fprintf(fid, ' ');
        for i = 1:num_algorithms
            fprintf(fid, '& Mean & Std ');
        end
        fprintf(fid, '\\\\\n');
        fprintf(fid, '\\hline\n');
        
        % Data rows
        for func_idx = 1:num_functions
            fprintf(fid, 'F%d ', Function_IDs(func_idx));
            
            % Find best mean
            [best_mean, ~] = min(Results_Mean(func_idx, :, dim_idx));
            
            for alg_idx = 1:num_algorithms
                mean_val = Results_Mean(func_idx, alg_idx, dim_idx);
                std_val = Results_Std(func_idx, alg_idx, dim_idx);
                
                % Bold the best result
                if abs(mean_val - best_mean) < 1e-10 * max(abs(best_mean), 1)
                    fprintf(fid, '& \\textbf{%.2e} & \\textbf{%.2e} ', mean_val, std_val);
                else
                    fprintf(fid, '& %.2e & %.2e ', mean_val, std_val);
                end
            end
            fprintf(fid, '\\\\\n');
        end
        
        % Table footer
        fprintf(fid, '\\hline\n');
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\\end{table}\n');
        
        fclose(fid);
        fprintf('LaTeX table saved to: %s\n', filename);
        
        %% Generate CSV file
        csv_filename = sprintf('Results_Tables/Results_D%d.csv', dim);
        fid = fopen(csv_filename, 'w');
        
        % Header
        fprintf(fid, 'Function');
        for i = 1:num_algorithms
            fprintf(fid, ',%s_Mean,%s_Std', Algorithm_Names{i}, Algorithm_Names{i});
        end
        fprintf(fid, '\n');
        
        % Data
        for func_idx = 1:num_functions
            fprintf(fid, 'F%d', Function_IDs(func_idx));
            for alg_idx = 1:num_algorithms
                fprintf(fid, ',%e,%e', Results_Mean(func_idx, alg_idx, dim_idx), ...
                    Results_Std(func_idx, alg_idx, dim_idx));
            end
            fprintf(fid, '\n');
        end
        
        fclose(fid);
        fprintf('CSV file saved to: %s\n', csv_filename);
    end
    
    %% Generate ranking summary table
    filename = 'Results_Tables/Rankings_Summary.tex';
    fid = fopen(filename, 'w');
    
    fprintf(fid, '\\begin{table}[htbp]\n');
    fprintf(fid, '\\centering\n');
    fprintf(fid, '\\caption{Average ranking of algorithms across all benchmark functions}\n');
    fprintf(fid, '\\label{tab:rankings}\n');
    fprintf(fid, '\\begin{tabular}{l');
    for i = 1:num_dims
        fprintf(fid, 'c');
    end
    fprintf(fid, '}\n');
    fprintf(fid, '\\hline\n');
    
    % Header
    fprintf(fid, 'Algorithm ');
    for dim_idx = 1:num_dims
        fprintf(fid, '& D=%d ', Dimensions(dim_idx));
    end
    fprintf(fid, '\\\\\n');
    fprintf(fid, '\\hline\n');
    
    % Calculate and write rankings
    for alg_idx = 1:num_algorithms
        fprintf(fid, '%s ', strrep(Algorithm_Names{alg_idx}, '_', '\\_'));
        
        for dim_idx = 1:num_dims
            Rankings = zeros(num_functions, num_algorithms);
            for func_idx = 1:num_functions
                [~, sorted_idx] = sort(Results_Mean(func_idx, :, dim_idx));
                for rank = 1:num_algorithms
                    Rankings(func_idx, sorted_idx(rank)) = rank;
                end
            end
            avg_rank = mean(Rankings(:, alg_idx));
            fprintf(fid, '& %.2f ', avg_rank);
        end
        fprintf(fid, '\\\\\n');
    end
    
    fprintf(fid, '\\hline\n');
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\\end{table}\n');
    
    fclose(fid);
    fprintf('Rankings table saved to: %s\n', filename);
end
