% routine for testing scrambled bins MLEs against RL model MLEs
% MLES generated with gradient descent
% comparison via BIC

tic
close all;
%subset of players well fit by rl (player = pid +1, as players start from 0)
nogamma_players = [11,18,28,31,33,37,42];

RESTRICTED = 0;
ALGORITHM = 'qlearning'; % alternative 'sarsa'
CAP = 107; % alternative 25
N_ACTIONS = 3;
RISK_MEASURE = 'beta'; % alternative 'risk'
STATE_TYPE =  'profit'; % alternative 'reward'
ALPHA_CONFIDENCE = 0.01; % 99% confidence
FONT_SIZE = 20;
LINE_WIDTH = 0.5;
SAVE_CONFIDENCE_INTERVALS = 0; % saves confidence intervals in players_CI.csv in results/stats folder
SAVE_FIG = 1;
SAVE_FOLDER = '../graphs/paper_correction/';
PRINT_WIDTH = 20;
PRINT_HEIGHT = 15;

% nogramma v random degrees of freedom
ng_dof = 2; % (alpha, beta) v (0)

% import scrambled MLE matrices
[scrambles_number, scrambles] = MLE_SCRAM_importer(RESTRICTED, ALGORITHM, CAP, N_ACTIONS);
scram_iterator = 1:scrambles_number;


% load model results (nogamma as it's the simplest model)
noGamma = MLE_model_importer(RESTRICTED, ALGORITHM, CAP, N_ACTIONS, RISK_MEASURE,STATE_TYPE,'_nogamma');
noGamma_MLEs = noGamma(:,5);

% count players
players = unique(noGamma(:,1));
players_number = size(players,1);

% the original amount of transactions
% depends only on the CAP (not restriction yet)
transactions_number = csvread(['../results/stats/transactions_number_',num2str(CAP),'CAP.csv']);
% the amount of transactions after removing the ones not used to calculate MLE
transactions = transactions_number - RESTRICTED;

% the random MLE value is calculated based on 
% the number of actions and the number of transactions
random_MLEs = - transactions * log(1 / N_ACTIONS);
% [rnd_aic,rnd_bic] = aicbic(-random_MLEs, ones(players_number,1), transactions);
% 
% % structure to save the comparisons results
model_v_scram_aic  = zeros(players_number,scrambles_number);
model_v_scram_bic  = zeros(players_number,scrambles_number);
% scram_v_random_aic = zeros(players_number,scrambles_number);
% scram_v_random_bic = zeros(players_number,scrambles_number);

% % calculate aic and bic for RL model (3 parameters)
[mod_aic,mod_bic] = aicbic(-model_MLEs, ones(players_number,1)*ng_dof, transactions);

% COMPARE RANKED VS SCRAMBLED AND
% FIND BEST SCRAMBLED COMPARED TO RANDOM

for i = scram_iterator 
    disp(['comparison with scrambled bin ',num2str(i)]);
    scrambled_MLE = scrambles(i);
    scrambled_MLE = scrambled_MLE{1};
    
    scrambled_MLEs = scrambled_MLE(:,5);
        
%    calculate aic and bic for scrambled model (nogamma version, 2 parameters)
    [scr_aic,scr_bic] = aicbic(-scrambled_MLEs, ones(players_number,1)*ng_dof, transactions);
     
    model_v_scram_aic(:,i) = mod_aic < scr_aic;
    model_v_scram_bic(:,i) = mod_bic < scr_bic;
% 
%     scram_v_random_aic(:,i) = scr_aic < rnd_aic;
%     scram_v_random_bic(:,i) = scr_bic < rnd_bic;
%     
end

% calculate for each player if the ranked bins are better than the
% scrambled ones and give a confidence interval (phat, pci)
% apply binomial CI test (clopper-pearson) at results of comparison

[phat_a, pci_a] = binofit(sum(model_v_scram_aic,2),scrambles_number,ALPHA_CONFIDENCE);
[phat_b, pci_b] = binofit(sum(model_v_scram_bic,2),scrambles_number,ALPHA_CONFIDENCE);

% [pID, phatAIC, pciAIC1, pciAIC2, phatBIC, pciBIC1, pciBIC2]
rank_v_scram_result = [model(:,1), phat_a, pci_a, phat_b, pci_b];

if SAVE_CONFIDENCE_INTERVALS
    csvwrite('../results/stats/players_CI.csv',rank_v_scram_result);
end

%errorbars ranked nogamma vs scrambled nogamma
fig01 = figure();
hold on;
eh1 = errorbar(rank_v_scram_result(:,1),rank_v_scram_result(:,2),rank_v_scram_result(:,2)-rank_v_scram_result(:,3),rank_v_scram_result(:,4)-rank_v_scram_result(:,2),'bx');
%eh2 = errorbar(rank_v_scram_result(:,1),rank_v_scram_result(:,5),rank_v_scram_result(:,5)-rank_v_scram_result(:,6),rank_v_scram_result(:,7)-rank_v_scram_result(:,5),'g');
set(eh1,'linewidth',LINE_WIDTH)
%set(eh2,'linewidth',LINE_WIDTH)
plot([0,47],[0.5,0.5],'r-');
axis([-1 47 0 1]);
xlabel('Player ID');
ylabel('Probability');
set(gca,'FontSize',FONT_SIZE);
set(gca,'Xtick',0:1:45,'XTickLabel',1:1:46);
grid minor
hold off;

%PAPER FIGURE
fig02 = figure();
hold on;
eh1 = errorbar(1:1:size(nogamma_players,2),rank_v_scram_result(nogamma_players,2),rank_v_scram_result(nogamma_players,2)-rank_v_scram_result(nogamma_players,3),rank_v_scram_result(nogamma_players,4)-rank_v_scram_result(nogamma_players,2),'b.');
%eh2 = errorbar(rank_v_scram_result(:,1),rank_v_scram_result(:,5),rank_v_scram_result(:,5)-rank_v_scram_result(:,6),rank_v_scram_result(:,7)-rank_v_scram_result(:,5),'g');
eh1.LineWidth = 2;
eh1.MarkerSize = 20;
plot([0,size(nogamma_players,2)+1],[0.5,0.5],'r-');
axis([0 size(nogamma_players,2)+1 0.4 1]);
xlabel('Players');
ylabel('Probability');
set(gca,'FontSize',FONT_SIZE);
set(gca,'Xtick',1:1:size(nogamma_players,2),'XTickLabel',nogamma_players);
set(gca,'Ytick',0.25:0.25:1);
%grid minor
hold off;

 if SAVE_FIG 
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        
        fileName = [SAVE_FOLDER, 'ranked_v_scrambled_subset_nogamma_',num2str(RESTRICTED),'restricted'];
        fileName = [fileName,'_',ALGORITHM];
        fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS)];
        fileName = [fileName,'_',RISK_MEASURE,'_',STATE_TYPE,'.png'];
        print(fig02, '-dpng', '-loose', fileName); 
