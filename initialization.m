%___________________________________________________________________%
%  Population Initialization Function                              %
%                                                                   %
%  Generates an initial population of N individuals in dim          %
%  dimensions within the specified bounds.                          %
%___________________________________________________________________%

function Positions = initialization(SearchAgents_no, dim, ub, lb)
    
    % Ensure bounds are row vectors
    if isscalar(lb)
        lb = lb * ones(1, dim);
    end
    if isscalar(ub)
        ub = ub * ones(1, dim);
    end
    
    % Ensure row vectors
    lb = lb(:)';
    ub = ub(:)';
    
    % Handle case where bounds length doesn't match dim
    if length(lb) ~= dim
        if length(lb) == 1
            lb = lb * ones(1, dim);
        else
            % Use the bounds as provided (for fixed-dim functions)
            dim = length(lb);
        end
    end
    if length(ub) ~= dim
        if length(ub) == 1
            ub = ub * ones(1, dim);
        else
            dim = length(ub);
        end
    end
    
    % Initialize positions
    Positions = zeros(SearchAgents_no, dim);
    for i = 1:dim
        Positions(:, i) = rand(SearchAgents_no, 1) .* (ub(i) - lb(i)) + lb(i);
    end
end
