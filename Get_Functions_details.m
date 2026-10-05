%___________________________________________________________________%
%  Benchmark Functions Details                                      %
%                                                                   %
%  This function returns the lower bound (lb), upper bound (ub),    %
%  dimension (dim), and objective function handle (fobj) for        %
%  various benchmark test functions.                                %
%                                                                   %
%  Functions F1-F7: Unimodal benchmark functions                    %
%  Functions F8-F13: Multimodal benchmark functions                 %
%  Functions F14-F23: Fixed-dimension multimodal functions          %
%___________________________________________________________________%

function [lb, ub, dim, fobj] = Get_Functions_details(F)
    
    switch F
        case 1
            fobj = @F1;
            lb = -100;
            ub = 100;
            dim = 30;
            
        case 2
            fobj = @F2;
            lb = -10;
            ub = 10;
            dim = 30;
            
        case 3
            fobj = @F3;
            lb = -100;
            ub = 100;
            dim = 30;
            
        case 4
            fobj = @F4;
            lb = -100;
            ub = 100;
            dim = 30;
            
        case 5
            fobj = @F5;
            lb = -30;
            ub = 30;
            dim = 30;
            
        case 6
            fobj = @F6;
            lb = -100;
            ub = 100;
            dim = 30;
            
        case 7
            fobj = @F7;
            lb = -1.28;
            ub = 1.28;
            dim = 30;
            
        case 8
            fobj = @F8;
            lb = -500;
            ub = 500;
            dim = 30;
            
        case 9
            fobj = @F9;
            lb = -5.12;
            ub = 5.12;
            dim = 30;
            
        case 10
            fobj = @F10;
            lb = -32;
            ub = 32;
            dim = 30;
            
        case 11
            fobj = @F11;
            lb = -600;
            ub = 600;
            dim = 30;
            
        case 12
            fobj = @F12;
            lb = -50;
            ub = 50;
            dim = 30;
            
        case 13
            fobj = @F13;
            lb = -50;
            ub = 50;
            dim = 30;
            
        case 14
            fobj = @F14;
            lb = -65;
            ub = 65;
            dim = 2;
            
        case 15
            fobj = @F15;
            lb = -5;
            ub = 5;
            dim = 4;
            
        case 16
            fobj = @F16;
            lb = -5;
            ub = 5;
            dim = 2;
            
        case 17
            fobj = @F17;
            lb = [-5, 0];
            ub = [10, 15];
            dim = 2;
            
        case 18
            fobj = @F18;
            lb = -2;
            ub = 2;
            dim = 2;
            
        case 19
            fobj = @F19;
            lb = 0;
            ub = 1;
            dim = 3;
            
        case 20
            fobj = @F20;
            lb = 0;
            ub = 1;
            dim = 6;
            
        case 21
            fobj = @F21;
            lb = 0;
            ub = 10;
            dim = 4;
            
        case 22
            fobj = @F22;
            lb = 0;
            ub = 10;
            dim = 4;
            
        case 23
            fobj = @F23;
            lb = 0;
            ub = 10;
            dim = 4;
    end
end

% F1: Sphere Function
function o = F1(x)
    o = sum(x.^2);
end

% F2: Schwefel 2.22
function o = F2(x)
    o = sum(abs(x)) + prod(abs(x));
end

% F3: Schwefel 1.2
function o = F3(x)
    dim = size(x, 2);
    o = 0;
    for i = 1:dim
        o = o + sum(x(1:i))^2;
    end
end

% F4: Schwefel 2.21
function o = F4(x)
    o = max(abs(x));
end

% F5: Rosenbrock
function o = F5(x)
    dim = size(x, 2);
    o = sum(100 * (x(2:dim) - x(1:dim-1).^2).^2 + (x(1:dim-1) - 1).^2);
end

% F6: Step
function o = F6(x)
    o = sum(floor(x + 0.5).^2);
end

% F7: Quartic with Noise
function o = F7(x)
    dim = size(x, 2);
    o = sum((1:dim) .* (x.^4)) + rand;
end

% F8: Schwefel 2.26
function o = F8(x)
    o = sum(-x .* sin(sqrt(abs(x))));
end

% F9: Rastrigin
function o = F9(x)
    dim = size(x, 2);
    o = sum(x.^2 - 10 * cos(2 * pi .* x)) + 10 * dim;
end

% F10: Ackley
function o = F10(x)
    dim = size(x, 2);
    o = -20 * exp(-0.2 * sqrt(sum(x.^2) / dim)) - exp(sum(cos(2 * pi .* x)) / dim) + 20 + exp(1);
end

% F11: Griewank
function o = F11(x)
    dim = size(x, 2);
    o = sum(x.^2) / 4000 - prod(cos(x ./ sqrt(1:dim))) + 1;
end

% F12: Penalized 1
function o = F12(x)
    dim = size(x, 2);
    y = 1 + (x + 1) / 4;
    o = pi / dim * (10 * sin(pi * y(1))^2 + sum((y(1:dim-1) - 1).^2 .* (1 + 10 * sin(pi * y(2:dim)).^2)) + (y(dim) - 1)^2) + sum(Ufun(x, 10, 100, 4));
end

% F13: Penalized 2
function o = F13(x)
    dim = size(x, 2);
    o = 0.1 * (sin(3 * pi * x(1))^2 + sum((x(1:dim-1) - 1).^2 .* (1 + sin(3 * pi * x(2:dim)).^2)) + (x(dim) - 1)^2 * (1 + sin(2 * pi * x(dim))^2)) + sum(Ufun(x, 5, 100, 4));
end

