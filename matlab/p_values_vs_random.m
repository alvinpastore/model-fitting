plot_variance = @(x,lower,upper,color) set(fill([x,x(end:-1:1)],[upper,lower(end:-1:1)],color),'EdgeColor',color);

% calculates p-values for each player best RL model against random model

close all;

yellow	= [1,1,0];
magenta	= [1,0,1];
cyan	= [0,1,1];
red     = [1,0,0];
green	= [0,1,0];
blue	= [0,0,1];
white	= [1,1,1];
black	= [0,0,0];

syms x;

PLOT = 0;
models = [3];

%repetitions (both random and RL)
n = 1000;

% degrees of freedom for likelihood ratio 
% # params w1 - # params w2
% random (0 params)
MODEL_PARAM_AMOUNT = 2; %nogamma 2
dof = MODEL_PARAM_AMOUNT - 0;

MODEL_NAME = 'resnog';

% data structure to hold the p_values of all the results available
pvalues = cell(length(models),1);
perf_idx = 1;

for i = models 

    % load model results
    current_results = [MODEL_NAME,num2str(i)];
    current_random = ['random',num2str(i)];
    model = eval(current_results);
    random_model = eval(current_random);
    
    % count players
    players = unique(model(:,1));
    playersAmount = size(players,1);
    
    % initialise performances
    current_pvalues = zeros(playersAmount,6);
    
    
    
    % random model lines have alpha = 0 (TODO add AND beta == 0)
    r_MLE_lines = find(model(:,2) == 0); 
    r_MLE = model(r_MLE_lines,5);
    
    % for every player calculate best model and compare with random
    for playerID = 0:playersAmount-1

        % search for player best model precision
        p_lines = find(model(:,1) == playerID); 
        [p_prec, p_line] = max(model(p_lines,6));
        p_prec = p_prec * 100;
        
        r_prec  = random_model(playerID+1,2)*100;
        r_std   = random_model(playerID+1,3); % random std devs generated already in %
        r_ste   = r_std / sqrt(1000);
        
        % calculate P-value
        t_v = abs((r_prec - p_prec) / r_ste);
        p_v = double(2 * (1-tcdf(abs(t_v),n-2)));
        
        % find best MLE 
        [p_best_MLE, p_best_MLE_line] = min(model(p_lines,5));
        
        % calculate Likelihood ratio (best precision model)
        chi_value = 2 * (r_MLE(playerID+1) - p_best_MLE);
        p_v_MLE = 1-chi2cdf(chi_value,dof);

        current_pvalues(playerID+1,:) = [playerID p_prec p_v p_v > 0.01 p_v_MLE p_v_MLE > 0.1];

        %% NOT CORRECT BECAUSE MY p_prec is already an average of 1000 datapoints
        %gaussian = (1 / (sqrt(2 * pi) * r_std))  *  exp(-(x - r_prec)^2 / (2 * r_std^2));
        %pvalue = p_prec < r_prec * (2 * vpa(double(int(gaussian,-200,p_prec)),5)) + p_prec >= r_prec * (2 * vpa(double(int(gaussian,p_prec,200)),5));
        %disp(pvalue)
        
        
    end
    
    if PLOT
        %% FIGURE P-value vs random
        fig1 = figure();
        mu = random_model(:,2)*100;
        sigma = random_model(:,3)./sqrt(1000);

        hold on;
        plot_variance(current_pvalues(:,1).',(mu-2*sigma).', (mu+2*sigma).',[0.9 0.9 0]);

        xlab = xlabel('Players','FontSize',25);
        ylab = ylabel('Precision (%)','FontSize',25);
        set(gca,'FontSize',20);
        axis([-1 46 20 100]);
        title('Statistical Significance','FontSize',20);

        plot(current_pvalues(:,1),mu,'-b');
        scatter(current_pvalues(:,1), current_pvalues(:,2), 100, current_pvalues(:,4) * red ,'x');

        l{1}=' 95% confidence interval'; l{2}=' Average random model'; l{3}=' Reinforcement Learning'; 
        legend(l,'Location',[0.83 0.87 0 0]);

        alpha(0.5);
        hold off;

        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
        %saveas(gcf,['graphs_shaded/g-2states-',num2str(i),'_statistical_significance.png']);
    end
   
end