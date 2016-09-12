%% Compare the MLEs of the best model vs the best model based
% DEPRECATED ?
% uses a 2 stage binarisation and binomial fit
% 1) compare every MLE instance to the MLE vector of the alternative model
% 2) apply binomial fit and get p value and confidence interval
% 3) if confidence interval is above chance threshold (0.5) mark as better (1)
% 4) apply binomial fit to the resulting binary vector 
% 5) store and visualise the p-hat and p-ci 

tic

% load models and remove random models 
% (lines where the alpha parameter (column 2) is 0
[MF_MLE, model_free] = MLE_model_importer('model_free',1000);
model_free = model_free(model_free(:,2) ~= 0,:);  

[MB_MLE, model_based] = MLE_model_importer('model_based',1000,5);
model_based = model_based(model_based(:,2) ~= 0,:);
% used for testing model free against itself
%[MB_MLE, model_based] = MLE_model_importer('model_free',5000); 

% % extend to no gamma
% [NG_MLE, model_nogamma] = MLE_model_importer('no_gamma',1000);
% model_nogamma = model_nogamma(model_nogamma(:,2) ~= 0,:);


% offset = amount of models in gridsearch
% = 5alpha X 4betas X 5gammas
OFFSET = 100;
alpha_confidence = 0.01;    % 99% confidence
iterations = 1000;
COMPARISON_FACTOR = 0;      % tolerance level (-0.05 or 0.05 for conservative or tolerating, 0 for standard comparison)
CHANCE_THRESHOLD = 0.5;     % probability threshold for chance

FONT_SIZE = 20;

% count players
players = unique(model_free(:,1));
playersAmount = size(players,1);

players_CI = zeros(playersAmount,4);

for playerID = 0:playersAmount-1
   
    disp(['Player ' , num2str(playerID)]);
    
    % find player lines in model and MLE results for model free
    player_lines_model_free = find(model_free(:,1) == playerID); 
    [MF_best_MLE, MF_best_MLE_line] = min(model_free(player_lines_model_free,5));
    % MF_best_MLE_line is relative to the lines of playerID
    % the offset is the amount of lines (100) for each player
    corresponding_MLE_line = MF_best_MLE_line + (playerID * OFFSET);
    % find corresponding MLE line in model 
    model_free_MLE_line = MF_MLE(corresponding_MLE_line,5:end);
    
    % for model based
    player_lines_model_based = find(model_based(:,1) == playerID); 
    [MB_best_MLE, MB_best_MLE_line] = min(model_based(player_lines_model_based,5));
    corresponding_MLE_line = MB_best_MLE_line + (playerID * OFFSET);
    model_based_MLE_line = MB_MLE(corresponding_MLE_line,5:end);
    
%     % for nogamma
%     player_lines_no_gamma = find(model_nogamma(:,1) == playerID); 
%     [NG_best_MLE, NG_best_MLE_line] = min(model_nogamma(player_lines_no_gamma,5));
%     corresponding_MLE_line = NG_best_MLE_line + (playerID * OFFSET);
%     model_nogamma_MLE_line = NG_MLE(corresponding_MLE_line,5:end);
    
    row_idx = 1;
    % binary vectors, 1 if phat+-CI > 0.5, 0 otherwise
    MB_MF_results_player = zeros(1,iterations);
    MB_NG_results_player = zeros(1,iterations);
    
    % logical comparison of each value from MF_MLE against MB_MLE and NG_MLE
    for MLE_instance = model_based_MLE_line 
        %% TEST MB VS MF
        MLE_comparison = MLE_instance < model_free_MLE_line + (model_free_MLE_line * COMPARISON_FACTOR);
        
        % apply binomial CI test (clopper-pearson) at results of comparison
        [phat, pci] = binofit(sum(MLE_comparison),length(model_free_MLE_line),alpha_confidence);
        
        % if the Confidence Interval is above 0.5 threshold 
        % the MLE instance is stat. sign. better than model based
        if min(phat,min(pci)) > CHANCE_THRESHOLD
            MB_MF_results_player(row_idx) = 1;
        end
        
        %% TEST MB VS NG
        
%         MLE_comparison = MLE_instance < model_nogamma_MLE_line + (model_nogamma_MLE_line * COMPARISON_FACTOR);
%         
%         % apply binomial CI test (clopper-pearson) at results of comparison
%         [phat, pci] = binofit(sum(MLE_comparison),length(model_nogamma_MLE_line),alpha_confidence);
% 
%         if min(phat,min(pci)) > CHANCE_THRESHOLD
%             MB_NG_results_player(row_idx) = 1;
%         end
        
        row_idx = row_idx + 1;
    end
    
    % apply binomial CI test (clopper-pearson) at MLE instances outcomes
    [phat_MB_MF, pci_MB_MF] = binofit(sum(MB_MF_results_player),size(MB_MF_results_player,2),alpha_confidence);
%     [phat_MB_NG, pci_MB_NG] = binofit(sum(MB_NG_results_player),size(MB_NG_results_player,2),alpha_confidence);
    
    players_CI(playerID+1,:) = [playerID phat_MB_MF pci_MB_MF(1) pci_MB_MF(2)];% phat_MB_NG pci_MB_NG(1) pci_MB_NG(2)];
