clear all
close all
clc

% Define the details of the table design problem
nVar = 3;                 % number of variables  
ub = [1000 1000 1000];    % upper Bound
lb = [0 0 0];             % lower bound  
fobj = @tunning;          % Objective function Name

% Define the BWO's parameters 
noP = 15;                 % number of beluga whales (equivalent to population size)
maxIter = 10;             % maximum iterations
Wf = 0.1;                 % Probability of whale fall

% Initialize the population positions
for k = 1 : noP
    X(k, :) = (ub - lb) .* rand(1, nVar) + lb; 
    X_fitness(k) = inf;
end

GBEST_O = inf;
GBEST_X = zeros(1, nVar);

% Main loop
for t = 1 : maxIter
    
    % Evaluate objective values
    for k = 1 : noP
        % Boundary Control
        X(k, :) = max(X(k, :), lb);
        X(k, :) = min(X(k, :), ub);
        
        X_fitness(k) = fobj(X(k, :));
        
        % Update Global Best
        if X_fitness(k) < GBEST_O
            GBEST_O = X_fitness(k);
            GBEST_X = X(k, :);
        end
    end
    
    % Dynamic Balance Factor (Bf) to shift between Exploration and Exploitation
    Bf = rand() * (1 - t / maxIter); 
    
    X_new = X; % Temporary population matrix to store updates
    
    % Update Positions based on behaviors
    for i = 1 : noP
        
        if Bf > 0.5
            %% 1. EXPLORATION PHASE (Swimming behavior)
            % Randomly select another whale for pairing
            p_idx = randi(noP);
            while p_idx == i
                p_idx = randi(noP);
            end
            
            % Randomly pick a dimension to establish trajectory tracking
            pj = randi(nVar);
            
            r1 = rand();
            r2 = rand();
            
            % Update dimension by dimension depending on structural indexing
            for j = 1 : nVar
                if mod(pj, 2) == 0 % Even indexing dimension path
                    X_new(i, j) = X(i, pj) + (X(p_idx, 1) - X(i, pj)) * (1 + r1) * sin(2 * pi * r2);
                else               % Odd indexing dimension path
                    X_new(i, j) = X(i, pj) + (X(p_idx, 1) - X(i, pj)) * (1 + r1) * cos(2 * pi * r2);
                end
            end
            
        else
            %% 2. EXPLOITATION PHASE (Controlled Hunting behavior)
            % Variables to track whale positions during herd hunt
            r3 = rand();
            r4 = rand();
            C1 = 2 * r4 * (1 - t / maxIter); % Dynamic scale modifier
            
            % Pick a random tracking partner index
            r_idx = randi(noP);
            
            % Move toward the best solution using levy flight components/local steps
            X_new(i, :) = r3 * GBEST_X + (1 - r3) * X(r_idx, :) + C1 * (GBEST_X - X(i, :));
        end
        
        %% 3. WHALE FALL PHASE (Structural Replacements)
        % Checks if environmental conditions cause a simulated whale collapse
        if rand() < Wf
            r5 = rand(); r6 = rand(); r7 = rand();
            step_size = r5 * (ub - lb) * r6;
            C2 = 2 * Wf * noP;
            X_new(i, :) = r7 * X(i, :) + (1 - r7) * GBEST_X + C2 * step_size;
        end
    end
    
    % Replace original positions with valid better-performing new coordinates
    for i = 1 : noP
        X_new(i, :) = max(X_new(i, :), lb);
        X_new(i, :) = min(X_new(i, :), ub);
        
        new_fit = fobj(X_new(i, :));
        if new_fit < X_fitness(i)
            X(i, :) = X_new(i, :);
            X_fitness(i) = new_fit;
            
            % Instantaneous global checkpoint tracker
            if new_fit < GBEST_O
                GBEST_O = new_fit;
                GBEST_X = X_new(i, :);
            end
        end
    end
    
    outmsg = ['Iteration# ', num2str(t) , ' BWO.GBEST.O = ' , num2str(GBEST_O)];
    disp(outmsg);
    
    cgCurve(t) = GBEST_O;
end
 
% Plot results
figure;
semilogy(cgCurve, 'LineWidth', 2);
xlabel('Iteration#')
ylabel('Weight')
title('BWO Convergence Curve')
grid on;