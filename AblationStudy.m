%___________________________________________________________________%
%  Ablation Study for QESDO                                        %
%                                                                   %
%  This script performs an ablation study to analyze the            %
%  contribution of each component of QESDO:                         %
%  - QESDO (full): All components                                   %
%  - QESDO-Q: Without Q-learning (random operator selection)        %
%  - QESDO-OBL: Without Opposition-Based Learning                   %
%  - QESDO-LS: Without Memetic Local Search                         %
%  - QESDO-SA: Without Self-Adaptive parameter control              %
%___________________________________________________________________%

clear all; clc; close all;

%% Settings
SearchAgents_no = 50;
Max_iteration = 500;
num_runs = 30;
Function_IDs = 1:23;   % Sphere, Rosenbrock, Rastrigin, Ackley
dim = 30;

Variant_Names = {'QESDO (Full)', 'QESDO-Q', 'QESDO-OBL', 'QESDO-LS', 'QESDO-SA'};
num_variants = length(Variant_Names);
num_functions = length(Function_IDs);

%% Run Ablation Study
Results_Mean = zeros(num_functions, num_variants);
Results_Std = zeros(num_functions, num_variants);
All_Fitness = cell(num_functions, num_variants);

fprintf('=================================================================\n');
fprintf('  QESDO ABLATION STUDY\n');
fprintf('=================================================================\n\n');

