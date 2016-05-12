

[MF_MLE, model_free] = MLE_model_importer('model_free');
[MB_MLE, model_based] = MLE_model_importer('model_based');
[NG_MLE, model_nogamma] = MLE_model_importer('no_gamma');

% TODO need to remove random?
%nogamma = nogamma(nogamma(:,2) ~= 0,:);

%% AIC delta test

NUM_PARAM = 3;
scram_DELTA = zeros(length(players),length(MLE_iter));

for playerID = 0:playersAmount-1
    % find best model MLE and calculate AIC

    % find player lines in model and MLE results 
    % (second condition to avoid random models where beta = 0)
    player_lines_model = find(model(:,1) == playerID  ); 

    % find best MLE full model 
    [p_best_MLE, p_best_MLE_line] = min(model(player_lines_model,5));
    aic_model = aicbic(p_best_MLE,NUM_PARAM);
    
    % find best scrambled MLE and calculate AIC
    for i = MLE_iter
        
        % load i-th scrambled and calculate averages of MLEs
        scrambled_MLE = MLESCRAMS(i);
        scrambled_MLE = scrambled_MLE{1};
        avg_scrambled = mean(scrambled_MLE(:,5:end).').';
        
        % find player lines
        player_lines_MLE = find(scrambled_MLE(:,1) == playerID);
        
        % find best MLE in i-th scrambled model
        [s_best_MLE, best_MLE_line] = min(avg_scrambled(player_lines_MLE,:));
        
        % calculate AIC for best MLE for i-th scrambled 
        % TODO this might be wrong. s_besst_MLE is negative logL
        % aicbic wants the logL
        aic_scram = aicbic(s_best_MLE,NUM_PARAM);
        
        % calculate difference and store AIC-DELTA
        scram_DELTA(playerID + 1,i + 1) = aic_model-aic_scram;
        
    end
end