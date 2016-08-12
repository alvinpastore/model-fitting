%DEPRECATED after probability calculation bugfix, no stochasticity in the MLE

%% creates a histogram for each players best model free 
% plotting the distribution of the MLEs
% used to investigate the distribution of MLEs (Central Limit Theorem) 
close all;

SAVE_FIG = 1;

% offset = amount of models in gridsearch
% = 5alpha X 4betas X 5gammas
OFFSET = 100;
REPETITIONS = 1000;
BINS_NUMBER = REPETITIONS/10;


[MF_MLE, model_free] = MLE_model_importer('model_free',REPETITIONS);
model_free = model_free(model_free(:,2) ~= 0,:);  

% count players
players = unique(model_free(:,1));
playersAmount = size(players,1);
mode_mean = zeros(playersAmount,2);

for playerID = 0:playersAmount-1
    
    % find player lines in model and MLE results for model free
    player_lines_model_free = find(model_free(:,1) == playerID); 
    [MF_best_MLE, MF_best_MLE_line] = min(model_free(player_lines_model_free,5));
    % MF_best_MLE_line is relative to the lines of playerID
    % the offset is the amount of lines (100) for each player
    corresponding_MLE_line = MF_best_MLE_line + (playerID * OFFSET);
    % find corresponding MLE line in model 
    model_free_MLE_line = MF_MLE(corresponding_MLE_line,5:end);
    param_set = MF_MLE(corresponding_MLE_line,2:4);
    
    figure()
    hist(model_free_MLE_line,BINS_NUMBER);
    title(['alpha ',num2str(param_set(1)),' - beta ',num2str(param_set(2)),' - gamma ',num2str(param_set(3))]);
    disp(['Player ' , num2str(playerID)]);
    mode_mean(playerID + 1,:) = [mode(model_free_MLE_line) , mean(model_free_MLE_line)];
    
    
    if SAVE_FIG
        fileName = ['../graphs/MLE_distributions/best_model_',num2str(REPETITIONS),'rep/g-',num2str(playerID),'.png'];
        %print(gcf, '-dpng', fileName)
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 27 21]); %x_width=10cm y_width=15cm
        saveas(gcf,fileName);
    end
    close(gcf);
end