% routine for testing scrambled MLEs against RL model
tic

% import scrambled MLE matrices
[SCRAM_NUMBER, MLESCRAMS, model_MLE, res3] = MLE_SCRAM_importer();
MLE_iter = 1:SCRAM_NUMBER;

% load model results
model = res3;
model = model(find(model(:,2) ~= 0),:);


% offset = amount of models in gridsearch
% = 5alphas X 4betas X 5gammas
OFFSET = 100;
alpha = 0.01; % 99% confidence
iterations = 1000;

% count players
players = unique(model(:,1));
playersAmount = size(players,1);

players_CI = zeros(playersAmount,4);

for playerID = 0:playersAmount-1
    disp(num2str(playerID));
    % find player lines in model and MLE results 
    % (second condition to avoid random models where beta = 0)
    player_lines_model = find(model(:,1) == playerID  ); 

    player_lines_MLE = find(model_MLE(:,1) == playerID);

    % find best MLE full model 
    [p_best_MLE, p_best_MLE_line] = min(model(player_lines_model,5));

    % p_best_MLE_line is relative to the lines of playerID
    % the offset is the amount of lines (100) for each player
    corresponding_MLE_line = p_best_MLE_line + (playerID * OFFSET);

    % find corresponding MLE line in model 
    model_MLE_line = model_MLE(corresponding_MLE_line,5:end);
    
    % find corresponding MLE line in scrambled
    scrambled_MLE_line = zeros(1,SCRAM_NUMBER * iterations);
    
    % create scrams MLEs vector (100k = 100 x 1000 (scrams x iterations))
    for i = MLE_iter % iterate over the 100 scrambled bins
        scrambled_MLE = MLESCRAMS(i);
        scrambled_MLE = scrambled_MLE{1};
        % append the 1000 scrambled MLEs 
        current_index = 1 + ((i -1) * iterations);
        scrambled_MLE_line(1, current_index:i*iterations) = scrambled_MLE(corresponding_MLE_line,5:end-1); % end-1 because of trailing 0???
    end
    % structure: rows are the model MLE instances
    % columns are comparison of MLE instance with other scrambleds MLEs
    MLE_comparison = zeros(iterations,SCRAM_NUMBER * iterations);
    row_idx = 1;
    
    % binary vectors, 1 if phat+-CI > 0.5, 0 otherwise
    MLE_results_player = zeros(1,iterations);
    
    % logical comparison of each value from model_MLE with all scrambles
    for MLE_instance = model_MLE_line(:,1:end-1)
        MLE_comparison(row_idx,:) = MLE_instance < scrambled_MLE_line;
        
        % apply binomial CI test (clopper-pearson) at results of comparison
        [phat, pci] = binofit(sum(MLE_comparison(row_idx,:)),SCRAM_NUMBER * iterations,alpha);
        
        % if the Confidence Interval is above 0.5 threshold 
        % the MLE instance is stat. sign. better than scrambled
        if min(phat,min(pci)) > 0.5
            MLE_results_player(row_idx) = 1;
        end
        
        row_idx = row_idx + 1;
    end
    
    
    % apply binomial CI test (clopper-pearson) at MLE instances outcomes
    [phat, pci] = binofit(sum(MLE_results_player),size(MLE_results_player,2),alpha);
    
    players_CI(playerID+1,:) = [playerID phat pci(1) pci(2)];
    
end


sorted_CI = sortrows(players_CI,2);

close all;
hold on;
errorbar(players_CI(:,1),sorted_CI(:,2),sorted_CI(:,2)-sorted_CI(:,3),sorted_CI(:,4)-sorted_CI(:,2));
plot([0,47],[0.5,0.5],'r-');
axis([-1 47 0 1]);
labels = num2str(sorted_CI(:,1));
set(gca,'Xtick',0:1:46,'XTickLabel',labels);
xlabel('Player ID');
ylabel('Probability');
set(gca,'FontSize',20);
hold off;
%clearvars -except better_than_scrambled MLESCRAMS MLEFULL* res3 players_CI sorted_CI SCRAM_NUMBER model_MLE;
toc

