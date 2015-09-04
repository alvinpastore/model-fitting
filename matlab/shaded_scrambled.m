plot_variance = @(x,lower,upper,color) set(fill([x,x(end:-1:1)],[upper,lower(end:-1:1)],color),'EdgeColor',color);

tic;
close all;
models = [3];


% data structure to hold the performances of all the results available
performances = cell(length(models),1);
perf_idx = 1;

for i = models 
    
    current_results = ['res',num2str(i)];
    current_scrambled = ['scrambled',num2str(i)];
    disp(['Processing ', current_results]);
    disp(['Processing ', current_scrambled]);

    % load model results
    model = eval(current_results);
    scrambled_model = eval(current_scrambled);

    % count players
    players = unique(model(:,1));
    playersAmount = size(players,1);

    % initialise performances
    current_performances = zeros(playersAmount,8);

    % use the actions to calculate random precision
    ACTIONS_AMOUNT = i;

    % for every player calculate best model and compare with random
    for playerID = 0:playersAmount-1

        % search for player best model precision
        p_lines = find(model(:,1) == playerID); 
        [p_best, p_best_line]  = max(model(p_lines,6));
        
        % FIRST COMPARISON
        % compare to scrambled model with same parameters
        % it can be found at the same line as the RL best model
        s_prec = scrambled_model(p_best_line,8)*100; 
        s_std  = scrambled_model(p_best_line,9)*100;
        s_ste  = scrambled_model(p_best_line,10)*100;
        if s_std == 0 
            s_std = random3(playerID+1,3);
            s_ste = s_std / sqrt(100);
        end
        
        % SECOND COMPARISON
        % compare to best scrambled model (highest precision)
        s_lines = find(scrambled_model(:,1) == playerID); 
        [s_best_prec, s_best_line]  = max(scrambled_model(s_lines,6));
        
        s_best_prec = s_best_prec * 100;
        s_best_std = scrambled_model(s_best_line,9)*100;
        s_best_ste = scrambled_model(s_best_line,10)*100;
           
        if s_best_std == 0 
            s_best_std = random3(playerID+1,3);
            s_best_ste = s_best_std / sqrt(100);
        end
        
        % populate performances matrix
        % [1 playerID 
        %  2 RL_best_precision 
        %  3 SCRAMBLED_precision / compared to RL best
        %  4 SCRAMBLED_std_dev   / compared to RL best
        %  5 SCRAMBLED_std_err   / compared to RL best
        %  6 SCRAMBLED_best_precision 
        %  7 SCRAMBLED_best_std_dev
        %  8 SCRAMBLED_best_std_err]
        current_performances(playerID+1,:) = [playerID p_best s_prec s_std  s_ste s_best_prec s_best_std s_best_ste];

    end
    performances{perf_idx} = current_performances;
    perf_idx = perf_idx + 1;
    
    %% PLOT ROUTINE 1 (using STD DEV)
    fig1 = figure(i);
    
    % FIRST FIGURE FIRST SUBPLOT - COMPARISON WITH SAME PARAMS
    subplot(1,2,1);
    
    mu = current_performances(:,3);
    sigma = current_performances(:,4);
           
    hold on;
    plot_variance(current_performances(:,1).',(mu-2*sigma).', (mu+2*sigma).',[0.9 0.9 0]);
    xlab = xlabel('Players','FontSize',25);
    ylab = ylabel('Precision (%)','FontSize',25);
    set(gca,'FontSize',20);
    title('vs Scrambled (same Params)','FontSize',20);
    axis([-1 46 min((mu-2*sigma)-3) max(((current_performances(:,2)*100)+3 ))]);
    
    plot(current_performances(:,1),mu,'-b');
    scatter(current_performances(:,1),current_performances(:,2)*100,'xr')
    alpha(0.5);
    
    % FIRST FIGURE SECOND SUBPLOT - COMPARISON WITH BEST SCRAMBLED PRECISION
    subplot(1,2,2);
    
    mu = current_performances(:,6);
    sigma = current_performances(:,7);
    
    hold on;
    plot_variance(current_performances(:,1).',(mu-2*sigma).', (mu+2*sigma).',[0.9 0.9 0]);
    xlab = xlabel('Players','FontSize',25);
    ylab = ylabel('Precision (%)','FontSize',25);
    set(gca,'FontSize',20);
    title('vs Best Scrambled','FontSize',20);
    axis([-1 46 min((mu-2*sigma)-3) max(((current_performances(:,2)*100)+3 ))]);
    
    plot(current_performances(:,1),mu,'-b');
    scatter(current_performances(:,1),current_performances(:,2)*100,'xr')
    
    
    % SUBPLOTS COMMON SETTINGS
    annotation_handle = annotation('textbox', [0 0.9 1 0.1], ...
    'String', [num2str(i),' actions RL vs Scrambled Models (std dev 2*sigma)'], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
    s = annotation_handle.FontSize;
    annotation_handle.FontSize = 28;
    
    l{1}=' 95% confidence interval'; l{2}=' Average Scrambled model'; l{3}=' Reinforcement Learning'; 
    legend(l,'Location',[0.83 0.87 0 0]);
    
    alpha(0.5);
    hold off;
    %saveas(gcf,['graphs_shaded/g-',num2str(i)]);
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 35 25]);
    saveas(gcf,['graphs_shaded/g-2states-',num2str(i),'-vs-scrambled_stdev.png']);
    
    
    %% PLOT ROUTINE 2
    fig2 = figure(i*10); % i*10 so it does not clash with other models (3,4,5,7,10 actions)
    % SECOND FIGURE  FIRST SUBPLOT - (using STD ERROR)
    
    subplot(1,2,1);
    
    mu = current_performances(:,3);
    sigma = current_performances(:,5);
           
    hold on;
    plot_variance(current_performances(:,1).',(mu-2*sigma).', (mu+2*sigma).',[0.9 0.9 0]);
    xlab = xlabel('Players','FontSize',25);
    ylab = ylabel('Precision (%)','FontSize',25);
    set(gca,'FontSize',20);
    title('vs Scrambled (same Params)','FontSize',20);
    axis([-1 46 min((mu-2*sigma)-3) max(((current_performances(:,2)*100)+3 ))]);
    
    plot(current_performances(:,1),mu,'-b');
    scatter(current_performances(:,1),current_performances(:,2)*100,'xr')
    alpha(0.5);
    % FIRST FIGURE SECOND SUBPLOT - COMPARISON WITH BEST SCRAMBLED PRECISION
    subplot(1,2,2);
    
    mu = current_performances(:,6);
    sigma = current_performances(:,8);
    
    hold on;
    plot_variance(current_performances(:,1).',(mu-2*sigma).', (mu+2*sigma).',[0.9 0.9 0]);
    xlab = xlabel('Players','FontSize',25);
    ylab = ylabel('Precision (%)','FontSize',25);
    set(gca,'FontSize',20);
    title('vs Best Scrambled','FontSize',20);
    axis([-1 46 min((mu-2*sigma)-3) max(((current_performances(:,2)*100)+3 ))]);
    
    plot(current_performances(:,1),mu,'-b');
    scatter(current_performances(:,1),current_performances(:,2)*100,'xr')
    
    % SUBPLOTS COMMON SETTINGS
    annotation_handle = annotation('textbox', [0 0.9 1 0.1], ...
    'String', [num2str(i),' actions RL vs Scrambled Models (std error 2*sigma)'], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
    s = annotation_handle.FontSize;
    annotation_handle.FontSize = 28;
    
    l{1}=' 95% confidence interval'; l{2}=' Average Scrambled model'; l{3}=' Reinforcement Learning'; 
    legend(l,'Location',[0.83 0.87 0 0]);
    
    alpha(0.5);
    hold off;
    %saveas(gcf,['graphs_shaded/g-',num2str(i)]);
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 35 25]); 
    
    saveas(gcf,['graphs_shaded/g-2states-',num2str(i),'-vs-scrambled_sterr.png']);
end

toc