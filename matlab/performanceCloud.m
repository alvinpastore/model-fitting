close all;

THRESHOLDS = [0. 0.5];
SAVE_FIG = 1;
FIG_IDX = 0;
dx = 0.15;
dy = 0.007;
    
% load performances 
perfs = sortrows(csvread('results/stats/performances/profit_performances.csv',0,1,[0,1,45,2]),1);

for t = THRESHOLDS
    
    % get the performances subset (above threshold)
    % (remove players whos MLE is not significative)
    performances = []; %it's ok to populate dinamycally as it is at most 46 players
    for idx = 1:size(perfs,1)
        if players_CI(idx,3) >= t
            performances = [performances; perfs(idx,:)];
        end
    end
    
    % get the number of players
    plAmount = size(performances,1);

    % instantiate statistics vectors
    % pid, profit, MLE best, MLE random, alpha, beta, gamma
    stats = [];

    for idx = 1:plAmount
        % get the player ID
        pid = performances(idx,1);

        % find player MLEs in results file
        pl_lines = find(res3(:,1) == pid);

        % get the columns [alpha, beta, gamma, MLE]
        current_res = res3(pl_lines, 2:5);

        % get best MLE and the RANDOM MLE
        [minMLE, minMLE_idx] = min(current_res(:,4));
        randomMLE = current_res(1,4);

        % get alpha, beta and gamma param for best model
        abg = current_res(minMLE_idx,1:3);

        % store stats
        stats = [stats; pid, performances(idx,2), minMLE, randomMLE, abg];
    end
    
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
    l = text(x + dx, y_best+dy ,labels,'FontSize',15);
    
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
    y_gamma = ranked_performances(:,7);
    [R,P]=corrcoef(x,y_gamma);
    
    FIG_IDX = FIG_IDX + 1;
    fig = figure(FIG_IDX);
    hold on;
    
    % plot alpha vs profit
    scatter(x, y_gamma, 'bo');
    l = text(x + dx, y_gamma+dy ,labels,'FontSize',15);
    
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
end