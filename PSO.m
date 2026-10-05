%___________________________________________________________________%
%  Particle Swarm Optimization (PSO)                               %
%                                                                   %
%  Reference:                                                       %
%  Kennedy, J., & Eberhart, R. (1995).                              %
%  Particle swarm optimization.                                     %
%  Proceedings of ICNN'95 - International Conference on Neural     %
%  Networks, 4, 1942-1948.                                          %
%                                                                   %
%  Shi, Y., & Eberhart, R. (1998).                                  %
%  A modified particle swarm optimizer.                             %
%  IEEE International Conference on Evolutionary Computation.       %
%___________________________________________________________________%

function [Best_pos, Best_score, Convergence_curve] = PSO(N, Max_iter, lb, ub, dim, fobj)
    
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
    
    % PSO Parameters
    w_max = 0.9;    % Maximum inertia weight
    w_min = 0.4;    % Minimum inertia weight
    c1 = 2.0;       % Cognitive coefficient
    c2 = 2.0;       % Social coefficient
    
    % Velocity limits
    Vmax = 0.2 * (ub - lb);
    Vmin = -Vmax;
    
    % Initialize population
    X = initialization(N, dim, ub, lb);
    V = zeros(N, dim);  % Initialize velocities
    
    % Evaluate initial fitness
    Fit = zeros(N, 1);
    for i = 1:N
        Fit(i) = fobj(X(i, :));
    end
    
    % Initialize personal best
    pBest = X;
    pBest_score = Fit;
    
    % Initialize global best
    [Best_score, bestIdx] = min(Fit);
    Best_pos = X(bestIdx, :);
    
    % Initialize convergence curve
    Convergence_curve = zeros(1, Max_iter);
    
    %% Main Loop
    for t = 1:Max_iter
        % Update inertia weight
        w = w_max - (w_max - w_min) * t / Max_iter;
        
        for i = 1:N
            % Update velocity
            r1 = rand(1, dim);
            r2 = rand(1, dim);
            
            V(i, :) = w * V(i, :) + ...
                      c1 * r1 .* (pBest(i, :) - X(i, :)) + ...
                      c2 * r2 .* (Best_pos - X(i, :));
            
            % Velocity clamping
            V(i, :) = min(max(V(i, :), Vmin), Vmax);
            
            % Update position
            X(i, :) = X(i, :) + V(i, :);
            
            % Boundary handling
            X(i, :) = min(max(X(i, :), lb), ub);
            
            % Evaluate fitness
            Fit(i) = fobj(X(i, :));
            
            % Update personal best
            if Fit(i) < pBest_score(i)
                pBest(i, :) = X(i, :);
                pBest_score(i) = Fit(i);
                
                % Update global best
                if Fit(i) < Best_score
                    Best_score = Fit(i);
                    Best_pos = X(i, :);
                end
            end
        end
        
        Convergence_curve(t) = Best_score;
    end
end
