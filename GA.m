%___________________________________________________________________%
%  Genetic Algorithm (GA)                                          %
%                                                                   %
%  Reference:                                                       %
%  Holland, J. H. (1992).                                           %
%  Adaptation in Natural and Artificial Systems.                    %
%  MIT Press.                                                       %
%                                                                   %
%  Goldberg, D. E. (1989).                                          %
%  Genetic Algorithms in Search, Optimization, and Machine Learning.%
%  Addison-Wesley.                                                  %
%___________________________________________________________________%

function [Best_pos, Best_score, Convergence_curve] = GA(N, Max_iter, lb, ub, dim, fobj)
    
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
    
    % GA Parameters
    pc = 0.9;       % Crossover probability
    pm = 0.01;      % Mutation probability
    mu = 0.1;       % Mutation step size (fraction of range)
    elitism = 2;    % Number of elite individuals
    
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
        % Calculate selection probabilities (rank-based)
        [~, sortIdx] = sort(Fit);
        ranks = zeros(N, 1);
        ranks(sortIdx) = N:-1:1;
        selectProb = ranks / sum(ranks);
        
        % Create new population
        newX = zeros(N, dim);
        newFit = zeros(N, 1);
        
        % Elitism: keep best individuals
        [~, eliteIdx] = sort(Fit);
        for i = 1:elitism
            newX(i, :) = X(eliteIdx(i), :);
            newFit(i) = Fit(eliteIdx(i));
        end
        
        % Generate rest of population
        for i = elitism+1:2:N
            % Selection (roulette wheel)
            parent1Idx = rouletteWheel(selectProb);
            parent2Idx = rouletteWheel(selectProb);
            
            parent1 = X(parent1Idx, :);
            parent2 = X(parent2Idx, :);
            
            % Crossover (SBX - Simulated Binary Crossover)
            if rand < pc
                [child1, child2] = SBXCrossover(parent1, parent2, lb, ub);
            else
                child1 = parent1;
                child2 = parent2;
            end
            
            % Mutation (Polynomial Mutation)
            child1 = polynomialMutation(child1, pm, lb, ub);
            child2 = polynomialMutation(child2, pm, lb, ub);
            
            % Boundary handling
            child1 = min(max(child1, lb), ub);
            child2 = min(max(child2, lb), ub);
            
            % Store offspring
            newX(i, :) = child1;
            if i + 1 <= N
                newX(i + 1, :) = child2;
            end
        end
        
        % Evaluate new population
        for i = elitism+1:N
            newFit(i) = fobj(newX(i, :));
        end
        
        % Replace population
        X = newX;
        Fit = newFit;
        
        % Update best
        [minFit, minIdx] = min(Fit);
        if minFit < Best_score
            Best_score = minFit;
            Best_pos = X(minIdx, :);
        end
        
        Convergence_curve(t) = Best_score;
    end
end

function idx = rouletteWheel(prob)
    cumProb = cumsum(prob);
    r = rand;
    idx = find(cumProb >= r, 1, 'first');
    if isempty(idx)
        idx = length(prob);
    end
end

function [child1, child2] = SBXCrossover(parent1, parent2, lb, ub)
    eta_c = 20;  % Distribution index
    dim = length(parent1);
    child1 = zeros(1, dim);
    child2 = zeros(1, dim);
    
    for j = 1:dim
        if rand <= 0.5
            if abs(parent1(j) - parent2(j)) > 1e-14
                if parent1(j) < parent2(j)
                    y1 = parent1(j);
                    y2 = parent2(j);
                else
                    y1 = parent2(j);
                    y2 = parent1(j);
                end
                
                beta = 1 + (2 * (y1 - lb(j)) / (y2 - y1));
                alpha = 2 - beta^(-(eta_c + 1));
                
                u = rand;
                if u <= 1/alpha
                    betaq = (u * alpha)^(1/(eta_c + 1));
                else
                    betaq = (1/(2 - u * alpha))^(1/(eta_c + 1));
                end
                
                child1(j) = 0.5 * ((y1 + y2) - betaq * (y2 - y1));
                child2(j) = 0.5 * ((y1 + y2) + betaq * (y2 - y1));
            else
                child1(j) = parent1(j);
                child2(j) = parent2(j);
            end
        else
            child1(j) = parent1(j);
            child2(j) = parent2(j);
        end
    end
end

function child = polynomialMutation(parent, pm, lb, ub)
    eta_m = 20;  % Distribution index
    dim = length(parent);
    child = parent;
    
    for j = 1:dim
        if rand < pm
            y = parent(j);
            delta1 = (y - lb(j)) / (ub(j) - lb(j));
            delta2 = (ub(j) - y) / (ub(j) - lb(j));
            
            u = rand;
            if u < 0.5
                xy = 1 - delta1;
                val = 2 * u + (1 - 2 * u) * xy^(eta_m + 1);
                deltaq = val^(1/(eta_m + 1)) - 1;
            else
                xy = 1 - delta2;
                val = 2 * (1 - u) + 2 * (u - 0.5) * xy^(eta_m + 1);
                deltaq = 1 - val^(1/(eta_m + 1));
            end
            
            child(j) = y + deltaq * (ub(j) - lb(j));
        end
    end
end
