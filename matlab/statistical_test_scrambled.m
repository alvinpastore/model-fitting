
MLE_iter = [0, 1, 2, 3, 4, 5, 6, 7 ,8 ,9];


% load model results
current_results = 'res3';
model = eval(current_results);
model = model(find(model(:,2) ~= 0),:);

SORTEDMLE_NAME = 'MLEFULL';
sorted_MLE = eval(SORTEDMLE_NAME);

SCRAMBLEDMLE_NAME = 'MLESCRAM';

% count players
players = unique(model(:,1));
playersAmount = size(players,1);

% offset = amount of models in gridsearch
% = 5alphas X 4betas X 5gammas
OFFSET = 100;

% cell array to hold info about all comparisons
pvalues = cell(length(MLE_iter),1);
pv_idx = 1;

% save the players who are better than scrambled
better_than_scrambled = zeros(playersAmount+1,length(MLE_iter));

for i = MLE_iter 
    disp(['iteration ',num2str(i)]);
    scrambled_MLE = eval([SCRAMBLEDMLE_NAME,num2str(i)]);
    
    avg_scrambled_model = mean(scrambled_MLE(:,5:end).').';
    
    
    
    % initialise performances structure
    % [ID,  model_MLE, mean_MLE, median_MLE, mean_scram_MLE_corr, median_scram_MLE_corr, pvalue, mean_scram_MLE_best, median_scram_MLE_best, pvalue, modelMLE < mean_scram_MLE_corr, modelMLE < mean_scram_MLE_best] 
    current_pvalues = zeros(playersAmount,12);
    
    for playerID = 0:playersAmount-1
        %disp(num2str(playerID));
        % find player lines in model and MLE results 
        % (second condition to avoid random models where beta = 0)
        player_lines_model = find(model(:,1) == playerID  ); 
        
        player_lines_MLE = find(sorted_MLE(:,1) == playerID);
        
        % find best MLE full model 
        [p_best_MLE, p_best_MLE_line] = min(model(player_lines_model,5));
        
        % p_best_MLE_line is relative to the lines of playerID
        % the offset is the amount of lines (100) for each player
        corresponding_MLE_line = p_best_MLE_line + (playerID * OFFSET);
        
        % find corresponding MLE line in sorted 
        sorted_MLE_line = sorted_MLE(corresponding_MLE_line,5:end);
        %l_sort = sorted_MLE(corresponding_MLE_line,1:15)
        
        % find corresponding MLE line in scrambled
        scrambled_MLE_line = scrambled_MLE(corresponding_MLE_line,5:end);
        %l_scram_corr = scrambled_MLE(corresponding_MLE_line,1:15)
        
        % find best MLE scrambled model
        [s_best_MLE, s_best_MLE_line] = min(avg_scrambled_model(player_lines_MLE,:));
        corresponding_best_MLE_line = s_best_MLE_line + (playerID * OFFSET);
        scrambled_best_MLE_line = scrambled_MLE(corresponding_best_MLE_line,5:end);
        %l_scram_best = scrambled_MLE(corresponding_best_MLE_line,1:15)
        
        % calculate p-value for corresponding MLE scrambled
        [p_corr] = ranksum(sorted_MLE_line,scrambled_MLE_line);
        
        % calculate p-value for best MLE scrambled
        [p_best] = ranksum(sorted_MLE_line,scrambled_best_MLE_line);
        
        % The p-value <0.05 indicates that ranksum rejects the 
        % null hypothesis of equal medians at the default 5% significance level.
        %disp([num2str(playerID), '  ' ,num2str(p_corr),'  ', num2str(p_best)]);
        
        %if sum(isnan(sorted_MLE_line))>0
        %    disp('sortedMLEline');
        %end
        %if sum(isnan(scrambled_MLE_line))>0 
        %    disp('scrambledMLEline');
        %end
        %if sum(isnan(scrambled_best_MLE_line))>0 
        %    disp('scrambledBEstMLE');
        %end

        current_pvalues(playerID+1,:) = [playerID p_best_MLE mean(sorted_MLE_line) median(sorted_MLE_line) mean(scrambled_MLE_line) median(scrambled_MLE_line) p_corr mean(scrambled_best_MLE_line) median(scrambled_best_MLE_line) p_best p_best_MLE < mean(scrambled_MLE_line) p_best_MLE < mean(scrambled_best_MLE_line)];
        
    end
    
    % 1 for players better than best scrambled with statistical significance
    better_than_scrambled(:,i + 1) = [current_pvalues(:,12) & current_pvalues(:,10) < 0.01; sum(current_pvalues(:,12))];
    
    pvalues{pv_idx} = current_pvalues;
    pv_idx = pv_idx + 1;
    
end
disp(better_than_scrambled);
