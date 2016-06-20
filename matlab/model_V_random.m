%script to compare best model (set of param) vs random MLE
% this script might be deprecated since introducing 

% number of params of bigger model - number of params of nested model
rnd_dof = 3-1;  % alpha, beta, gamma, (k) VS beta

close all;
[MLEs, model] = MLE_model_importer('model_free',25,3,'2016-06-13');

random = model(model(:,2) == 0,:);
model = model(model(:,2) ~= 0,:);

% count players
players = unique(model(:,1));
playersAmount = size(players,1);

plot_values = zeros(playersAmount,7);


for playerID = 0:playersAmount-1

    disp(['Player ' , num2str(playerID)]);
    % find player lines in model and MLE results 
    player_lines_model = find(model(:,1) == playerID); 
    
    % create a subset of the results for the player
    player_subresults = model(player_lines_model,:);
    
    % find best MLE full model 
    [p_best_MLE, p_best_MLE_line] = min(player_subresults(:,5));
    
    % save playerID, alpha, beta, gamma and MLE of best model, randomMLE, transactions number
    plot_values(playerID+1,:) = [player_subresults(p_best_MLE_line,1:5) random(playerID+1,5) player_subresults(p_best_MLE_line,9)];

end

random_MLEs = plot_values(:,6);
model_MLEs = plot_values(:,5);

% number of observations (for calculating BIC)
transactions = plot_values(:,7);

scatter(plot_values(:,1), random_MLEs, 70, 'xr');
hold on
scatter(plot_values(:,1), model_MLEs, 70, 'ob');
%axis([-1 46 0 30])
grid on
grid minor

% calculate aic for RL models
[aic,bic] = aicbic(-model_MLEs, ones(playersAmount,1)*3, transactions);
[raic,rbic] = aicbic(-random_MLEs, ones(playersAmount,1), transactions);

% likelihood ratio test manual
chi_value_random = 2 * (-model_MLEs - (-random_MLEs));
p_rand_MLE = 1-chi2cdf(chi_value_random, rnd_dof);

% likelihood ratio test matlab
[h,pValue,stat,cValue] = lratiotest(random_MLEs,model_MLEs, rnd_dof);

aic_comparison = aic<raic;
bic_comparison = bic<rbic;

