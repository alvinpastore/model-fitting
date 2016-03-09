% routine for testing scrambled MLEs against RL model
tic

% TODO might rewrite so that scrams are loaded one at a time to reduce memory consumption

% if the MLESCRAMS have been already imported use 0 as input and use a dummy for MLESCRAMS
% import scrambled MLE matrices, model MLE matrix and resuls matrix
[SCRAM_NUMBER, MLESCRAMS, model_MLE, model] = MLE_SCRAM_importer(1);
MLE_iter = 1:SCRAM_NUMBER;

% remove random models
model = model(model(:,2) ~= 0,:);

% offset = amount of models in gridsearch
% = 5alpha X 4betas X 5gammas
OFFSET = 100;
alpha_confidence = 0.01;    % 99% confidence
iterations = 1000;
COMPARISON_FACTOR = 0;      % tolerance level (-0.05 or 0.05 for conservative or tolerating, 0 for standard comparison)
CHANCE_THRESHOLD = 0.5;     % probability threshold for chance

FONT_SIZE = 20;

% count players
players = unique(model(:,1));
playersAmount = size(players,1);

players_CI = zeros(playersAmount,4);

for playerID = 0:playersAmount-1
    
    disp(['Player ' , num2str(playerID)]);
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
    model_MLE_line = model_MLE(corresponding_MLE_line,5:end-1); % end-1 because of trailing 0
    
    % find corresponding MLE line in scrambled
    scrambled_MLE_line = zeros(1,SCRAM_NUMBER * iterations);
    
    % create scrams MLEs vector (100k = 100 x 1000 (scrams x iterations))
    for i = MLE_iter % iterate over the 100 scrambled bins
        scrambled_MLE = MLESCRAMS(i);
        scrambled_MLE = scrambled_MLE{1};
        % append the 1000 scrambled MLEs 
        current_index = 1 + ((i -1) * iterations);
        scrambled_MLE_line(1, current_index:i*iterations) = scrambled_MLE(corresponding_MLE_line,5:end-1); % end-1 because of trailing 0 
    end
    
    row_idx = 1;
 
    % binary vectors, 1 if phat+-CI > 0.5, 0 otherwise
    MLE_results_player = zeros(1,iterations);
    
    % removed indexing for the loop. test if it works TODO
    % check: do I need mle_comparison to be a matrix (use a vector and
    % re-populate over and over
       
    % logical comparison of each value from model_MLE with all scrambles
    for MLE_instance = model_MLE_line 
        
        MLE_comparison = MLE_instance < scrambled_MLE_line + (scrambled_MLE_line * COMPARISON_FACTOR);
        
        % apply binomial CI test (clopper-pearson) at results of comparison
        [phat, pci] = binofit(sum(MLE_comparison),SCRAM_NUMBER * iterations,alpha_confidence);
        
        % if the Confidence Interval is above 0.5 threshold 
        % the MLE instance is stat. sign. better than scrambled
        if min(phat,min(pci)) > CHANCE_THRESHOLD
            MLE_results_player(row_idx) = 1;
        end
        
        row_idx = row_idx + 1;
    end
    
    % apply binomial CI test (clopper-pearson) at MLE instances outcomes
    [phat, pci] = binofit(sum(MLE_results_player),size(MLE_results_player,2),alpha_confidence);
    
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
set(gca,'FontSize',FONT_SIZE);
hold off;
%clearvars -except better_than_scrambled MLESCRAMS MLEFULL* res3 players_CI sorted_CI SCRAM_NUMBER model_MLE;
toc

