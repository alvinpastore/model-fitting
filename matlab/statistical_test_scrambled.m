% routine for testing scrambled bins MLEs against RL model MLEs
% MLES generated with gradient descent (deterministic)
% comparison via BIC

tic
close all;

RESTRICTED = 0;
ALGORITHM = 'qlearning';
CAP = 25;
N_ACTIONS = 3;
ALPHA_CONFIDENCE = 0.01; % 99% confidence
FONT_SIZE = 20;
LINE_WIDTH = 0.5;
% import scrambled MLE matrices
[scrambles_number, scrambles] = MLE_SCRAM_importer(RESTRICTED, ALGORITHM, CAP, N_ACTIONS);
scram_iterator = 1:scrambles_number;


% load model results
model = MLE_model_importer(0, 'qlearning', 25, 3);
model_MLEs = model(:,5);

% count players
players = unique(model(:,1));
players_number = size(players,1);

% the original amount of transactions
% depends only on the CAP (not restriction yet)
transactions_number = csvread(['../results/stats/transactions_number_',num2str(CAP),'CAP.csv']);
% the amount of transactions after removing the ones not used to calculate MLE
transactions = transactions_number - RESTRICTED;

% the random MLE value is calculated based on 
% the number of actions and the number of transactions
random_MLEs = - transactions * log(1 / N_ACTIONS);
[rnd_aic,rnd_bic] = aicbic(-random_MLEs, ones(players_number,1), transactions);

% structure to save the comparisons results
model_v_scram_aic  = zeros(players_number,scrambles_number);
model_v_scram_bic  = zeros(players_number,scrambles_number);
scram_v_random_aic = zeros(players_number,scrambles_number);
scram_v_random_bic = zeros(players_number,scrambles_number);

% calculate aic and bic for RL model (3 parameters)
[mod_aic,mod_bic] = aicbic(-model_MLEs, ones(players_number,1)*3, transactions);

% COMPARE RANKED VS SCRAMBLED AND
% FIND BEST SCRAMBLED COMPARED TO RANDOM

for i = scram_iterator 
    disp(['comparison with scrambled bin ',num2str(i)]);
    scrambled_MLE = scrambles(i);
    scrambled_MLE = scrambled_MLE{1};
    
    scrambled_MLEs = scrambled_MLE(:,5);
    
    % calculate aic and bic for scrambled model (3 parameters)
    [scr_aic,scr_bic] = aicbic(-scrambled_MLEs, ones(players_number,1)*3, transactions);
    
    model_v_scram_aic(:,i) = mod_aic < scr_aic;
    model_v_scram_bic(:,i) = mod_bic < scr_bic;

    scram_v_random_aic(:,i) = scr_aic < rnd_aic;
    scram_v_random_bic(:,i) = scr_bic < rnd_bic;
    
end

% calculate for each player if the ranked bins are better than the
% scrambled ones and give a confidence interval (phat, pci)
% apply binomial CI test (clopper-pearson) at results of comparison
[phat_a, pci_a] = binofit(sum(model_v_scram_aic,2),scrambles_number,ALPHA_CONFIDENCE);
[phat_b, pci_b] = binofit(sum(model_v_scram_bic,2),scrambles_number,ALPHA_CONFIDENCE);

% [pID, phatAIC, pciAIC1, pciAIC2, phatBIC, pciBIC1, pciBIC2]
rank_v_scram_result = [model(:,1), phat_a, pci_a, phat_b, pci_b];

%% ranked vs scrambled
subplot(2,1,1)
% plot aic results
sorted_CI = sortrows(rank_v_scram_result,2);
hold on;
eh = errorbar(rank_v_scram_result(:,1),sorted_CI(:,2),sorted_CI(:,2)-sorted_CI(:,3),sorted_CI(:,4)-sorted_CI(:,2),'b');
set(eh,'linewidth',LINE_WIDTH)
plot([0,47],[0.5,0.5],'r-');
axis([-1 47 0 1]);
labels = num2str(sorted_CI(:,1));
set(gca,'Xtick',0:1:46,'XTickLabel',labels);
xlabel('Player ID');
ylabel('Probability');
set(gca,'FontSize',FONT_SIZE);
title('AIC comparison');
hold off;

subplot(2,1,2)
% plot bic results
sorted_CI = sortrows(rank_v_scram_result,5);
hold on;
eh = errorbar(rank_v_scram_result(:,1),sorted_CI(:,2),sorted_CI(:,2)-sorted_CI(:,3),sorted_CI(:,4)-sorted_CI(:,2),'g');
set(eh,'linewidth',LINE_WIDTH)
plot([0,47],[0.5,0.5],'r-');
axis([-1 47 0 1]);
labels = num2str(sorted_CI(:,1));
set(gca,'Xtick',0:1:46,'XTickLabel',labels);
xlabel('Player ID');
ylabel('Probability');
set(gca,'FontSize',FONT_SIZE);
title('BIC comparison');
hold off;

%% scrambled vs random
figure();
title('SCRAMBLES VS RANDOM');
subplot(2,1,1);
bar(1:scrambles_number, sum(scram_v_random_aic));
axis([-1 101 0 46]);
set(gca,'FontSize',FONT_SIZE);
subplot(2,1,2);
bar(1:scrambles_number, sum(scram_v_random_bic));
xlabel('Scramble ID');
ylabel('Frequency better than random (players)');
axis([-1 101 0 46]);
set(gca,'FontSize',FONT_SIZE);

toc