% F14: Shekel Foxholes
function o = F14(x)
    aS = [-32, -16, 0, 16, 32, -32, -16, 0, 16, 32, -32, -16, 0, 16, 32, -32, -16, 0, 16, 32, -32, -16, 0, 16, 32;
          -32, -32, -32, -32, -32, -16, -16, -16, -16, -16, 0, 0, 0, 0, 0, 16, 16, 16, 16, 16, 32, 32, 32, 32, 32];
    bS = zeros(25, 1);
    for j = 1:25
        bS(j) = sum((x' - aS(:, j)).^6);
    end
    o = (1/500 + sum(1 ./ ((1:25) + bS'))).^(-1);
end

% F15: Kowalik
function o = F15(x)
    aK = [0.1957, 0.1947, 0.1735, 0.16, 0.0844, 0.0627, 0.0456, 0.0342, 0.0323, 0.0235, 0.0246];
    bK = [0.25, 0.5, 1, 2, 4, 6, 8, 10, 12, 14, 16];
    bK = 1 ./ bK;
    o = sum((aK - ((x(1) .* (bK.^2 + x(2) .* bK)) ./ (bK.^2 + x(3) .* bK + x(4)))).^2);
end

% F16: Six-Hump Camel
function o = F16(x)
    o = 4 * x(1)^2 - 2.1 * x(1)^4 + x(1)^6 / 3 + x(1) * x(2) - 4 * x(2)^2 + 4 * x(2)^4;
end

% F17: Branin
function o = F17(x)
    o = (x(2) - 5.1 * x(1)^2 / (4 * pi^2) + 5 * x(1) / pi - 6)^2 + 10 * (1 - 1/(8 * pi)) * cos(x(1)) + 10;
end

% F18: Goldstein-Price
function o = F18(x)
    o = (1 + (x(1) + x(2) + 1)^2 * (19 - 14 * x(1) + 3 * x(1)^2 - 14 * x(2) + 6 * x(1) * x(2) + 3 * x(2)^2)) * ...
        (30 + (2 * x(1) - 3 * x(2))^2 * (18 - 32 * x(1) + 12 * x(1)^2 + 48 * x(2) - 36 * x(1) * x(2) + 27 * x(2)^2));
end

% F19: Hartmann 3-D
function o = F19(x)
    aH = [3, 10, 30; 0.1, 10, 35; 3, 10, 30; 0.1, 10, 35];
    cH = [1, 1.2, 3, 3.2];
    pH = [0.3689, 0.117, 0.2673; 0.4699, 0.4387, 0.747; 0.1091, 0.8732, 0.5547; 0.03815, 0.5743, 0.8828];
    o = 0;
    for i = 1:4
        o = o - cH(i) * exp(-sum(aH(i, :) .* (x - pH(i, :)).^2));
    end
end

% F20: Hartmann 6-D
function o = F20(x)
    aH = [10, 3, 17, 3.5, 1.7, 8; 0.05, 10, 17, 0.1, 8, 14; 3, 3.5, 1.7, 10, 17, 8; 17, 8, 0.05, 10, 0.1, 14];
    cH = [1, 1.2, 3, 3.2];
    pH = [0.1312, 0.1696, 0.5569, 0.0124, 0.8283, 0.5886;
          0.2329, 0.4135, 0.8307, 0.3736, 0.1004, 0.9991;
          0.2348, 0.1415, 0.3522, 0.2883, 0.3047, 0.6650;
          0.4047, 0.8828, 0.8732, 0.5743, 0.1091, 0.0381];
    o = 0;
    for i = 1:4
        o = o - cH(i) * exp(-sum(aH(i, :) .* (x - pH(i, :)).^2));
    end
end

% F21: Shekel 5
function o = F21(x)
    aSH = [4, 4, 4, 4; 1, 1, 1, 1; 8, 8, 8, 8; 6, 6, 6, 6; 3, 7, 3, 7;
           2, 9, 2, 9; 5, 5, 3, 3; 8, 1, 8, 1; 6, 2, 6, 2; 7, 3.6, 7, 3.6];
    cSH = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3, 0.7, 0.5, 0.5];
    o = 0;
    for i = 1:5
        o = o - 1 / (sum((x - aSH(i, :)).^2) + cSH(i));
    end
end

% F22: Shekel 7
function o = F22(x)
    aSH = [4, 4, 4, 4; 1, 1, 1, 1; 8, 8, 8, 8; 6, 6, 6, 6; 3, 7, 3, 7;
           2, 9, 2, 9; 5, 5, 3, 3; 8, 1, 8, 1; 6, 2, 6, 2; 7, 3.6, 7, 3.6];
    cSH = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3, 0.7, 0.5, 0.5];
    o = 0;
    for i = 1:7
        o = o - 1 / (sum((x - aSH(i, :)).^2) + cSH(i));
    end
end

% F23: Shekel 10
function o = F23(x)
    aSH = [4, 4, 4, 4; 1, 1, 1, 1; 8, 8, 8, 8; 6, 6, 6, 6; 3, 7, 3, 7;
           2, 9, 2, 9; 5, 5, 3, 3; 8, 1, 8, 1; 6, 2, 6, 2; 7, 3.6, 7, 3.6];
    cSH = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3, 0.7, 0.5, 0.5];
    o = 0;
    for i = 1:10
        o = o - 1 / (sum((x - aSH(i, :)).^2) + cSH(i));
    end
end

% Penalty function
function o = Ufun(x, a, k, m)
    o = k .* ((x - a).^m) .* (x > a) + k .* ((-x - a).^m) .* (x < (-a));
end
