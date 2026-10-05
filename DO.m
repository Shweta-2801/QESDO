%___________________________________________________________________%
%  Dandelion Optimizer (DO)                                        %
%                                                                   %
%  Reference:                                                       %
%  Zhao, S., Zhang, T., Ma, S., & Chen, M. (2022).                  %
%  Dandelion Optimizer: A nature-inspired metaheuristic algorithm   %
%  for engineering applications.                                    %
%  Engineering Applications of Artificial Intelligence, 114, 105075.%
%___________________________________________________________________%

function [Best_pos, Best_score, Convergence_curve] = DO(N, Max_iter, lb, ub, dim, fobj)
    
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
        % Calculate alpha (decreasing factor)
        alpha = rand * ((1 / Max_iter^2) * (t^2 - 2*t + 1) + 1 / (Max_iter^2 - 2*Max_iter + 1));
        
        % Population mean
        Xmean = mean(X, 1);
        
        % Brownian motion term
        beta_t = randn;
        
        % Linear ramp factor
        q = (t^2 - 2*t + 1) / (Max_iter^2 - 2*Max_iter + 1) + 1 / (Max_iter^2 - 2*Max_iter + 1);
        
        for i = 1:N
            Xi = X(i, :);
            
            %% Stage 1: Rising Stage (Exploration)
            r = rand * 2;
            if r < 1.5  % Sunny day - vortex rise
                vx = randn;
                vy = randn;
                lnY = exp(randn);  % Lognormal
                randIdx = randi(N);
                Xi_rise = Xi + alpha * vx * vy * lnY * (X(randIdx, :) - Xi);
            else  % Rainy day - local dispersal
                k = 1 - rand * q;
                Xi_rise = Xi * k;
            end
            
            %% Stage 2: Descending Stage (Brownian motion)
            Xi_desc = Xi_rise - alpha * beta_t * (Xmean - alpha * beta_t * Xi_rise);
            
            %% Stage 3: Landing Stage (Levy flight exploitation)
            delta = 2 * t / Max_iter;
            levy = levyFlight(1);
            Xi_land = Best_pos + levy * alpha * (Best_pos - Xi_desc * delta);
            
            % Final position
            Xi_new = Xi_land;
            
            % Boundary handling
            Xi_new = min(max(Xi_new, lb), ub);
            
            % Evaluate new solution
            Fi_new = fobj(Xi_new);
            
            % Greedy selection
            if Fi_new < Fit(i)
                X(i, :) = Xi_new;
                Fit(i) = Fi_new;
                
                % Update best
                if Fi_new < Best_score
                    Best_score = Fi_new;
                    Best_pos = Xi_new;
                end
            end
        end
        
        Convergence_curve(t) = Best_score;
    end
end

function L = levyFlight(s)
    beta = 1.5;
    sigma = (gamma(1 + beta) * sin(pi * beta / 2) / ...
             (gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2)))^(1 / beta);
    u = randn * sigma;
    v = randn;
    L = 0.01 * s * u / (abs(v)^(1 / beta) + 1e-12);
end
