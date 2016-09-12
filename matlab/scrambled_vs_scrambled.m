% routine for testing scrambled MLEs against each other
% DEPRECATED ?
tic

% import scrambled MLE matrices
% if the MLESCRAMS have been already imported use 0 as input and use a dummy for MLESCRAMS
[Num, MLESCRAMS_dummy] = MLE_SCRAM_importer(0);
[MLEFULL, model] = MLE_model_importer('model_free');

MLE_iter = 1:Num;

% load model results
% remove random model lines
model = model(find(model(:,2) ~= 0),:);

% count players
players = unique(model(:,1));
playersAmount = size(players,1);

% offset = amount of models in gridsearch
% 5alphas X 4betas X 5gammas
OFFSET = 100;

% cell array to hold info about all comparisons
scram_compare = cell(Num * Num,1);
pv_idx = 1;

% permutations of models minus model with itself (N*N)-N
PERMUTATIONS = (Num * Num) - Num;
% save the players who are better than scrambled
% last row is for the sum (how many players are better than that scram)
better_than_scrambled = zeros(playersAmount+1,PERMUTATIONS);
bts_idx = 1;

for i = MLE_iter
    
    % scram model first
    first_scrambled_MLE = MLESCRAMS(i);
    first_scrambled_MLE = first_scrambled_MLE{1};
    % mean calculates for each col, hence the transpose and re-transpose
    % to have the mean of each row
    avg_first_scrambled = mean(first_scrambled_MLE(:,5:end)')';
    
    for k = MLE_iter
        if i ~= k
            disp(['i ',num2str(i),' k: ',num2str(k),' bts_idx: ',num2str(bts_idx)]);
            % initialise performances structure
            % [playerID first_best_MLE second_best_MLE first_best_MLE < second_best_MLE pv_MLE] 
            current_pvalues = zeros(playersAmount,5);
            
            % scram model second
            second_scrambled_MLE = MLESCRAMS(k);
            second_scrambled_MLE = second_scrambled_MLE{1};
            avg_second_scrambled = mean(second_scrambled_MLE(:,5:end)')';
            
            for playerID = 0:playersAmount-1

                % find player lines
                player_lines_MLE = find(first_scrambled_MLE(:,1) == playerID);
                
                % find best MLE first scrambled model (using mean, this
                % might not be correct because of CLT not holding true)
                [first_best_MLE, first_best_MLE_line] = min(avg_first_scrambled(player_lines_MLE,:));
               
                corresponding_best_MLE_line = first_best_MLE_line + (playerID * OFFSET);
                first_MLE_line = first_scrambled_MLE(corresponding_best_MLE_line,5:end);

                % find best MLE second scrambled model
                [second_best_MLE, second_best_MLE_line] = min(avg_second_scrambled(player_lines_MLE,:));
               
                corresponding_best_MLE_line = second_best_MLE_line + (playerID * OFFSET);
                second_MLE_line = second_scrambled_MLE(corresponding_best_MLE_line,5:end);
                
                % calculate p-value 
                % Wilcoxon rank sum test for equal medians
                [pv_MLE] = ranksum(first_MLE_line,second_MLE_line);

                current_pvalues(playerID+1,:) = [playerID first_best_MLE second_best_MLE first_best_MLE < second_best_MLE pv_MLE];

            end

            % add column of 1 for players better than best scrambled with statistical significance
            better_than_scrambled(1:end-1,bts_idx) = current_pvalues(:,4) & current_pvalues(:,5) < 0.01;
            bts_idx = bts_idx + 1;
            scram_compare{pv_idx} = current_pvalues;
            pv_idx = pv_idx + 1;
        end
    end
end

better_than_scrambled(end,:) = sum(better_than_scrambled,1);

disp(better_than_scrambled);
avg_model = 0.55;
avg_players = sum(better_than_scrambled(47,:)) / length(better_than_scrambled);
disp(['average players scram_vs_scram ',num2str(avg_players)]);
avg_percent = avg_players/length(players);
disp(['average percentage ',num2str(avg_percent)]);
zeta = 1.96;%2.57;

% TODO -> this normal approximation is probably wrong because the CLT does
% not hold for this data. Check: wikipedia.org/wiki/Mann?Whitney_U_test#Normal_approximation_and_tie_correction

width = zeta*sqrt( (avg_percent * (1 - avg_percent)) / (length(players) * length(better_than_scrambled) ));
disp(['width scrambled',num2str(width)]);
disp(['min ',num2str(avg_percent-width),' max ',num2str(avg_percent+width)]);

hold on;
errorbar(1,avg_percent,width,width,'bx');
plot(1,avg_percent,'xb','MarkerSize',10);

width = zeta*sqrt( (avg_model * (1 - avg_model)) / (length(players) * length(MLE_iter) ));
disp(['width model',num2str(width)]);
errorbar(1,avg_model, width,width,'rx');
plot(1,avg_model,'xr','MarkerSize',10);

axis([0.9 1.1 avg_percent - 2 * width max(avg_model + 2 * width,avg_percent + 2 * width)]);
title('Ranked vs Scrambled bins (95% confidence)','FontSize',20);
ylabel('% players better fitted by ranked','FontSize',20);


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
%clearvars -except MLESCRAMS better_than_scrambled MLEFULL* res3

toc