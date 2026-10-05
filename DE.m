%___________________________________________________________________%
%  Differential Evolution (DE/rand/1/bin)                          %
%                                                                   %
%  Reference:                                                       %
%  Storn, R., & Price, K. (1997).                                   %
%  Differential Evolution - A Simple and Efficient Heuristic for   %
%  Global Optimization over Continuous Spaces.                      %
%  Journal of Global Optimization, 11(4), 341-359.                  %
%___________________________________________________________________%

function [Best_pos, Best_score, Convergence_curve] = DE(N, Max_iter, lb, ub, dim, fobj)
    
    % Ensure bounds are row vectors
    if numel(lb) == 1
        lb = repmat(lb, 1, dim);
    end
    if numel(ub) == 1
        ub = repmat(ub, 1, dim);
    end
    lb = lb(:)';
    ub = ub(:)';
    
    % Adjust dim if bounds have different length
    if length(lb) ~= dim
        dim = length(lb);
    end
    
    % DE Parameters
    F = 0.5;     % Scaling factor
    CR = 0.9;    % Crossover rate
    
    % Initialize population
    X = initialization(N, dim, ub, lb);
    
    % Evaluate initial fitness
    Fit = zeros(N, 1);
    for i = 1:N
        Fit(i) = fobj(X(i, :));
    end
    
    % Find best solution
    [Best_score, bestIdx] = min(Fit);
    Best_pos = X(bestIdx, :);
    
    % Initialize convergence curve
    Convergence_curve = zeros(1, Max_iter);
    
    %% Main Loop
    for t = 1:Max_iter
        for i = 1:N
            % Mutation: DE/rand/1
            candidates = 1:N;
            candidates(i) = [];
            idx = candidates(randperm(length(candidates), 3));
            r1 = idx(1);
            r2 = idx(2);
            r3 = idx(3);
            
            % Mutant vector
            V = X(r1, :) + F * (X(r2, :) - X(r3, :));
            
            % Boundary handling
            V = min(max(V, lb), ub);
            
            % Crossover: binomial
            U = X(i, :);
            jrand = randi(dim);
            for j = 1:dim
                if rand <= CR || j == jrand
                    U(j) = V(j);
                end
            end
            
            % Selection
            Fit_U = fobj(U);
            if Fit_U <= Fit(i)
                X(i, :) = U;
                Fit(i) = Fit_U;
                
                % Update best
                if Fit_U < Best_score
                    Best_score = Fit_U;
                    Best_pos = U;
                end
            end
        end
        
        Convergence_curve(t) = Best_score;
    end
end
