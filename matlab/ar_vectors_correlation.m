% Actions Rewards correlation
% calculates the correlation between the actions and the rewards obtained 
% for each player and cumulatively

tic;
close all;

SAVE_FIG = 0;
P_VALUE_THRESHOLD = 0.05;

% load the data
arvectors = csvread('../results/ar_vectors/ar_vectors.csv');

% BOOLEAN flag for discretised correlations
% using bins of risk based on riskiness 
% instead of the riskiness measure on its own
DISCRETISE = 1;

%risk column is normally 2 but it is 4 for the discretised riskiness
RISK_COLUMN = 2 + (2 * DISCRETISE); 

% thresholds for N actions (manually checked from data/uniform_N.txt)
thresholds = [0.066 0.166];

%% Discretise riskiness  
% this is to determine to which bin of risk each action corresponds
if DISCRETISE == 1
    t1 = 1 .* (arvectors(:,2) < thresholds(1));
    t2 = 2 .* (arvectors(:,2) > thresholds(1)) .* (arvectors(:,2) < thresholds(2));
    t3 = 3 .* (arvectors(:,2) > thresholds(2));
    
    arvectors(:,4) = t1 + t2 + t3; % discretised riskiness on column 4
end

% count players 
players = unique(arvectors(:,1));
playersAmount = size(players,1);

% instantiate correlation vectors
correlations = zeros(playersAmount,3);


for playerID = 0:playersAmount-1    
    
    % retrieve player lines
    player_lines = find(arvectors(:,1) == playerID); 
    
    % identify action(risk bin) and reward vectors
    actions = arvectors(player_lines,RISK_COLUMN);
    rewards = arvectors(player_lines,3);
    
    % calculate correlation and p-value
    [r,p] = corrcoef(actions , rewards);
    R = r(1,2);
    P = p(1,2);
    
    % populate correlations vector
    correlations(playerID+1,:)  = [playerID R P];
    
    % interesting p-values (<1 for all)
    if P < P_VALUE_THRESHOLD
        disp(playerID);
        
        % calculate linear regression 
        p = polyfit(actions,rewards,1);
        pp = polyval(p,actions); 
        
        % generate figure
        figure();
        hold on
        
        scatter(actions, rewards, 'rx');
        plot(actions,pp,'-b');
        
        title(['Player: ',num2str(playerID), ' R: ',num2str(R),' -  P-value: ', num2str(P)]);
        xlabel('Risk');
        ylabel('Reward');
        axis([0.5, 3.5, -1, 1]);
        legend('Scatter','Regression','Location','NorthWest')
        set(gca,'XTick',[1,2,3]);
        set(gca,'XTickLabel',{'low','mid','high'})
        set(gca,'FontSize',20)



        if SAVE_FIG
            fileName = ['graphs_correlation_risk_reward\g-',num2str(playerID)];
            if DISCRETISE == 1
                fileName = [fileName, 'discretised.png'];
            end
            print(gcf, '-dpng', fileName)
        end
        
        hold off
    end    
end

% cumulative correlation
actions = arvectors(:,RISK_COLUMN);
rewards = arvectors(:,3);
% calculate correlation and p-value
[r,p] = corrcoef(actions , rewards);
R = r(1,2);
P = p(1,2);
p = polyfit(actions,rewards,1);
pp = polyval(p,actions); 

% generate figure
figure();
hold on

scatter(actions, rewards, 'rx');
plot(actions,pp,'-b');

title(['All players all actions -  R: ',num2str(R),'  -  P-value ', num2str(P)]);
xlabel('Risk');
ylabel('Reward');
axis([0.5, 3.5, -1, 1]);
legend('Scatter','Regression','Location','NorthWest')
set(gca,'XTick',[1,2,3]);
set(gca,'XTickLabel',{'low','mid','high'})
set(gca,'FontSize',20)
    
toc

