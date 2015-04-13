
% get list of players from model results
players = unique(res_model(:,1));
playersAmount = size(players,1);

performances = zeros(playersAmount,4);
for playerID = 0:playersAmount-1
    
    % search for player best model precision
    p_model_lines = find(res_model(:,1) == playerID); 
    p_model_best  = max(res_model(p_model_lines,6));
    
    % search for player best alternative model precision
    p_alternative_lines = find(res_alternative(:,1) == playerID); 
    p_alternative_best  = max(res_alternative(p_alternative_lines,6));
    
    % calculate improvement rates (over alternative model)
    improvementRate = ((p_model_best-p_alternative_best)/p_alternative_best);
    
    % populate performances matrix
    performances(playerID+1,:) = [playerID p_model_best p_alternative_best improvementRate];
    
end

% calculate avg improvement performance
avg_improvement = mean(performances(:,4));

figure(1);
hold on
bar(performances(:,1),performances(:,2),'r')
bar(performances(:,1),performances(:,3),'b')
plot([-1 46],[avg_improvement avg_improvement],'-r','LineWidth',2);
axis([-1 46 0 1]);

hold off  
% sort according to the improvement 
sorted_performances = sortrows(performances,2);

% print sorted bar chart
figure(2);
hold on
bar(performances(:,1),sorted_performances(:,2),'r')
bar(performances(:,1),sorted_performances(:,3),'b')
plot([-1 46],[avg_improvement avg_improvement],'-r','LineWidth',2);
axis([-1 46 0 1]);

set(gca,'Xtick',0:1:45);
set(gca,'XtickLabel',sorted_performances(:,1));
hold off