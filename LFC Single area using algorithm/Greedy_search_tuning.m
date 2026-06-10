clear all
close all
clc

% Define the details of the table design problem
nVar = 3;                 % number of variables  
ub = [1000 1000 1000];    % upper Bound
lb = [0 0 0];             % lower bound  
fobj = @tunning;          % Objective function Name

% Define Greedy Search parameters
% To match your layout, we can track 15 independent greedy search paths (agents)
noP = 15;                 % number of parallel greedy tracks (equivalent to noP)
maxIter = 10;             % maximum iterations

% Step size for local neighborhood search (e.g., 5% of total search space)
stepSize = (ub - lb) .* 0.05; 

% Initialize the positions of the agents
for k = 1 : noP
    Agents(k).X = (ub - lb) .* rand(1, nVar) + lb; 
    Agents(k).O = inf; 
end

GBEST_O = inf;
GBEST_X = zeros(1, nVar);

% Main loop
for t = 1 : maxIter
    
    % Evaluate current positions and establish global baseline
    for k = 1 : noP
        % Boundary Control
        Agents(k).X = max(Agents(k).X, lb);
        Agents(k).X = min(Agents(k).X, ub);
        
        Agents(k).O = fobj(Agents(k).X);
        
        % Update Global Best
        if Agents(k).O < GBEST_O
            GBEST_O = Agents(k).O;
            GBEST_X = Agents(k).X;
        end
    end
    
    % Greedy Update Phase
    for k = 1 : noP
        % Propose a new candidate solution in the local neighborhood
        % randn provides a normal distribution centered around the current position
        New_X = Agents(k).X + randn(1, nVar) .* stepSize;
        
        % Boundary Control
        New_X = max(New_X, lb);
        New_X = min(New_X, ub);
        
        % Evaluate the candidate
        New_O = fobj(New_X);
        
        % GREEDY CONDITION: Accept ONLY if it strictly improves the cost
        if New_O < Agents(k).O
            Agents(k).X = New_X;
            Agents(k).O = New_O;
        end
    end
    
    outmsg = ['Iteration# ', num2str(t) , ' Greedy.GBEST.O = ' , num2str(GBEST_O)];
    disp(outmsg);
    
    cgCurve(t) = GBEST_O;
end
 
% Plot results
figure;
semilogy(cgCurve, 'LineWidth', 2);
xlabel('Iteration#')
ylabel('Weight')
title('Greedy Search Convergence Curve')
grid on;