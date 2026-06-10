clear all
close all
clc

% Define the details of the table design problem
nVar = 3;                 % number of variables  
ub = [1000 1000 1000];    % upper Bound
lb = [0 0 0];             % lower bound  
fobj = @tunning;          % Objective function Name

% Define the TLBO's parameters 
noP = 15;                 % Class size / population (equivalent to noP)
maxIter = 10;             % maximum iterations

% Initialize the learners (Students)
for k = 1 : noP
    Class(k).X = (ub - lb) .* rand(1, nVar) + lb; 
    Class(k).O = inf; 
end

GBEST_O = inf;
GBEST_X = zeros(1, nVar);

% Main loop
for t = 1 : maxIter
    
    % Evaluate objective values and identify the Teacher
    Teacher_O = inf;
    Teacher_idx = 1;
    
    for k = 1 : noP
        % Boundary Control
        Class(k).X = max(Class(k).X, lb);
        Class(k).X = min(Class(k).X, ub);
        
        Class(k).O = fobj(Class(k).X);
        
        % Track the Teacher (Best solution in the current population)
        if Class(k).O < Teacher_O
            Teacher_O = Class(k).O;
            Teacher_idx = k;
        end
        
        % Update overall Global Best
        if Class(k).O < GBEST_O
            GBEST_O = Class(k).O;
            GBEST_X = Class(k).X;
        end
    end
    
    Teacher_X = Class(Teacher_idx).X;
    
    %% 1. TEACHER PHASE
    % Calculate the mean position of the class for each variable
    all_X = reshape([Class.X], nVar, noP)'; % Matrix of size [noP x nVar]
    mean_X = mean(all_X, 1);
    
    for k = 1 : noP
        % Teaching Factor (TF): Can be either 1 or 2 randomly
        TF = randi([1, 2]); 
        
        % Calculate the step difference between the Teacher and the Class Mean
        Difference_Mean = rand(1, nVar) .* (Teacher_X - TF .* mean_X);
        
        % Propose a new position for the student
        New_X = Class(k).X + Difference_Mean;
        
        % Boundary Control
        New_X = max(New_X, lb);
        New_X = min(New_X, ub);
        
        % Evaluate the new position
        New_O = fobj(New_X);
        
        % Greedy Selection: Accept only if the new position is better
        if New_O < Class(k).O
            Class(k).X = New_X;
            Class(k).O = New_O;
        end
    end
    
    %% 2. LEARNER PHASE
    for k = 1 : noP
        % Select a random peer partner (different from the current learner)
        partner_idx = randi(noP);
        while partner_idx == k
            partner_idx = randi(noP);
        end
        
        % The current learner interacts with the peer partner
        if Class(k).O < Class(partner_idx).O
            % Current learner is smarter; move away from the partner
            New_X = Class(k).X + rand(1, nVar) .* (Class(k).X - Class(partner_idx).X);
        else
            % Partner is smarter; move closer to the partner
            New_X = Class(k).X + rand(1, nVar) .* (Class(partner_idx).X - Class(k).X);
        end
        
        % Boundary Control
        New_X = max(New_X, lb);
        New_X = min(New_X, ub);
        
        % Evaluate the updated position
        New_O = fobj(New_X);
        
        % Greedy Selection: Keep the knowledge if it improves the student's grade
        if New_O < Class(k).O
            Class(k).X = New_X;
            Class(k).O = New_O;
        end
    end
    
    % Secondary pass to ensure global tracking variable stays updated
    for k = 1 : noP
        if Class(k).O < GBEST_O
            GBEST_O = Class(k).O;
            GBEST_X = Class(k).X;
        end
    end
    
    outmsg = ['Iteration# ', num2str(t) , ' TLBO.GBEST.O = ' , num2str(GBEST_O)];
    disp(outmsg);
    
    cgCurve(t) = GBEST_O;
end
 
% Plot results
figure;
semilogy(cgCurve, 'LineWidth', 2);
xlabel('Iteration#')
ylabel('Weight')
title('TLBO Convergence Curve')
grid on;