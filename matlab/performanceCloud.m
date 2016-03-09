%run statistical_test_scrambled_2_stage_binomial first for players_CI 

close all;
THRESHOLDS = [0];% 0.5];  % threshold for considering players whose MLE significative ??
SAVE_FIG = 1;             % 0 does not save figures, 1 saves figures

alpha_confidence = 0.01;  % 99% confidence
COMPARISON_FACTOR = 0.01; % tolerance level
CHANCE_THRESHOLD = 0.5;   % probability threshold for chance 
MLE_THRESHOLD = 5;        % consider only players who are RL (arbitrary)
P_VALUE_THRESHOLD = 0.05; % p-value threshold

% markup for figures
dx = 0.25;                % shift for the player numbers on the datapoints
dy = -0.25;
FONT_SIZE = 30;             
ID_TEXT_SIZE = 20;
PRINT_WIDTH = 80;
PRINT_HEIGHT = 50;
MARKER_SIZE = 100;

% import scrambled MLE matrices, model MLE matrix and resuls matrix
[SCRAM_NUMBER, MLESCRAMS_dummy, model_MLE, res3] = MLE_SCRAM_importer(0);

% load performances 
perfs = sortrows(csvread('results/stats/performances/profit_performances.csv',0,1,[0,1,45,2]),1);
% load model results (merge with the full MLE file (1000 iterations)
model = res3;

% load nogamma results
MLE_NOGAMMA = csvread('results/MLE_model/nogamma/MLE_Portfolio_[0.0]_1000_u.csv');
nogamma = csvread('results/after_money_1k/_nogamma/profit_states/Negative_Portfolio_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.0-0.0_gamma_u.csv');
nogamma = nogamma(nogamma(:,2) ~= 0,:);

% load performances [playerID model_MLE random_MLE nogamma_MLE p_nog_MLE p_rand_MLE chi_value_random chi_value_nogamma]
performance_fit = paper_figures(0,0);

% these files are needed to find performance_fit 
% (now generated in paper_figures.m)
no_gamma_players = performance_fit(find(performance_fit(:,5) < P_VALUE_THRESHOLD));

% get the random lines from the model
randomMLEs = model(model(:,2) == 0,:);
% other lines are non-random models
model = model(model(:,2) ~= 0,:);

model = [model(:,1:5), model_MLE(:,5:end-1)];

for t = THRESHOLDS
    
    % get the performances subset (above threshold)
    % (remove players whose MLE is not significative)
    %it's ok to populate dinamycally as it is at most 46 players
    performances = []; 
    for idx = 1:size(perfs,1)
        if players_CI(idx,3) >= t
            performances = [performances; perfs(idx,:)];
        end
    end
    
    % structure to save the p-hat and p-ci 
    errorbars = [];
    
    % get the number of players
    playerAmount = size(performances,1);

    % instantiate statistics vectors
    % playerID, profit, MLE best, MLE random, alpha, beta, gamma
    stats = [];
    nogamma_stats = [];
    
    for idx = 1:playerAmount
        % get the player ID
        playerID = performances(idx,1);

        % find player MLEs in results file
        pl_lines = find(model(:,1) == playerID);

        % get the columns [alpha, beta, gamma, MLE]
        current_res = model(pl_lines, 1:end);

        % sort current_res so that the best N models 
        % are available as the first N rows
        current_res = sortrows(current_res,5);
       
        % get the N best MLE (new version: top N)
        current_res = current_res(1:5,:);
        
        % store best models alpha beta and gamma and MLE
        abg = current_res(1,2:4);
        
        % store alpha beta gamma for the alternative models
        alternative_abgs = current_res(2:end,2:4);
              
        % store best models MLE (avg)
        minMLE = current_res(1,5);
        
        % get model 1000 MLEs repetitions (exclude the avg MLE col.5)
        best_MLEs = current_res(1,6:end);
        
        MLE_comparison = zeros(size(current_res(2:end,6:end)));
        
        randomMLE = randomMLEs(randomMLEs(:,1) == playerID,5);
        
        for MLE_instance = best_MLEs
            % compare the MLE instance (scalar) 
            % to a matrix of MLES (best N lines)
            % each line summed to itself at each comparison
            % each line is a comparison (sum the line for clopper pearson)
            % comparison__alternative_MLEs is the matrix of MLEs to be compared
            % incremented of 1/100 of each value (COMPARISON_FACTOR)
            comparison__alternative_MLEs = current_res(2:end,6:end) + (current_res(2:end,6:end) * COMPARISON_FACTOR);
            % the comparison sign is > because MLE is better lower 
            % (if the MLE_instance of the best model is higher than 
            % the alternative it means the alternative is actually better)
            MLE_comparison =  MLE_comparison + +(MLE_instance > comparison__alternative_MLEs);
            
        end
        
        % each line is a model
        for jdx = 1:4
            comparison = MLE_comparison(jdx,:);
            [phat,pci] = binofit(sum(comparison),1000*1000,alpha_confidence);
            
            
             if pci(1) > CHANCE_THRESHOLD
                fig = figure();
                hold on;
                temp = current_res(2:end,6:end);
                hist([best_MLEs;temp(jdx,:)].',100);
                tit_temp = {['player: ', num2str(playerID)], [num2str(pci(1)),' ',num2str(phat),' ',num2str(pci(2))],  num2str(abg),  num2str(alternative_abgs(jdx,:))};
                title(tit_temp,'FontSize',20);
                legend({'best','alternative'},'FontSize',20);
                %axis([0 22 0 1000]);
                hold off;
%                 if SAVE_FIG
%                     set(gcf, 'PaperUnits', 'centimeters');
%                     set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
%                     path = 'graphs/model_MLE_comparison/portfolio/';
%                     fileName = [path, 'player: ', num2str(playerID),'p-hat',num2str(phat), '.png'];
%                     print(fig, '-dpng', '-loose', fileName);
%                 end
                if minMLE < MLE_THRESHOLD
                    stats = [stats; playerID, performances(idx,2), minMLE, randomMLE, alternative_abgs(jdx,:)];
                end
                
                % if player is a nogamma player...
                if sum(find(playerID==no_gamma_players)) > 0
                    nogamma_stats = [nogamma_stats; playerID, performances(idx,2), minMLE, randomMLE, alternative_abgs(jdx,:)];
                end
                
            elseif pci(2) < CHANCE_THRESHOLD
                %disp('statistically worse');
            else
                disp('statistically same as best');
             end
            
            errorbars = [errorbars; phat, pci];
        end
        
        
        % get best MLE (OLD version: single MLE)
        %[minMLE, minMLE_idx] = min(current_res(:,4));
        % get alpha, beta and gamma param for best model
        %abg = current_res(minMLE_idx,1:3);
        
        % store stats
        if minMLE < MLE_THRESHOLD
            stats = [stats; playerID, performances(idx,2), minMLE, randomMLE, abg];
        end
        
        % if player is a nogamma player...
        if sum(find(playerID==no_gamma_players)) > 0
            nogamma_stats = [nogamma_stats; playerID, performances(idx,2), minMLE, randomMLE, alternative_abgs(jdx,:)];
        end
    end
    
    %% FIGURE 0 MLE comparison using CP (errorbars)
    % best model (according to avg) vs next 4 models
    fig = figure();
    hold on
    errorbar(1:1:size(errorbars,1),errorbars(:,1),errorbars(:,1)-errorbars(:,2),errorbars(:,3)-errorbars(:,1),'bx');
    plot([-10 size(errorbars,1)+10],[.5 .5],'r-','LineWidth',4)
    axis([-10 200 0 0.75]);%(max(errorbars) + 0.1 * max(errorbars))]);
    hold off
    xlabel('Models');
    ylabel('Probability');
    set(gca,'FontSize',FONT_SIZE);
    
    %% FIGURE 1 profit VS MLE
    
    % sort players according to performances 
    %ranked_performances = sortrows(stats,2);
    ranked_performances = sortrows(nogamma_stats,2);
    
        
    % on the x-axis there is profit
    x = ranked_performances(:,2);
    
    % on the y-axis there is MLE (best and random)
    y_best = ranked_performances(:,3);
    y_random = ranked_performances(:,4);
    
    % players ids
    labels = num2str(ranked_performances(:,1));
    
    % calculate regression coefficient R and p-value
    [R,P]=corrcoef(x,y_best);

    fig = figure();
    hold on;
    
    % plot players MLE vs profit
    scatter(x, y_best,MARKER_SIZE, 'bo');
    labels_text = text(x + dx, y_best+dy ,labels,'FontSize',ID_TEXT_SIZE);
    
    % plot line for random MLE (not much info added as all MLE are better)
    plot(x,y_random,'s-r');
    
    % draw the regression line
    lsline;
    
    % title, labels, font
    title_text = ['Performance VS MLE - ', num2str(t), ' threshold - R = ',num2str(R(1,2))];
    title_text = [title_text, '- R2 = ',num2str(R(1,2)^2)];
    title_text = [title_text,' - p = ',num2str(P(1,2))];
    title(title_text);
    disp(title_text);
    ylabel('Model Fitness (MLE)');
    xlabel('Player Performance (profit)');
    set(gca,'FontSize',FONT_SIZE);
    
    hold off
    
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        path = 'graphs/stats/performance_cloud/portfolio/';
        fileName = [path, 'performance_vs_MLE_t_',num2str(t),'.png'];
        print(fig, '-dpng', '-loose', fileName); 
    end
    
    
    %% FIGURE 2 profit VS alpha
       
    % on the y-axis there is alpha 
    y_alpha = ranked_performances(:,5);
    [R,P]=corrcoef(x,y_alpha);
    
    fig = figure();
    hold on;
    
    % plot alpha vs profit
    scatter(x, y_alpha,MARKER_SIZE, 'bo');
    l = text(x + dx/10, y_alpha + dy/10 ,labels,'FontSize',ID_TEXT_SIZE);
    
    % draw the regression line
    lsline;
    
    % title, labels, font
    title_text = ['Performance VS alpha - ', num2str(t), ' threshold - R = ',num2str(R(1,2))];
    title_text = [title_text, '- R2 = ',num2str(R(1,2)^2)];
    title_text = [title_text,' - p = ',num2str(P(1,2))];
    title(title_text);
    ylabel('Alpha');
    xlabel('Player Performance (profit)');
    set(gca,'FontSize',FONT_SIZE);
    axis([-6e+03 2e+04 0.45 1.05]);
    hold off;
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        path = 'graphs/stats/performance_cloud/portfolio/';
        fileName = [path, 'performance_vs_alpha_t_',num2str(t),'.png'];
        print(fig, '-dpng', '-loose', fileName); 
    end
    
    %% FIGURE 3 profit VS gamma
       
    % on the y-axis there is gamma 
    % called z_gamma because it's used in 3d plot together with y_alpha
    z_gamma = ranked_performances(:,7);
    [R,P]=corrcoef(x,z_gamma);
    
    fig = figure();
    hold on;
    
    % plot alpha vs profit
    scatter(x, z_gamma,MARKER_SIZE, 'bo');
    l = text(x + dx/10, z_gamma + dy/10 ,labels,'FontSize',ID_TEXT_SIZE);
    
    % draw the regression line
    lsline;
    
    % title, labels, font
    title_text = ['Performance VS gamma - ', num2str(t), ' threshold - R = ',num2str(R(1,2))];
    title_text = [title_text, '- R2 = ',num2str(R(1,2)^2)];
    title_text = [title_text,' - p = ',num2str(P(1,2))];
    title(title_text);
    ylabel('Gamma');
    xlabel('Player Performance (profit)');
    set(gca,'FontSize',FONT_SIZE);
    axis([-6.5e+03 2e+04 -0.1 1.1]);
    hold off;
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        path = 'graphs/stats/performance_cloud/portfolio/';
        fileName = [path, 'performance_vs_gamma_t_',num2str(t),'.png'];
        print(fig, '-dpng', '-loose', fileName); 
    end
    
    %% FIGURE 4 profit VS alpha VS gamma
    
    fig = figure();
    hold on;
    
    % plot alpha vs profit
    scatter3(y_alpha, z_gamma, x,MARKER_SIZE,'bo');
    %l = text(y_alpha + dy, z_gamma+dy, x + dx ,labels,'FontSize',ID_TEXT_SIZE);
    
    % draw the regression line
    %lsline;
    
    % title, labels, font
    title_text = ['Performance VS alpha VS gamma - ', num2str(t), ' threshold - R = ',num2str(R(1,2))];
    %title_text = [title_text, '- R2 = ',num2str(R(1,2)^2)];
    %title_text = [title_text,' - p = ',num2str(P(1,2))];
    title(title_text);

    xlabel('Alpha');
    ylabel('Gamma');
    zlabel('Player Performance (profit)');
    set(gca,'FontSize',FONT_SIZE);
    %axis([-6e+03 2e+04 0 1.05]);
    axis([-0.1 1.1 -0.1 1.1 (min(x)-min(x)*0.1) (max(x)+max(x)*0.1)])
    grid
    hold off;
    
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        path = 'graphs/stats/performance_cloud/portfolio/';
        fileName = [path, 'performance_vs_gamma_vs_alpha_t_',num2str(t),'.png'];
        print(fig, '-dpng', '-loose', fileName); 
    end
end