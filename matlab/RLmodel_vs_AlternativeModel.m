% Setting for the comparison 

% 4 compare against alternative model (including nogamma)
% 5 compare against random model
CONFIG_COMPARISON = 5;

% 0 for other models
% 1 for nogamma models (less columns in results (5 instead of 6))
NOGAMMA_COMPARISON = 0;

% Dumb player number (0 for no dumb player)
DUMB_PLAYER = 0;

% number of actions for RANDOM COMPARISON
ACTIONS_AMOUNT = 10;

% name of ALTERNATIVE MODEL
ALTERNATIVE_MODEL = ['Dumb Player ' num2str(DUMB_PLAYER)];

MODEL_DESCRIPTION = [num2str(ACTIONS_AMOUNT),' actions vs '];

if CONFIG_COMPARISON == 5
    MODEL_DESCRIPTION = [MODEL_DESCRIPTION, 'Random Model'];
else
    if NOGAMMA_COMPARISON == 1
        MODEL_DESCRIPTION = [MODEL_DESCRIPTION, 'NoGamma Model'];
    else
        MODEL_DESCRIPTION = [MODEL_DESCRIPTION, ALTERNATIVE_MODEL];
    end
end

% get list of players from model results
players = unique(res_model(:,1));
playersAmount = size(players,1);

% store random model precision
p_random = 1/ACTIONS_AMOUNT;

performances = zeros(playersAmount,5);
outperformers = [];
for playerID = 0:playersAmount-1
    
    % search for player best model precision
    p_model_lines = find(res_model(:,1) == playerID); 
    p_model_best  = max(res_model(p_model_lines,6));
    
    % search for player best alternative model precision
    p_alternative_lines = find(res_alternative(:,1) == playerID); 
    if DUMB_PLAYER < 1
        ALTERNATIVE_COLUMN = 6 - NOGAMMA_COMPARISON;
    else
        ALTERNATIVE_COLUMN = DUMB_PLAYER + 1;
    end
    p_alternative_best  = max(res_alternative(p_alternative_lines, ALTERNATIVE_COLUMN));
    
    
    if p_alternative_best == 0
        disp(playerID)
        outperformers(size(outperformers,2)+1) = playerID;
    else
        % calculate improvement rates (over alternative model)
        improv_rate_altern = ((p_model_best-p_alternative_best)/p_alternative_best)*100;
    end
    
    % calculate improvement rates (over random model)
    improv_rate_random = ((p_model_best-p_random)/p_random)*100;
    
    % populate performances matrix
    performances(playerID+1,:) = [playerID p_model_best p_alternative_best improv_rate_altern improv_rate_random];
    
end

% calculate avg improvement performance
avg_improvement = mean(performances(:,CONFIG_COMPARISON));
tit = [num2str(ACTIONS_AMOUNT),' Actions - Precision Improvement, Avg: ',num2str(avg_improvement)];
if size(outperformers,2) > 0
    tit = [tit , ' outperformers: ',mat2str(outperformers)];
end


%%% PRINT unsorted bar chart
%figure(1);
%hold on
%bar(performances(:,1),performances(:,CONFIG_COMPARISON));
%plot([-1 46],[avg_improvement avg_improvement],'-r','LineWidth',2);

%title(tit,'FontSize', 24);
%xlabel('Players')
%ylabel(['Improvement over ',MODEL_DESCRIPTION])
%axis([-1 46 min(performances(:,CONFIG_COMPARISON)) max(performances(:,CONFIG_COMPARISON))]);
%set(gca,'fontsize', 24)
%legend('Individual improvement','Avg Improvement');
%hold off

%fileName = 'graphs_improvements\g_RL_RandBins_unsorted.png';
%print(fig,'-dpng',fileName)
    
% sort according to the improvement 
sorted_performances = sortrows(performances,CONFIG_COMPARISON);

% PRINT sorted bar chart
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

