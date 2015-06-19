plot_variance = @(x,lower,upper,color) set(fill([x,x(end:-1:1)],[upper,lower(end:-1:1)],color),'EdgeColor',color);

tic;
close all;
models = [3,4,5,7,10];


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
    %random_model = eval(
    % count players
    players = unique(model(:,1));
    playersAmount = size(players,1);

    % initialise performances
    current_performances = zeros(playersAmount,4);

    % use the actions to calculate random precision
    ACTIONS_AMOUNT = i;

    p_random = 1/ACTIONS_AMOUNT;
    disp(['random precision: ' , num2str(p_random)]);


    % for every player calculate best model and compare with random
    for playerID = 0:playersAmount-1

        % search for player best model precision
        p_model_lines = find(model(:,1) == playerID); 
        p_model_best  = max(model(p_model_lines,6));

        % populate performances matrix
        % [playerID RL_best_precision RM_precision RM_std_dev]
        current_performances(playerID+1,:) = [playerID p_model_best random_model(playerID+1,2) random_model(playerID+1,3)];

    end
    performances{perf_idx} = current_performances;
    perf_idx = perf_idx + 1;
    
    mu = current_performances(:,3)*100;
    sigma = current_performances(:,4);
       
    fig = figure(i);
    
    hold on;
    plot_variance(current_performances(:,1).',(mu-2*sigma).', (mu+2*sigma).',[0.9 0.9 0]);
    xlab = xlabel('Players','FontSize',25);
    ylab = ylabel('Precision (%)','FontSize',25);
    set(gca,'FontSize',20);
    title([num2str(i),' actions RL vs RM'],'FontSize',28);
    axis([-1 46 min((mu-2*sigma)-3) max(((current_performances(:,2)*100)+3 ))]);
    
    plot(current_performances(:,1),mu,'-b');
    scatter(current_performances(:,1),current_performances(:,2)*100,'xr')
    
    
    l{1}=' 95% confidence interval'; l{2}=' Average random model'; l{3}=' Reinforcement Learning'; 
    legend(l,'Location',[0.7 0.8 0 0]);
    %set(hLegend,'FontSize',24);
    alpha(0.5);
    hold off;
    saveas(gcf,['graphs_shaded/g-',num2str(i)]);
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 27 21]); %x_width=10cm y_width=15cm
    saveas(gcf,['graphs_shaded/g-',num2str(i),'.png']);
end

toc
