% Setting for the comparison 

% 4 compare against alternative model
% 5 compare against random model
CONFIG_COMPARISON = 4;

% 0 for alternative models
% 1 for nogamma models (less columns in results)
NOGAMMA_COMPARISON = 0;

MODEL_DESCRIPTION = 'Dumb Player 3';
% get list of players from model results
players = unique(res_model(:,1));
playersAmount = size(players,1);

% store random model precision
p_random = 1/3;

performances = zeros(playersAmount,5);
outperformers = [];
for playerID = 0:playersAmount-1
    
    % search for player best model precision
    p_model_lines = find(res_model(:,1) == playerID); 
    p_model_best  = max(res_model(p_model_lines,6));
    
    % search for player best alternative model precision
    p_alternative_lines = find(res_alternative(:,1) == playerID); 
    p_alternative_best  = max(res_alternative(p_alternative_lines,(6-NOGAMMA_COMPARISON)));
    % calculate improvement rates (over alternative model and over random model)
    if p_alternative_best == 0
        disp(playerID)
        outperformers(size(outperformers,2)+1) = playerID;
    else
        improv_rate_altern = ((p_model_best-p_alternative_best)/p_alternative_best)*100;
        improv_rate_random = ((p_model_best-p_random)/p_random)*100;
    end
    % populate performances matrix
    performances(playerID+1,:) = [playerID p_model_best p_alternative_best improv_rate_altern improv_rate_random];
    
end

% calculate avg improvement performance
avg_improvement = mean(performances(:,CONFIG_COMPARISON));
tit = ['Precision Improvement, Avg: ',num2str(avg_improvement), ' outperformers: ',mat2str(outperformers)];

% print unsorted bar chart
figure(1);
hold on
bar(performances(:,1),performances(:,CONFIG_COMPARISON));
plot([-1 46],[avg_improvement avg_improvement],'-r','LineWidth',2);

title(tit,'FontSize', 24);
xlabel('Players')
ylabel(['Improvement over ',MODEL_DESCRIPTION])
axis([-1 46 min(performances(:,CONFIG_COMPARISON)) max(performances(:,CONFIG_COMPARISON))]);
set(gca,'fontsize', 24)
legend('Individual improvement','Avg Improvement');
hold off
%fileName = 'graphs_improvements\g_RL_RandBins_unsorted.png';
%print(fig,'-dpng',fileName)
    
% sort according to the improvement 
sorted_performances = sortrows(performances,CONFIG_COMPARISON);

% print sorted bar chart
figure(2);
hold on
bar(performances(:,1),sorted_performances(:,CONFIG_COMPARISON));
plot([-1 46],[avg_improvement avg_improvement],'-r','LineWidth',2);

title(tit,'FontSize', 24);
xlabel('Players')
ylabel(['Improvement over ',MODEL_DESCRIPTION])
axis([-1 46 min(performances(:,CONFIG_COMPARISON)) max(performances(:,CONFIG_COMPARISON))]);
set(gca,'fontsize', 24)
set(gca,'Xtick',0:1:45);
set(gca,'XtickLabel',sorted_performances(:,1));
legend('Individual improvement','Avg Improvement','Location','NorthWest');
hold off
%fileName = 'graphs_improvements\g_RL_RandBins_sorted.png';
%print(fig,'-dpng',fileName)

