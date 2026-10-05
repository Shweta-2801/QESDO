%___________________________________________________________________%
%  Grey Wolf Optimizer (GWO)                                       %
%                                                                   %
%  Reference:                                                       %
%  Mirjalili, S., Mirjalili, S. M., & Lewis, A. (2014).             %
%  Grey Wolf Optimizer.                                             %
%  Advances in Engineering Software, 69, 46-61.                     %
%___________________________________________________________________%

function [Alpha_pos, Alpha_score, Convergence_curve] = GWO(SearchAgents_no, Max_iter, lb, ub, dim, fobj)
    
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
    
    % Initialize alpha, beta, and delta positions
    Alpha_pos = zeros(1, dim);
    Alpha_score = inf;
    
    Beta_pos = zeros(1, dim);
    Beta_score = inf;
    
    Delta_pos = zeros(1, dim);
    Delta_score = inf;
    
    % Initialize the positions of search agents
    Positions = initialization(SearchAgents_no, dim, ub, lb);
    
    Convergence_curve = zeros(1, Max_iter);
    
    t = 0;  % Loop counter
    
    % Main loop
    while t < Max_iter
        for i = 1:size(Positions, 1)
            
            % Return back the search agents that go beyond the boundaries
            Flag4ub = Positions(i, :) > ub;
            Flag4lb = Positions(i, :) < lb;
            Positions(i, :) = (Positions(i, :) .* (~(Flag4ub + Flag4lb))) + ub .* Flag4ub + lb .* Flag4lb;
            
            % Calculate objective function
            fitness = fobj(Positions(i, :));
            
            % Update Alpha, Beta, and Delta
            if fitness < Alpha_score
                Alpha_score = fitness;
                Alpha_pos = Positions(i, :);
            end
            
            if fitness > Alpha_score && fitness < Beta_score
                Beta_score = fitness;
                Beta_pos = Positions(i, :);
            end
            
            if fitness > Alpha_score && fitness > Beta_score && fitness < Delta_score
                Delta_score = fitness;
                Delta_pos = Positions(i, :);
            end
        end
        
        a = 2 - t * (2 / Max_iter);  % a decreases linearly from 2 to 0
        
        % Update the Position of search agents
        for i = 1:size(Positions, 1)
            for j = 1:size(Positions, 2)
                
                r1 = rand();
                r2 = rand();
                
                A1 = 2 * a * r1 - a;
                C1 = 2 * r2;
                
                D_alpha = abs(C1 * Alpha_pos(j) - Positions(i, j));
                X1 = Alpha_pos(j) - A1 * D_alpha;
                
                r1 = rand();
                r2 = rand();
                
                A2 = 2 * a * r1 - a;
                C2 = 2 * r2;
                
                D_beta = abs(C2 * Beta_pos(j) - Positions(i, j));
                X2 = Beta_pos(j) - A2 * D_beta;
                
                r1 = rand();
                r2 = rand();
                
                A3 = 2 * a * r1 - a;
                C3 = 2 * r2;
                
                D_delta = abs(C3 * Delta_pos(j) - Positions(i, j));
                X3 = Delta_pos(j) - A3 * D_delta;
                
                Positions(i, j) = (X1 + X2 + X3) / 3;
            end
        end
        t = t + 1;
        Convergence_curve(t) = Alpha_score;
    end
end
