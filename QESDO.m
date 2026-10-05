%___________________________________________________________________%
%  QESDO: Q-learning Enhanced Self-adaptive Dandelion Optimizer    %
%                                                                   %
%  A hybrid metaheuristic that augments the Dandelion Optimizer     %
%  with four mechanisms:                                            %
%     (1) Q-learning driven ADAPTIVE OPERATOR SELECTION             %
%     (2) Opposition-Based Learning (OBL) for initialization        %
%         and elite jumping                                         %
%     (3) A memetic elite LOCAL SEARCH (Gaussian refinement)        %
%     (4) Self-adaptive parameter control for step-size/Levy scale  %
%                                                                   %
%  Reference:                                                       %
%  Base DO: Zhao et al., EAAI 114 (2022) 105075                     %
%___________________________________________________________________%

function [Best_pos, Best_score, Convergence_curve] = QESDO(N, Max_iter, lb, ub, dim, fobj)
    
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
    
    % Minimum population size
    if N < 4
        N = 4;
    end
    
    %% Q-learning hyperparameters
    numStates = 4;      % 4 states based on diversity and improvement
    numActions = 4;     % 4 actions: Rising, Descending, Landing, Memetic LS
    Q = zeros(numStates, numActions);
    alphaQ = 0.6;       % Q-learning rate
    gammaQ = 0.9;       % Discount factor
    eps0 = 0.9;         % Initial epsilon (exploration)
    epsEnd = 0.05;      % Final epsilon
    
    %% OBL / Local Search / Self-adaptive parameters
    Jr = 0.3;           % OBL elite jump probability
    sigma0 = 0.5;       % Initial memetic LS sigma
    smin = 0.001;       % Minimum Levy scale
    smax = 0.5;         % Maximum Levy scale
    s = 0.3;            % Current Levy scale
    alphaStep = 0.5;    % Step factor
    
    %% (1) Opposition-Based Learning Initialization
    % Generate random population
    X = initialization(N, dim, ub, lb);
    
    % Generate opposition population
    OX = repmat(lb, N, 1) + repmat(ub, N, 1) - X;
    
    % Evaluate both populations
    Fit = zeros(N, 1);
    OFit = zeros(N, 1);
    for i = 1:N
        Fit(i) = fobj(X(i, :));
        OFit(i) = fobj(OX(i, :));
    end
    
    % Combine and select best N individuals
    AllX = [X; OX];
    AllF = [Fit; OFit];
    [~, idx] = sort(AllF);
    X = AllX(idx(1:N), :);
    Fit = AllF(idx(1:N));
    
    % Initialize best solution
    [Best_score, bestIdx] = min(Fit);
    Best_pos = X(bestIdx, :);
    EliteX = Best_pos;
    
    % Initialize convergence curve
    Convergence_curve = zeros(1, Max_iter);
    
    % Previous best for improvement tracking
    prevBest = Best_score;
    
    %% Main Loop
    for t = 1:Max_iter
        % Decay epsilon for exploration-exploitation balance
        epsilon = eps0 - (eps0 - epsEnd) * t / Max_iter;
        
        % Calculate population centroid and Brownian term
        Xmean = mean(X, 1);
        beta_t = randn;
        
        % Calculate diversity signal
        div = mean(std(X, 0, 1) ./ (ub - lb + 1e-12));
        
        % Check if improved
        improved = (Best_score < prevBest);
        
        % Encode current state
        state = stateEncode(div, improved);
        
        % Linear ramp factor for DO operations
        q = (t^2 - 2*t + 1) / (Max_iter^2 - 2*Max_iter + 1) + 1 / (Max_iter^2 - 2*Max_iter + 1);
        q = min(max(q, 1e-4), 1);
        
        % Success counter for self-adaptation
        successCount = 0;
        
        %% Update each search agent
        for i = 1:N
            % Epsilon-greedy action selection
            if rand < epsilon
                a = randi(numActions);  % Random action (exploration)
            else
                [~, a] = max(Q(state, :));  % Best action (exploitation)
            end
            
            Xi = X(i, :);
            Xi_new = Xi;
            
            %% Execute selected action
            switch a
                case 1  % A1: DO Rising Stage (Exploration)
                    if rand * 2 < 1.5  % Sunny day
                        vx = randn;
                        vy = randn;
                        lnY = exp(randn);
                        alpha = alphaStep * rand;
                        randIdx = randi(N);
                        Xi_new = Xi + alpha * vx * vy * lnY * (X(randIdx, :) - Xi);
                    else  % Rainy day
                        Xi_new = Xi * (1 - rand * q);
                    end
                    
                case 2  % A2: DO Descending Stage (Brownian Transition)
                    alpha = alphaStep * rand;
                    Xi_new = Xi - alpha * beta_t * (Xmean - alpha * beta_t * Xi);
                    
                case 3  % A3: DO Landing Stage (Levy Exploitation)
                    delta = 2 * t / Max_iter;
                    L = levyFlight(s);
                    Xi_new = EliteX + L * alphaStep * (EliteX - Xi * delta);
                    
                case 4  % A4: Memetic Elite Local Search
                    sigMem = sigma0 * (1 - t / Max_iter) + 1e-6;
                    Xi_new = EliteX + sigMem * randn(1, dim) .* (ub - lb);
            end
            
            % Boundary handling (reflection)
            Xi_new = boundaryHandling(Xi_new, lb, ub);
            
            % Evaluate new solution
            Fi_new = fobj(Xi_new);
            
            % Greedy selection
            if Fi_new < Fit(i)
                X(i, :) = Xi_new;
                Fit(i) = Fi_new;
                reward = 1;
                
                % Update best if improved
                if Fi_new < Best_score
                    Best_score = Fi_new;
                    Best_pos = Xi_new;
                    EliteX = Xi_new;
                    successCount = successCount + 1;
                end
            else
                reward = 0;
            end
            
            % Q-learning update
            stateNext = stateEncode(div, (Best_score < prevBest));
            Q(state, a) = Q(state, a) + alphaQ * (reward + gammaQ * max(Q(stateNext, :)) - Q(state, a));
        end
        
        %% (4) Self-adaptive Levy scale
        rate = successCount / N;
        if rate > 0.2
            s = min(s * 1.2, smax);
        elseif rate < 0.05
            s = max(s * 0.9, smin);
        end
        alphaStep = 0.5 + 0.5 * rand;
        
        %% (2) Opposition-based Elite Jump
        if rand < Jr
            OXe = lb + ub - EliteX;
            OXe = boundaryHandling(OXe, lb, ub);
            OFit_e = fobj(OXe);
            if OFit_e < Best_score
                Best_score = OFit_e;
                Best_pos = OXe;
                EliteX = OXe;
            end
        end
        
        % Update convergence curve
        Convergence_curve(t) = Best_score;
        prevBest = Best_score;
    end
end

%% Helper Functions

function st = stateEncode(div, improved)
    % Encode state based on diversity and improvement signals
    % States: 1 = High div + improved (explore)
    %         2 = High div + not improved (maintain)
    %         3 = Low div + improved (exploit)
    %         4 = Low div + not improved (stagnant)
    if div > 0.3 && improved
        st = 1;
    elseif div > 0.3 && ~improved
        st = 2;
    elseif div <= 0.3 && improved
        st = 3;
    else
        st = 4;
    end
end

function Xn = boundaryHandling(Xn, lb, ub)
    % Reflection boundary handling
    outl = Xn < lb;
    outh = Xn > ub;
    Xn(outl) = 2 * lb(outl) - Xn(outl);
    Xn(outh) = 2 * ub(outh) - Xn(outh);
    % Ensure within bounds
    Xn = min(max(Xn, lb), ub);
end

function L = levyFlight(s)
    % Mantegna's algorithm for Levy flight
    beta = 1.5;
    sigma = (gamma(1 + beta) * sin(pi * beta / 2) / ...
             (gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2)))^(1 / beta);
    u = randn * sigma;
    v = randn;
    L = 0.01 * s * u / (abs(v)^(1 / beta) + 1e-12);
end
