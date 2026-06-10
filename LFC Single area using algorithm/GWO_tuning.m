clear all
close all
clc

% Define the details of the table design problem
nVar = 3;                 % number of variables  
ub = [1000 1000 1000];    % upper Bound
lb = [0 0 0];             % lower bound  
fobj = @tunning;          % Objective function Name

% Define the GWO's parameters 
SearchAgents_no = 15;     % number of wolves (equivalent to noP)
maxIter = 10;              % maximum iterations

% Initialize the positions of grey wolves
for k = 1 : SearchAgents_no
    Positions(k, :) = (ub - lb) .* rand(1, nVar) + lb; 
end

% Initialize Alpha, Beta, and Delta positions and scores
Alpha_pos = zeros(1, nVar);
Alpha_score = inf; % Using inf for minimization

Beta_pos = zeros(1, nVar);
Beta_score = inf;

Delta_pos = zeros(1, nVar);
Delta_score = inf;

% Main loop
for t = 1 : maxIter
    
    % Calculate objective values and update Alpha, Beta, and Delta
    for i = 1 : SearchAgents_no
        
        % Return back the search agents that go beyond the boundaries
        Positions(i, :) = max(Positions(i, :), lb);
        Positions(i, :) = min(Positions(i, :), ub);
        
        % Calculate objective function for each search agent
        fitness = fobj(Positions(i, :));
        
        % Update Alpha, Beta, and Delta
        if fitness < Alpha_score 
            Delta_score = Beta_score; % Delta is updated from Beta
            Delta_pos = Beta_pos;
            
            Beta_score = Alpha_score; % Beta is updated from Alpha
            Beta_pos = Alpha_pos;
            
            Alpha_score = fitness; % Update Alpha
            Alpha_pos = Positions(i, :);
            
        elseif fitness > Alpha_score && fitness < Beta_score
            Delta_score = Beta_score; % Delta is updated from Beta
            Delta_pos = Beta_pos;
            
            Beta_score = fitness; % Update Beta
            Beta_pos = Positions(i, :);
            
        elseif fitness > Alpha_score && fitness > Beta_score && fitness < Delta_score
            Delta_score = fitness; % Update Delta
            Delta_pos = Positions(i, :);
        end
    end
    
    % Linearly decrease 'a' from 2 to 0 to control exploration/exploitation
    a = 2 - t * (2 / maxIter); 
    
    % Update the position of search agents including omega
    for i = 1 : SearchAgents_no
        for j = 1 : nVar
            
            % Update position relative to Alpha
            r1 = rand(); r2 = rand();
            A1 = 2 * a * r1 - a; 
            C1 = 2 * r2; 
            D_alpha = abs(C1 * Alpha_pos(j) - Positions(i, j)); 
            X1 = Alpha_pos(j) - A1 * D_alpha; 
                       
            % Update position relative to Beta
            r1 = rand(); r2 = rand();
            A2 = 2 * a * r1 - a; 
            C2 = 2 * r2; 
            D_beta = abs(C2 * Beta_pos(j) - Positions(i, j)); 
            X2 = Beta_pos(j) - A2 * D_beta; 
            
            % Update position relative to Delta
            r1 = rand(); r2 = rand();
            A3 = 2 * a * r1 - a; 
            C3 = 2 * r2; 
            D_delta = abs(C3 * Delta_pos(j) - Positions(i, j)); 
            X3 = Delta_pos(j) - A3 * D_delta; 
            
            % The final position is the average of X1, X2, and X3
            Positions(i, j) = (X1 + X2 + X3) / 3;
            
        end
    end
    
    outmsg = ['Iteration# ', num2str(t) , ' Alpha_score = ' , num2str(Alpha_score)];
    disp(outmsg);
    
    cgCurve(t) = Alpha_score;
end
 
% Plot results
figure;
semilogy(cgCurve, 'LineWidth', 2);
xlabel('Iteration#')
ylabel('Weight')
title('GWO Convergence Curve')
grid on;