for func_idx = 1:num_functions
    Function_ID = Function_IDs(func_idx);
    [lb, ub, ~, fobj] = Get_Functions_details(Function_ID);
    
    if isscalar(lb)
        lb = lb * ones(1, dim);
        ub = ub * ones(1, dim);
    end
    
    fprintf('Function F%d:\n', Function_ID);
    
    for var_idx = 1:num_variants
        fprintf('  Running %s... ', Variant_Names{var_idx});
        
        fitness_runs = zeros(1, num_runs);
        
        tic;
        for run = 1:num_runs
            rng(run);
            
            switch var_idx
                case 1  % Full QESDO
                    [~, Best_score, ~] = QESDO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
                case 2  % Without Q-learning
                    [~, Best_score, ~] = QESDO_noQ(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
                case 3  % Without OBL
                    [~, Best_score, ~] = QESDO_noOBL(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
                case 4  % Without Local Search
                    [~, Best_score, ~] = QESDO_noLS(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
                case 5  % Without Self-Adaptive
                    [~, Best_score, ~] = QESDO_noSA(SearchAgents_no, Max_iteration, lb, ub, dim, fobj);
            end
            
            fitness_runs(run) = Best_score;
        end
        elapsed = toc;
        
        All_Fitness{func_idx, var_idx} = fitness_runs;
        Results_Mean(func_idx, var_idx) = mean(fitness_runs);
        Results_Std(func_idx, var_idx) = std(fitness_runs);
        
        fprintf('Done (%.2fs) | Mean: %.4e | Std: %.4e\n', ...
            elapsed, mean(fitness_runs), std(fitness_runs));
    end
    fprintf('\n');
end

%% Plot Ablation Results
fprintf('Generating ablation bar chart...\n');

fig = figure('Position', [100, 100, 900, 400], 'Color', 'w');

% Normalize results for better visualization
Normalized_Mean = zeros(size(Results_Mean));
for func_idx = 1:num_functions
    min_val = min(Results_Mean(func_idx, :));
    max_val = max(Results_Mean(func_idx, :));
    if max_val > min_val
        Normalized_Mean(func_idx, :) = (Results_Mean(func_idx, :) - min_val) / (max_val - min_val);
    else
        Normalized_Mean(func_idx, :) = 0;
    end
end

bar(Normalized_Mean');
set(gca, 'XTickLabel', Variant_Names, 'FontSize', 11);
xtickangle(30);
ylabel('Normalized Mean Fitness (0=Best, 1=Worst)', 'FontSize', 12);
title('QESDO Ablation Study - Component Contribution Analysis', 'FontSize', 14);
legend(arrayfun(@(x) sprintf('F%d', x), Function_IDs, 'UniformOutput', false), 'Location', 'best');
grid on;
box on;

saveas(fig, 'Results_Figures/Ablation_Study.png');
saveas(fig, 'Results_Figures/Ablation_Study.fig');

%% Display Results Table
fprintf('\n=================================================================\n');
fprintf('  ABLATION STUDY RESULTS (Mean ± Std)\n');
fprintf('=================================================================\n\n');

fprintf('%-20s', 'Function');
for var_idx = 1:num_variants
    fprintf('%-25s', Variant_Names{var_idx});
end
fprintf('\n');
fprintf('%s\n', repmat('-', 1, 20 + 25*num_variants));

for func_idx = 1:num_functions
    fprintf('F%-19d', Function_IDs(func_idx));
    for var_idx = 1:num_variants
        fprintf('%.4e(%.2e) ', Results_Mean(func_idx, var_idx), Results_Std(func_idx, var_idx));
    end
    fprintf('\n');
end

fprintf('\n=================================================================\n');
fprintf('  ABLATION STUDY COMPLETED\n');
fprintf('=================================================================\n');

%% ===================== ABLATION VARIANTS =====================

function [Best_pos, Best_score, Convergence_curve] = QESDO_noQ(N, Max_iter, lb, ub, dim, fobj)
    % QESDO without Q-learning (random operator selection)
    if numel(lb) == 1, lb = repmat(lb, 1, dim); ub = repmat(ub, 1, dim); end
    lb = lb(:)'; ub = ub(:)';
    
    Jr = 0.3; sigma0 = 0.5; smin = 0.001; smax = 0.5; s = 0.3; alphaStep = 0.5;
    
    % OBL initialization
    X = initialization(N, dim, ub, lb);
    OX = repmat(lb, N, 1) + repmat(ub, N, 1) - X;
    Fit = zeros(N, 1); OFit = zeros(N, 1);
    for i = 1:N, Fit(i) = fobj(X(i,:)); OFit(i) = fobj(OX(i,:)); end
    AllX = [X; OX]; AllF = [Fit; OFit];
    [~, idx] = sort(AllF);
    X = AllX(idx(1:N),:); Fit = AllF(idx(1:N));
    [Best_score, bestIdx] = min(Fit);
    Best_pos = X(bestIdx,:); EliteX = Best_pos;
    
    Convergence_curve = zeros(1, Max_iter);
    
    for t = 1:Max_iter
        Xmean = mean(X,1); beta_t = randn;
        q = (t^2 - 2*t + 1)/(Max_iter^2 - 2*Max_iter + 1) + 1/(Max_iter^2 - 2*Max_iter + 1);
        successCount = 0;
        
        for i = 1:N
            a = randi(4);  % Random selection instead of Q-learning
            Xi = X(i,:); Xi_new = Xi;
            
            switch a
                case 1
                    if rand*2 < 1.5
                        vx = randn; vy = randn; lnY = exp(randn);
                        Xi_new = Xi + alphaStep*rand*vx*vy*lnY*(X(randi(N),:) - Xi);
                    else
                        Xi_new = Xi * (1 - rand*q);
                    end
                case 2
                    Xi_new = Xi - alphaStep*rand*beta_t*(Xmean - alphaStep*rand*beta_t*Xi);
                case 3
                    delta = 2*t/Max_iter;
                    L = levyFlight_abl(s);
                    Xi_new = EliteX + L*alphaStep*(EliteX - Xi*delta);
                case 4
                    sigMem = sigma0*(1 - t/Max_iter) + 1e-6;
                    Xi_new = EliteX + sigMem*randn(1,dim).*(ub - lb);
            end
            
            Xi_new = min(max(Xi_new, lb), ub);
            Fi_new = fobj(Xi_new);
            
            if Fi_new < Fit(i)
                X(i,:) = Xi_new; Fit(i) = Fi_new;
                if Fi_new < Best_score
                    Best_score = Fi_new; Best_pos = Xi_new; EliteX = Xi_new;
                    successCount = successCount + 1;
                end
            end
        end
        
        rate = successCount/N;
        if rate > 0.2, s = min(s*1.2, smax);
        elseif rate < 0.05, s = max(s*0.9, smin); end
        alphaStep = 0.5 + 0.5*rand;
        
        if rand < Jr
            OXe = lb + ub - EliteX;
            OFit_e = fobj(OXe);
            if OFit_e < Best_score, Best_score = OFit_e; Best_pos = OXe; EliteX = OXe; end
        end
        
        Convergence_curve(t) = Best_score;
    end
end

function [Best_pos, Best_score, Convergence_curve] = QESDO_noOBL(N, Max_iter, lb, ub, dim, fobj)
    % QESDO without OBL (standard random initialization, no elite jump)
    if numel(lb) == 1, lb = repmat(lb, 1, dim); ub = repmat(ub, 1, dim); end
    lb = lb(:)'; ub = ub(:)';
    
    numStates = 4; numActions = 4;
    Q = zeros(numStates, numActions);
    alphaQ = 0.6; gammaQ = 0.9; eps0 = 0.9; epsEnd = 0.05;
    sigma0 = 0.5; smin = 0.001; smax = 0.5; s = 0.3; alphaStep = 0.5;
    
    % Standard initialization (no OBL)
    X = initialization(N, dim, ub, lb);
    Fit = zeros(N, 1);
    for i = 1:N, Fit(i) = fobj(X(i,:)); end
    [Best_score, bestIdx] = min(Fit);
    Best_pos = X(bestIdx,:); EliteX = Best_pos;
    
    Convergence_curve = zeros(1, Max_iter);
    prevBest = Best_score;
    
    for t = 1:Max_iter
        epsilon = eps0 - (eps0 - epsEnd)*t/Max_iter;
        Xmean = mean(X,1); beta_t = randn;
        div = mean(std(X,0,1)./(ub - lb + 1e-12));
        improved = (Best_score < prevBest);
        state = stateEncode_abl(div, improved);
        q = (t^2 - 2*t + 1)/(Max_iter^2 - 2*Max_iter + 1) + 1/(Max_iter^2 - 2*Max_iter + 1);
        successCount = 0;
        
        for i = 1:N
            if rand < epsilon, a = randi(numActions);
            else, [~, a] = max(Q(state,:)); end
            
            Xi = X(i,:); Xi_new = Xi;
            
            switch a
                case 1
                    if rand*2 < 1.5
                        vx = randn; vy = randn; lnY = exp(randn);
                        Xi_new = Xi + alphaStep*rand*vx*vy*lnY*(X(randi(N),:) - Xi);
                    else
                        Xi_new = Xi * (1 - rand*q);
                    end
                case 2
                    Xi_new = Xi - alphaStep*rand*beta_t*(Xmean - alphaStep*rand*beta_t*Xi);
                case 3
                    delta = 2*t/Max_iter;
                    L = levyFlight_abl(s);
                    Xi_new = EliteX + L*alphaStep*(EliteX - Xi*delta);
                case 4
                    sigMem = sigma0*(1 - t/Max_iter) + 1e-6;
                    Xi_new = EliteX + sigMem*randn(1,dim).*(ub - lb);
            end
            
            Xi_new = min(max(Xi_new, lb), ub);
            Fi_new = fobj(Xi_new);
            
            if Fi_new < Fit(i)
                X(i,:) = Xi_new; Fit(i) = Fi_new; reward = 1;
                if Fi_new < Best_score
                    Best_score = Fi_new; Best_pos = Xi_new; EliteX = Xi_new;
                    successCount = successCount + 1;
                end
            else
                reward = 0;
            end
            
            stateNext = stateEncode_abl(div, (Best_score < prevBest));
            Q(state,a) = Q(state,a) + alphaQ*(reward + gammaQ*max(Q(stateNext,:)) - Q(state,a));
        end
        
        rate = successCount/N;
        if rate > 0.2, s = min(s*1.2, smax);
        elseif rate < 0.05, s = max(s*0.9, smin); end
        alphaStep = 0.5 + 0.5*rand;
        
        % No OBL elite jump
        
        Convergence_curve(t) = Best_score;
        prevBest = Best_score;
    end
end

function [Best_pos, Best_score, Convergence_curve] = QESDO_noLS(N, Max_iter, lb, ub, dim, fobj)
    % QESDO without Memetic Local Search (only 3 actions)
    if numel(lb) == 1, lb = repmat(lb, 1, dim); ub = repmat(ub, 1, dim); end
    lb = lb(:)'; ub = ub(:)';
    
    numStates = 4; numActions = 3;  % Only 3 actions
    Q = zeros(numStates, numActions);
    alphaQ = 0.6; gammaQ = 0.9; eps0 = 0.9; epsEnd = 0.05;
    Jr = 0.3; smin = 0.001; smax = 0.5; s = 0.3; alphaStep = 0.5;
    
    X = initialization(N, dim, ub, lb);
    OX = repmat(lb, N, 1) + repmat(ub, N, 1) - X;
    Fit = zeros(N, 1); OFit = zeros(N, 1);
    for i = 1:N, Fit(i) = fobj(X(i,:)); OFit(i) = fobj(OX(i,:)); end
    AllX = [X; OX]; AllF = [Fit; OFit];
    [~, idx] = sort(AllF);
    X = AllX(idx(1:N),:); Fit = AllF(idx(1:N));
    [Best_score, bestIdx] = min(Fit);
    Best_pos = X(bestIdx,:); EliteX = Best_pos;
    
    Convergence_curve = zeros(1, Max_iter);
    prevBest = Best_score;
    
    for t = 1:Max_iter
        epsilon = eps0 - (eps0 - epsEnd)*t/Max_iter;
        Xmean = mean(X,1); beta_t = randn;
        div = mean(std(X,0,1)./(ub - lb + 1e-12));
        improved = (Best_score < prevBest);
        state = stateEncode_abl(div, improved);
        q = (t^2 - 2*t + 1)/(Max_iter^2 - 2*Max_iter + 1) + 1/(Max_iter^2 - 2*Max_iter + 1);
        successCount = 0;
        
        for i = 1:N
            if rand < epsilon, a = randi(numActions);
            else, [~, a] = max(Q(state,:)); end
            
            Xi = X(i,:); Xi_new = Xi;
            
            switch a
                case 1
                    if rand*2 < 1.5
                        vx = randn; vy = randn; lnY = exp(randn);
                        Xi_new = Xi + alphaStep*rand*vx*vy*lnY*(X(randi(N),:) - Xi);
                    else
                        Xi_new = Xi * (1 - rand*q);
                    end
                case 2
                    Xi_new = Xi - alphaStep*rand*beta_t*(Xmean - alphaStep*rand*beta_t*Xi);
                case 3
                    delta = 2*t/Max_iter;
                    L = levyFlight_abl(s);
                    Xi_new = EliteX + L*alphaStep*(EliteX - Xi*delta);
            end
            
            Xi_new = min(max(Xi_new, lb), ub);
            Fi_new = fobj(Xi_new);
            
            if Fi_new < Fit(i)
                X(i,:) = Xi_new; Fit(i) = Fi_new; reward = 1;
                if Fi_new < Best_score
                    Best_score = Fi_new; Best_pos = Xi_new; EliteX = Xi_new;
                    successCount = successCount + 1;
                end
            else
                reward = 0;
            end
            
            stateNext = stateEncode_abl(div, (Best_score < prevBest));
            Q(state,a) = Q(state,a) + alphaQ*(reward + gammaQ*max(Q(stateNext,:)) - Q(state,a));
        end
        
        rate = successCount/N;
        if rate > 0.2, s = min(s*1.2, smax);
        elseif rate < 0.05, s = max(s*0.9, smin); end
        alphaStep = 0.5 + 0.5*rand;
        
        if rand < Jr
            OXe = lb + ub - EliteX;
            OFit_e = fobj(OXe);
            if OFit_e < Best_score, Best_score = OFit_e; Best_pos = OXe; EliteX = OXe; end
        end
        
        Convergence_curve(t) = Best_score;
        prevBest = Best_score;
    end
end

function [Best_pos, Best_score, Convergence_curve] = QESDO_noSA(N, Max_iter, lb, ub, dim, fobj)
    % QESDO without Self-Adaptive parameters
    if numel(lb) == 1, lb = repmat(lb, 1, dim); ub = repmat(ub, 1, dim); end
    lb = lb(:)'; ub = ub(:)';
    
    numStates = 4; numActions = 4;
    Q = zeros(numStates, numActions);
    alphaQ = 0.6; gammaQ = 0.9; eps0 = 0.9; epsEnd = 0.05;
    Jr = 0.3; sigma0 = 0.5;
    s = 0.3;  % Fixed Levy scale
    alphaStep = 0.5;  % Fixed step
    
    X = initialization(N, dim, ub, lb);
    OX = repmat(lb, N, 1) + repmat(ub, N, 1) - X;
    Fit = zeros(N, 1); OFit = zeros(N, 1);
    for i = 1:N, Fit(i) = fobj(X(i,:)); OFit(i) = fobj(OX(i,:)); end
    AllX = [X; OX]; AllF = [Fit; OFit];
    [~, idx] = sort(AllF);
    X = AllX(idx(1:N),:); Fit = AllF(idx(1:N));
    [Best_score, bestIdx] = min(Fit);
    Best_pos = X(bestIdx,:); EliteX = Best_pos;
    
    Convergence_curve = zeros(1, Max_iter);
    prevBest = Best_score;
    
    for t = 1:Max_iter
        epsilon = eps0 - (eps0 - epsEnd)*t/Max_iter;
        Xmean = mean(X,1); beta_t = randn;
        div = mean(std(X,0,1)./(ub - lb + 1e-12));
        improved = (Best_score < prevBest);
        state = stateEncode_abl(div, improved);
        q = (t^2 - 2*t + 1)/(Max_iter^2 - 2*Max_iter + 1) + 1/(Max_iter^2 - 2*Max_iter + 1);
        
        for i = 1:N
            if rand < epsilon, a = randi(numActions);
            else, [~, a] = max(Q(state,:)); end
            
            Xi = X(i,:); Xi_new = Xi;
            
            switch a
                case 1
                    if rand*2 < 1.5
                        vx = randn; vy = randn; lnY = exp(randn);
                        Xi_new = Xi + alphaStep*rand*vx*vy*lnY*(X(randi(N),:) - Xi);
                    else
                        Xi_new = Xi * (1 - rand*q);
                    end
                case 2
                    Xi_new = Xi - alphaStep*rand*beta_t*(Xmean - alphaStep*rand*beta_t*Xi);
                case 3
                    delta = 2*t/Max_iter;
                    L = levyFlight_abl(s);
                    Xi_new = EliteX + L*alphaStep*(EliteX - Xi*delta);
                case 4
                    sigMem = sigma0*(1 - t/Max_iter) + 1e-6;
                    Xi_new = EliteX + sigMem*randn(1,dim).*(ub - lb);
            end
            
            Xi_new = min(max(Xi_new, lb), ub);
            Fi_new = fobj(Xi_new);
            
            if Fi_new < Fit(i)
                X(i,:) = Xi_new; Fit(i) = Fi_new; reward = 1;
                if Fi_new < Best_score
                    Best_score = Fi_new; Best_pos = Xi_new; EliteX = Xi_new;
                end
            else
                reward = 0;
            end
            
            stateNext = stateEncode_abl(div, (Best_score < prevBest));
            Q(state,a) = Q(state,a) + alphaQ*(reward + gammaQ*max(Q(stateNext,:)) - Q(state,a));
        end
        
        % No self-adaptive update (fixed s and alphaStep)
        
        if rand < Jr
            OXe = lb + ub - EliteX;
            OFit_e = fobj(OXe);
            if OFit_e < Best_score, Best_score = OFit_e; Best_pos = OXe; EliteX = OXe; end
        end
        
        Convergence_curve(t) = Best_score;
        prevBest = Best_score;
    end
end

function st = stateEncode_abl(div, improved)
    if div > 0.3 && improved, st = 1;
    elseif div > 0.3 && ~improved, st = 2;
    elseif div <= 0.3 && improved, st = 3;
    else, st = 4; end
end

function L = levyFlight_abl(s)
    beta = 1.5;
    sigma = (gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
    u = randn*sigma; v = randn;
    L = 0.01*s*u/(abs(v)^(1/beta) + 1e-12);
end
