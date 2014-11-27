
% get list of players from model results
players = unique(res_model(:,1));
playersAmount = size(players,1);

% store random model precision
p_random = 1/3;

performances = zeros(playersAmount,5);

for playerID = 0:playersAmount-1
    
    % search for player best model precision
    p_model_lines = find(res_model(:,1) == playerID); 
    p_model_best  = max(res_model(p_model_lines,6));
    
    % search for player best nogamma precision
    p_nogamma_lines = find(res_nogamma(:,1) == playerID); 
    p_nogamma_best  = max(res_nogamma(p_nogamma_lines,5));
    
    % calculate improvement rates (over gamma and over random model)
    improvementRate1 = ((p_model_best-p_nogamma_best)/p_nogamma_best);
    improvementRate2 = ((p_model_best-p_random)/p_random);
    
    % print to console
    %disp(['P: ',num2str(playerID),', RL: ',num2str(p_model_best),', NoG: ',num2str(p_nogamma_best),', RL-NG:',num2str(improvementRate1),', RL-RM:',num2str(improvementRate2)]);
    
    % populate performances matrix
    performances(playerID+1,:) = [playerID p_model_best p_nogamma_best improvementRate1 improvementRate2];
    
end

% calculate avg improvement performance
avg_improvement = mean(performances(:,5));

% print unsorted bar chart
fig=figure(1);
hold on
bar(performances(:,1),performances(:,5));
plot(0:0.01:46,avg_improvement,'-r');
title(['Precision Improvement, Avg: ',num2str(avg_improvement)]);
xlabel('Players')
ylabel('Improvement over Random')
axis([-1 46 min(performances(:,5)) max(performances(:,5))]);
hold off
fileName = 'graphs_improvements\g_RLRM_unsorted.eps';
print(fig,'-depsc',fileName)
    
% sort according to the improvement 
sorted_performances = sortrows(performances,5);

% print sorted bar chart
fig=figure(2);
hold on
bar(performances(:,1),sorted_performances(:,5));
plot(0:0.01:46,avg_improvement,'-r');
title(['Precision Improvement, Avg: ',num2str(avg_improvement)]);
xlabel('Players')
ylabel('Improvement over Random')
axis([-1 46 min(performances(:,5)) max(performances(:,5))]);
set(gca,'Xtick',0:1:45);
set(gca,'XtickLabel',sorted_performances(:,1));
hold off
fileName = 'graphs_improvements\g_RLRM_sorted.eps';
print(fig,'-depsc',fileName)

