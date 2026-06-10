clear all
close all
clc

% Define the details of the table design problem
nVar = 3;                 % number of variables  
ub = [1000 1000 1000];    % upper Bound
lb = [0 0 0];             % lower bound  
fobj = @tunning;          % Objective function Name

% Define HOA parameters
noP = 15;                 % number of horses (population size)
maxIter = 10;             % maximum iterations

% Initialize positions and velocities
X = (ub - lb) .* rand(noP, nVar) + lb;
V = zeros(noP, nVar);
X_fitness = inf(noP, 1);

GBEST_O = inf;
GBEST_X = zeros(1, nVar);

% Main loop
for t = 1 : maxIter
    
    % 1. Calculate fitness values
    for i = 1 : noP
        % Boundary checking
        X(i, :) = max(X(i, :), lb);
        X(i, :) = min(X(i, :), ub);
        
        X_fitness(i) = fobj(X(i, :));
        
        % Track the global best solution
        if X_fitness(i) < GBEST_O
            GBEST_O = X_fitness(i);
            GBEST_X = X(i, :);
        end
    end
    
    % Sort the herd based on fitness to define the social age hierarchy
    [~, sortIdx] = sort(X_fitness);
    
    % Define age distribution factors (dynamic inertia modifiers)
    % Simulated profiles: Alpha (Leaders), Beta (Matures), Gamma (Stable), Young (Explorers)
    % Dynamically reduces over time to enforce local exploitation near the end
    g_factor = 0.9 * (1 - t / maxIter); 
    
    % 2. Position Updates via Social Behaviors
    for idx = 1 : noP
        i = sortIdx(idx); % Follow the social hierarchy rank
        
        % Assign behavioral weights depending on hierarchy positions
        if idx <= round(0.1 * noP)       % Alpha Horses (Top 10%)
            % Dominated by Grazing and local leadership adjustments
            Velocity_Behavior = g_factor * rand(1, nVar) .* (GBEST_X - X(i, :));
            
        elseif idx <= round(0.3 * noP)  % Beta Horses (Next 20%)
            % Dominated by Hierarchy tracking and imitation of Alphas
            alpha_leader = X(sortIdx(randi(max(1, round(0.1 * noP)))), :);
            Velocity_Behavior = rand(1, nVar) .* (alpha_leader - X(i, :));
            
        elseif idx <= round(0.7 * noP)  % Gamma Horses (Middle 40%)
            % Dominated by Sociability and group clustering
            mean_herd = mean(X, 1);
            Velocity_Behavior = 0.5 * rand(1, nVar) .* (mean_herd - X(i, :));
            
        else                             % Young Horses (Bottom 30%)
            % Dominated by Roaming (High exploration via random steps)
            Velocity_Behavior = 0.2 * (ub - lb) .* (rand(1, nVar) - 0.5);
        end
        
        % Combine internal memory (Velocity tracking) with Social Behaviors
        % Mimics the comprehensive update vector: V = V_old + Behaviors
        V(i, :) = 0.5 * V(i, :) + Velocity_Behavior;
        
        % Apply position shift
        X(i, :) = X(i, :) + V(i, :);
    end
    
    outmsg = ['Iteration# ', num2str(t) , ' HOA.GBEST.O = ' , num2str(GBEST_O)];
    disp(outmsg);
    
    cgCurve(t) = GBEST_O;
end
 
% Plot results
figure;
semilogy(cgCurve, 'LineWidth', 2);
xlabel('Iteration#')
ylabel('Weight')
title('HOA Convergence Curve')
grid on;