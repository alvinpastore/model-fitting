plot_variance = @(x,lower,upper,color) set(fill([x,x(end:-1:1)],[upper,lower(end:-1:1)],color),'EdgeColor',color);

tic;
close all;
models = [3];


% data structure to hold the performances of all the results available
performances = cell(length(models),1);
perf_idx = 1;

for i = models 
    
    current_results = ['res',num2str(i)];
    current_random = ['random',num2str(i)];
    disp(['Processing ', current_results]);
    disp(['Processing ', current_random]);

    % load model results
    model = eval(current_results);
    random_model = eval(current_random);

    % count players
    players = unique(model(:,1));
    playersAmount = size(players,1);

    % initialise performances
    current_performances = zeros(playersAmount,5);

    % use the actions to calculate random precision
    ACTIONS_AMOUNT = i;

    p_random = 1/ACTIONS_AMOUNT;
    disp(['analytical random precision: ' , num2str(p_random)]);


    % for every player calculate best model and compare with random
    for playerID = 0:playersAmount-1

        % search for player best model precision
        p_lines = find(model(:,1) == playerID); 
        p_best  = max(model(p_lines,6))*100;

        r_prec = random_model(playerID+1,2)*100;
        r_std  = random_model(playerID+1,3); % random std devs generated already in %
        r_ste  = r_std / sqrt(1000);
        
        % populate performances matrix
        % [1 playerID
        %  2 precision best RL model
        %  3 precision random model
        %  4 std dev random model
        %  5 std err random model]
        current_performances(playerID+1,:) = [playerID p_best r_prec r_std r_ste];

    end
    performances{perf_idx} = current_performances;
    perf_idx = perf_idx + 1;
   
    fig = figure(i);
    
    %% FIGURE 1 SUBPLOT 1 (using standard deviation)
    subplot(1,2,1);
    
    mu = current_performances(:,3);
    sigma = current_performances(:,4);  
       
    hold on;
    plot_variance(current_performances(:,1).',(mu-2*sigma).', (mu+2*sigma).',[0.9 0.9 0]);
    xlab = xlabel('Players','FontSize',25);
    ylab = ylabel('Precision (%)','FontSize',25);
    set(gca,'FontSize',20);
    axis([-1 46 0 100]);%min((mu-2*sigma)-3) max(((current_performances(:,2))+3 ))]);
    title('Std Dev (2 * sigma)','FontSize',20);
    
    plot(current_performances(:,1),mu,'-b');
    scatter(current_performances(:,1),current_performances(:,2),'xr')
    
    alpha(0.5);
    hold off;
    
    %% FIGURE 1 SUBPLOT 1 (using standard error)
    subplot(1,2,2);
    
    mu = current_performances(:,3);
    sigma = current_performances(:,5);   
           
    hold on;
    plot_variance(current_performances(:,1).',(mu-2*sigma).', (mu+2*sigma).',[0.9 0.9 0]);
    xlab = xlabel('Players','FontSize',25);
    ylab = ylabel('Precision (%)','FontSize',25);
    set(gca,'FontSize',20);
    axis([-1 46 0 100]);%min((mu-2*sigma)-3) max(((current_performances(:,2))+3 ))]);
    title('Std Error (2 * ste)','FontSize',20);

    plot(current_performances(:,1),mu,'-b');
    scatter(current_performances(:,1),current_performances(:,2),'xr')
    
    alpha(0.5);
    hold off;
    
    %% SUBPLOTS COMMON SETTINGS
    annotation_handle = annotation('textbox', [0 0.9 1 0.1], ...
    'String', [num2str(i),' actions RL vs RM'], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
    s = annotation_handle.FontSize;
    annotation_handle.FontSize = 28;
    
    l{1}=' 95% confidence interval'; l{2}=' Average random model'; l{3}=' Reinforcement Learning'; 
    legend(l,'Location',[0.83 0.87 0 0]);
    %set(hLegend,'FontSize',24);

    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
    saveas(gcf,['graphs_shaded/g-2states-',num2str(i),'.png']);
end

toc