end


sorted_CI = sortrows(players_CI,2);

close all;
figure();
hold on;
errorbar(players_CI(:,1),sorted_CI(:,2),sorted_CI(:,2)-sorted_CI(:,3),sorted_CI(:,4)-sorted_CI(:,2));
plot([0,47],[0.5,0.5],'r-');
axis([-1 47 0 1]);
labels = num2str(sorted_CI(:,1));
set(gca,'Xtick',0:1:46,'XTickLabel',labels);
xlabel('Player ID');
ylabel('Probability');
set(gca,'FontSize',FONT_SIZE);
hold off;
%clearvars -except better_than_scrambled MLESCRAMS MLEFULL* res3 players_CI sorted_CI SCRAM_NUMBER model_MLE;

%csvwrite('../results/stats/players_CI.csv',players_CI);
disp('statistica_test_scrambled_2_stage_binomial');


% 
% %% AIC delta test
% 
% NUM_PARAM = 3;
% scram_DELTA = zeros(length(players),length(MLE_iter));
% 
% for playerID = 0:playersAmount-1
%     % find best model MLE and calculate AIC
% 
%     % find player lines in model and MLE results 
%     % (second condition to avoid random models where beta = 0)
%     player_lines_model = find(model(:,1) == playerID  ); 
% 
%     % find best MLE full model 
%     [p_best_MLE, p_best_MLE_line] = min(model(player_lines_model,5));
%     aic_model = aicbic(p_best_MLE,NUM_PARAM);
%     
%     % find best scrambled MLE and calculate AIC
%     for i = MLE_iter
%         
%         % load i-th scrambled and calculate averages of MLEs
%         scrambled_MLE = MLESCRAMS(i);
%         scrambled_MLE = scrambled_MLE{1};
%         avg_scrambled = mean(scrambled_MLE(:,5:end).').';
%         
%         % find player lines
%         player_lines_MLE = find(scrambled_MLE(:,1) == playerID);
%         
%         % find best MLE in i-th scrambled model
%         [s_best_MLE, best_MLE_line] = min(avg_scrambled(player_lines_MLE,:));
%         
%         % calculate AIC for best MLE for i-th scrambled 
%         % TODO this might be wrong. s_besst_MLE is negative logL
%         % aicbic wants the logL
%         aic_scram = aicbic(s_best_MLE,NUM_PARAM);
%         
%         % calculate difference and store AIC-DELTA
%         scram_DELTA(playerID + 1,i + 1) = aic_model-aic_scram;
%         
%     end
% end
toc