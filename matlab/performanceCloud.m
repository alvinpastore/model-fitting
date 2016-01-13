close all;

%run statistical_test_scrambled_2_stage_binomial first ?

THRESHOLDS = [0 0.5];
SAVE_FIG = 0;   % 0 does not save figures, 1 saves figures
FIG_IDX = 0;    % starting point for the figure index
dx = 0.15;      % shift for the player numbers on the datapoints
dy = 0.007;
alpha_confidence = 0.01;   % 99% confidence
CHANCE_THRESHOLD = 0.5;
COMPARISON_FACTOR = 0.01; % tolerance level 

% import scrambled MLE matrices, model MLE matrix and resuls matrix
[SCRAM_NUMBER, MLESCRAMS_dummy, model_MLE, res3] = MLE_SCRAM_importer(0);

% load performances 
perfs = sortrows(csvread('results/stats/performances/profit_performances.csv',0,1,[0,1,45,2]),1);
% load model results (merge with the full MLE file (1000 iterations)
model = res3;

% get the random lines from the model
randomMLEs = model(find(model(:,2) == 0),:);

model = model(find(model(:,2) ~= 0),:);
model = [model(:,1:5), model_MLE(:,5:end-1)];

for t = THRESHOLDS
    
    % get the performances subset (above threshold)
    % (remove players whos MLE is not significative)
    performances = []; %it's ok to populate dinamycally as it is at most 46 players
    for idx = 1:size(perfs,1)
        if players_CI(idx,3) >= t
            performances = [performances; perfs(idx,:)];
        end
    end
    errorbars = [];
    % get the number of players
    plAmount = size(performances,1);

    % instantiate statistics vectors
    % pid, profit, MLE best, MLE random, alpha, beta, gamma
    stats = [];

    for idx = 1:plAmount
        % get the player ID
        pid = performances(idx,1);

        % find player MLEs in results file
        pl_lines = find(model(:,1) == pid);

        % get the columns [alpha, beta, gamma, MLE]
        current_res = model(pl_lines, 1:end);

        % sort current_res so that the best N models 
        % are available as the first N rows
        current_res = sortrows(current_res,5);
       
        % get the N best MLE (new version: top N)
        current_res = current_res(1:5,:);
        
        % store best models alpha beta and gamma
        abg = current_res(1,2:5);
        
        % store alpha beta gamma for the alternative models
        alternative_abgs = current_res(2:end,2:5);
              
        % store best models MLE (avg)
        minMLE = current_res(1,5);
        
        % get only the 1000 repetitions (exclude the avg MLE col.5)
        best_MLEs = current_res(1,6:end);
        
        MLE_comparison = zeros(size(current_res(2:end,6:end)));
        
        for MLE_instance = best_MLEs
            % compare the MLE instance (scalar) 
            % to a matrix of MLES (best N lines)
            % each line summed to itself at each comparison
            % each line is a comparison (sum the line for clopper pearson)
            % comparison_MLEs is the matrix of MLEs to be compared
            % incremented of 1/100 of each value
            comparison__alternative_MLEs = current_res(2:end,6:end) + (current_res(2:end,6:end) * COMPARISON_FACTOR);
            MLE_comparison =  MLE_comparison + +(MLE_instance > comparison__alternative_MLEs);
            
        end
        
        % each line is a model
        for jdx = 1:4
            comparison = MLE_comparison(jdx,:);
            [phat,pci] = binofit(sum(comparison),1000*1000,alpha_confidence);
            if pci(1) > CHANCE_THRESHOLD
                
                
                
                FIG_IDX = FIG_IDX + 1;
                fig = figure(FIG_IDX);
                hold on;
                temp = current_res(2:end,6:end);
                hist([best_MLEs;temp(jdx,:)].',100);
                tit_temp = {['player: ', num2str(pid)], [num2str(pci(1)),' ',num2str(phat),' ',num2str(pci(2))],  num2str(abg),  num2str(alternative_abgs(jdx,:))};
                title(tit_temp,'FontSize',20);
                legend({'best','alternative'},'FontSize',20);
                %axis([0 22 0 1000]);
                hold off;
                set(gcf, 'PaperUnits', 'centimeters');
                set(gcf, 'PaperPosition', [0 0 40 40]);
                path = 'graphs/model_MLE_comparison/';
                fileName = [path, 'player: ', num2str(pid),'p-hat',num2str(phat), '.png'];
                print(fig, '-dpng', '-loose', fileName);
                
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
        
        
        randomMLE = randomMLEs(find(randomMLEs(:,1) == pid),5);
        % store stats
        stats = [stats; pid, performances(idx,2), minMLE, randomMLE, abg(1:3)];
        
    end
    
    %% FIGURE 0 MLE comparison using CP (errorbars)
    % best model (according to avg) vs next 4 models
    FIG_IDX = FIG_IDX + 1;
    fig = figure(FIG_IDX);
    hold on
    errorbar(1:1:size(errorbars,1),errorbars(:,1),errorbars(:,1)-errorbars(:,2),errorbars(:,3)-errorbars(:,1),'bx');
    plot([0 size(errorbars,1)],[.5 .5],'r-')
    hold off
    
    % sort players according to performances 
    ranked_performances = sortrows(stats,2);
    
    %% FIGURE 1 profit VS MLE
    
    % on the x-axis there is profit
    x = ranked_performances(:,2);
    
    % on the y-axis there is MLE (best and random)
    y_best = ranked_performances(:,3);
    y_random = ranked_performances(:,4);
    
    % players ids
    labels = num2str(ranked_performances(:,1));
    
    % calculate regression coefficient R and p-value
    [R,P]=corrcoef(x,y_best);
    
    FIG_IDX = FIG_IDX + 1;
    fig = figure(FIG_IDX);
    hold on;
    
    % plot players MLE vs profit
    scatter(x, y_best, 'bo');
    labels_text = text(x + dx, y_best+dy ,labels,'FontSize',15);
    
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
    set(gca,'FontSize',20);
    
    hold off
    
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 40 40]);
        path = 'graphs/stats/performance_cloud/';
        fileName = [path, 'performance_vs_MLE_t_',num2str(t),'.png'];
        print(fig, '-dpng', '-loose', fileName); 
    end
    
    
    %% FIGURE 2 profit VS alpha
       
    % on the y-axis there is alpha 
    y_alpha = ranked_performances(:,5);
    [R,P]=corrcoef(x,y_alpha);
    
    FIG_IDX = FIG_IDX + 1;
    fig = figure(FIG_IDX);
    hold on;
    
    % plot alpha vs profit
    scatter(x, y_alpha, 'bo');
    l = text(x + dx, y_alpha+dy ,labels,'FontSize',15);
    
    % draw the regression line
    lsline;
    
    % title, labels, font
    title_text = ['Performance VS alpha - ', num2str(t), ' threshold - R = ',num2str(R(1,2))];
    title_text = [title_text, '- R2 = ',num2str(R(1,2)^2)];
    title_text = [title_text,' - p = ',num2str(P(1,2))];
    title(title_text);
    ylabel('Alpha');
    xlabel('Player Performance (profit)');
    set(gca,'FontSize',20);
    axis([-6e+03 2e+04 0.45 1.05]);
    hold off;
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 40 40]);
        path = 'graphs/stats/performance_cloud/';
        fileName = [path, 'performance_vs_alpha_t_',num2str(t),'.png'];
        print(fig, '-dpng', '-loose', fileName); 
    end
    
    %% FIGURE 3 profit VS gamma
       
    % on the y-axis there is gamma 
    z_gamma = ranked_performances(:,7);
    [R,P]=corrcoef(x,z_gamma);
    
    FIG_IDX = FIG_IDX + 1;
    fig = figure(FIG_IDX);
    hold on;
    
    % plot alpha vs profit
    scatter(x, z_gamma, 'bo');
    l = text(x + dx, z_gamma+dy ,labels,'FontSize',15);
    
    % draw the regression line
    lsline;
    
    % title, labels, font
    title_text = ['Performance VS gamma - ', num2str(t), ' threshold - R = ',num2str(R(1,2))];
    title_text = [title_text, '- R2 = ',num2str(R(1,2)^2)];
    title_text = [title_text,' - p = ',num2str(P(1,2))];
    title(title_text);
    ylabel('Gamma');
    xlabel('Player Performance (profit)');
    set(gca,'FontSize',20);
    axis([-6e+03 2e+04 0 1.05]);
    hold off;
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 40 40]);
        path = 'graphs/stats/performance_cloud/';
        fileName = [path, 'performance_vs_gamma_t_',num2str(t),'.png'];
        print(fig, '-dpng', '-loose', fileName); 
    end
    
    %% FIGURE 4 profit VS alpha VS gamma
    
    FIG_IDX = FIG_IDX + 1;
    fig = figure(FIG_IDX);
    hold on;
    
    % plot alpha vs profit
    scatter3(y_alpha, z_gamma, x,'bo');
    %l = text(y_alpha + dy, z_gamma+dy, x + dx ,labels,'FontSize',15);
    
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
    set(gca,'FontSize',20);
    %axis([-6e+03 2e+04 0 1.05]);
    hold off;
    
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 40 40]);
        path = 'graphs/stats/performance_cloud/';
        fileName = [path, 'performance_vs_gamma_t_',num2str(t),'.png'];
        print(fig, '-dpng', '-loose', fileName); 
    end
end