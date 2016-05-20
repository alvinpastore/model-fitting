

%% creates a histogram for each players best model free 
% plotting the distribution of the MLEs
% used to investigate the distribution of MLEs (Central Limit Theorem) 
close all;

% offset = amount of models in gridsearch
% = 5alpha X 4betas X 5gammas
OFFSET = 100;
REPETITIONS = 5000;
BINS_NUMBER = REPETITIONS/10;


%[MF_MLE, model_free] = MLE_model_importer('model_free',REPETITIONS);
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
    
    figure()
    hist(model_free_MLE_line,BINS_NUMBER);
    disp(['Player ' , num2str(playerID)]);
    mode_mean(playerID + 1,:) = [mode(model_free_MLE_line) , mean(model_free_MLE_line)];
    
end