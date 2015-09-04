% BOOLEAN flag for discretised correlations
DISCRETISE = 1;

%risk column is normally 2 but it is 4 for the discretised riskiness
RISK_COLUMN = 2 + 2*DISCRETISE; 

% thresholds for N actions (manually checked from data/uniform_N.txt)
thresholds = [0.066 0.166];

%% Discretise riskiness  
% TODO generalise code for N actions 
if DISCRETISE == 1
    t1 = 1 .* (arvectors(:,2) < thresholds(1));
    t2 = 2 .* (arvectors(:,2) > thresholds(1)) .* (arvectors(:,2) < thresholds(2));
    t3 = 3 .* (arvectors(:,2) > thresholds(2));
    
    arvectors(:,4) = t1 + t2 + t3; % discretised riskiness on column 4
end

% retrieve players 
players = unique(arvectors(:,1));
playersAmount = size(players,1);

% instantiate correlation vectors
correlations = zeros(playersAmount,3);


for playerID = 0:playersAmount-1    
    close all;
    % retrieve player lines
    player_lines = find(arvectors(:,1) == playerID); 
    
    % identify risk and reward vectors
    risk_vector = arvectors(player_lines,RISK_COLUMN);
    reward_vector = arvectors(player_lines,3);
    
    % calculate correlation and p-value
    [r,p] = corrcoef(risk_vector , reward_vector);
    R = r(1,2);
    P = p(1,2);
    
    % populate correlations vector
    correlations(playerID+1,:)  = [playerID R P];
    
    % interesting p-values (<1 for all)
    if P < 1
        disp(playerID);
        
        % calculate linear regression 
        p = polyfit(risk_vector,reward_vector,1);
        pp = polyval(p,risk_vector); 
        
        % generate figure
        figure();
        hold on
        
        scatter(risk_vector, reward_vector, 'rx');
        plot(risk_vector,pp,'-b');
        
        title(['Player: ',num2str(playerID), '  -  P-value ', num2str(P)]);
        xlabel('Risk');
        ylabel('Reward');
        legend('Scatter','Regression','Location','NorthWest')
        
        fileName = ['graphs_correlation_risk_reward\g-',num2str(playerID)];
        
        if DISCRETISE == 1
            fileName = [fileName, 'discretised.png'];
        end
        
        print(gcf, '-dpng', fileName)
        hold off
    end
    
end
