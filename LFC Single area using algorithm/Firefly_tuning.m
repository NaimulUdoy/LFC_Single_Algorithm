clear all
close all
clc

% Define the details of the table design problem
nVar = 3;                 % number of variables  
ub = [1000 1000 1000];    % upper Bound
lb = [0 0 0];             % lower bound  
fobj = @tunning;          % Objective function Name

% Define the Firefly Algorithm's parameters 
noP = 15;                 % number of fireflies (equivalent to population size)
maxIter = 10;             % maximum iterations

alpha = 0.2;              % Randomization parameter
beta0 = 1.0;              % Attraction coefficient base (at distance = 0)
gamma = 1.0;              % Light absorption coefficient

% Initialize the positions and light intensities (fitness) of fireflies
X = (ub - lb) .* rand(noP, nVar) + lb;
Intensity = inf(noP, 1);

GBEST_O = inf;
GBEST_X = zeros(1, nVar);

% Main loop
for t = 1 : maxIter
    
    % Evaluate objective values (Light Intensity)
    for i = 1 : noP
        % Boundary Control
        X(i, :) = max(X(i, :), lb);
        X(i, :) = min(X(i, :), ub);
        
        Intensity(i) = fobj(X(i, :));
        
        % Track Global Best
        if Intensity(i) < GBEST_O
            GBEST_O = Intensity(i);
            GBEST_X = X(i, :);
        end
    end
    
    % Move fireflies based on attractiveness
    for i = 1 : noP
        for j = 1 : noP
            
            % Since this is a minimization problem, a lower intensity value 
            % means the firefly is "brighter" (more attractive).
            if Intensity(j) < Intensity(i)
                
                % Calculate Cartesian distance between firefly i and j
                r = norm(X(i, :) - X(j, :));
                
                % Compute attractiveness based on distance and absorption coefficient
                beta = beta0 * exp(-gamma * r^2);
                
                % Generate a random step element
                epsilon = rand(1, nVar) - 0.5;
                
                % Move firefly i towards firefly j
                X(i, :) = X(i, :) + beta * (X(j, :) - X(i, :)) + alpha * (ub - lb) .* epsilon;
                
                % Immediate boundary control after movement
                X(i, :) = max(X(i, :), lb);
                X(i, :) = min(X(i, :), ub);
                
            end
        end
    end
    
    % Optional: Gradually reduce alpha over time to fine-tune exploitation
    alpha = alpha * 0.98;
    
    outmsg = ['Iteration# ', num2str(t) , ' FA.GBEST.O = ' , num2str(GBEST_O)];
    disp(outmsg);
    
    cgCurve(t) = GBEST_O;
end
 
% Plot results
figure;
semilogy(cgCurve, 'LineWidth', 2);
xlabel('Iteration#')
ylabel('Weight')
title('Firefly Algorithm Convergence Curve')
grid on;