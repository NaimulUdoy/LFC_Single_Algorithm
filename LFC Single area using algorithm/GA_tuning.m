clear all
close all
clc

% Define the details of the table design problem
nVar = 3;                 % number of variables  
ub = [1000 1000 1000];    % upper Bound
lb = [0 0 0];             % lower bound  
fobj = @tunning;          % Objective function Name

% Define the GA's parameters 
PopSize = 15;             % Population size (equivalent to noP)
maxGen = 10;              % Maximum generations (equivalent to maxIter)
pc = 0.8;                 % Crossover probability
pm = 0.1;                 % Mutation probability

% Initialize the Population
for k = 1 : PopSize
    Population(k).X = (ub-lb) .* rand(1,nVar) + lb; 
    Population(k).O = inf; 
end

BestCost = inf;
BestChrom = zeros(1, nVar);

% Main loop
for t = 1 : maxGen
    
    % 1. Calculate the objective value for each chromosome
    for k = 1 : PopSize
        Population(k).O = fobj(Population(k).X);
        
        % Update Global Best found so far
        if Population(k).O < BestCost
            BestCost = Population(k).O;
            BestChrom = Population(k).X;
        end
    end
    
    % 2. Selection (Roulette Wheel based on inverted costs for minimization)
    % Standardize costs to avoid errors if fitness goes negative or zero
    costs = [Population.O];
    if max(costs) ~= min(costs)
        % Transform to fitness (higher is better, shift to handle negative costs)
        fitness = max(costs) - costs + eps; 
    else
        fitness = ones(1, PopSize);
    end
    prob = fitness ./ sum(fitness);
    cumProb = cumsum(prob);
    
    % Create a temporary pool for the next generation
    NewPool = Population;
    
    % 3. Crossover (Pairwise processing)
    for k = 1 : 2 : PopSize
        % Select two parents using Roulette Wheel
        p1_idx = find(rand <= cumProb, 1, 'first');
        p2_idx = find(rand <= cumProb, 1, 'first');
        
        parent1 = Population(p1_idx).X;
        parent2 = Population(p2_idx).X;
        
        child1 = parent1;
        child2 = parent2;
        
        if rand < pc
            % Arithmetic Crossover
            alpha = rand(1, nVar);
            child1 = alpha .* parent1 + (1 - alpha) .* parent2;
            child2 = alpha .* parent2 + (1 - alpha) .* parent1;
        end
        
        NewPool(k).X = child1;
        if k+1 <= PopSize
            NewPool(k+1).X = child2;
        end
    end
    
    % 4. Mutation
    for k = 1 : PopSize
        for j = 1 : nVar
            if rand < pm
                % Uniform Mutation within bounds
                NewPool(k).X(j) = lb(j) + rand * (ub(j) - lb(j));
            end
        end
        
        % Boundary Control (Just in case)
        NewPool(k).X = max(NewPool(k).X, lb);
        NewPool(k).X = min(NewPool(k).X, ub);
    end
    
    % Update population for the next generation
    Population = NewPool;
    
    % Print progress
    outmsg = ['Generation# ', num2str(t) , ' BestCost = ' , num2str(BestCost)];
    disp(outmsg);
    
    cgCurve(t) = BestCost;
end
 
% Plot results
figure;
semilogy(cgCurve, 'LineWidth', 2);
xlabel('Generation#')
ylabel('Weight')
title('GA Convergence Curve')
grid on;