end

%% ranked vs scrambled
% fig1 = figure();
% subplot(2,1,1)
% % plot aic results
% sorted_CI = sortrows(rank_v_scram_result,2);
% hold on;
% eh = errorbar(rank_v_scram_result(:,1),sorted_CI(:,2),sorted_CI(:,2)-sorted_CI(:,3),sorted_CI(:,4)-sorted_CI(:,2),'b');
% set(eh,'linewidth',LINE_WIDTH)
% plot([0,47],[0.5,0.5],'r-');
% axis([-1 47 0 1]);
% labels = num2str(sorted_CI(:,1));
% set(gca,'Xtick',0:1:46,'XTickLabel',labels);
% xlabel('Player ID');
% ylabel('Probability');
% set(gca,'FontSize',FONT_SIZE);
% title('AIC comparison');
% hold off;
% % 
% subplot(2,1,2)
% % % plot bic results
% sorted_CI = sortrows(rank_v_scram_result,5);
% hold on;
% eh = errorbar(rank_v_scram_result(:,1),sorted_CI(:,2),sorted_CI(:,2)-sorted_CI(:,3),sorted_CI(:,4)-sorted_CI(:,2),'g');
% set(eh,'linewidth',LINE_WIDTH)
% plot([0,47],[0.5,0.5],'r-');
% axis([-1 47 0 1]);
% labels = num2str(sorted_CI(:,1));
% set(gca,'Xtick',0:1:46,'XTickLabel',labels);
% xlabel('Player ID');
% ylabel('Probability');
% set(gca,'FontSize',FONT_SIZE);
% title('BIC comparison');
% hold off;
% if SAVE_FIG
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
%         path = '../graphs/stats/risk_classification/';
%         fileName = [path, RISK_MEASURE, '_vs_Scrambled_',num2str(RESTRICTED),'restricted'];
%         fileName = [fileName,'_',ALGORITHM];
%         fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'.png'];
%         print(fig1, '-dpng', '-loose', fileName); 
% end
%     
% %% scrambled vs random
% fig2 = figure();
% 
% subplot(2,1,1);
% bar(1:scrambles_number, sum(scram_v_random_aic));
% xlabel('Scramble ID');
% %ylabel('Frequency better than random (players)');
% axis([0 scrambles_number 0 46]);
% set(gca,'FontSize',FONT_SIZE);
% title('SCRAMBLES VS RANDOM AIC');
% subplot(2,1,2);
% %figure();
% 
% bar(1:scrambles_number, sum(scram_v_random_bic));
% xlabel('Scramble ID');
% ylabel('Frequency better than random (players)');
% axis([0 scrambles_number 0 46]);
% set(gca,'FontSize',FONT_SIZE);
% title('SCRAMBLES VS RANDOM BIC');
% if SAVE_FIG
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
%         path = '../graphs/stats/risk_classification/';
%         fileName = [path,num2str(scrambles_number),'_Scrambles_vs_Random_',num2str(RESTRICTED),'restricted'];
%         fileName = [fileName,'_',ALGORITHM];
%         fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'.png'];
%         print(fig2, '-dpng', '-loose', fileName); 
% end
toc