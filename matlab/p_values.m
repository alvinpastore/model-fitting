plot_variance = @(x,lower,upper,color) set(fill([x,x(end:-1:1)],[upper,lower(end:-1:1)],color),'EdgeColor',color);
variance_yellow = [0.9 0.9 0];
yellow	= [1,1,0];
magenta	= [1,0,1];
cyan	= [0,1,1];
red     = [1,0,0];
green	= [0,1,0];
blue	= [0,0,1];
white	= [1,1,1];
black	= [0,0,0];

%% Calculate p-values for each player best RL model against alternative model
%  Compare using Likelihood ratio Chi-squared test

close all;

models = [3];

%repetitions (both alternative and RL must have the same amount)
n = 1000;

%% 2 For NoGamma
ALTERNATIVE_MODEL_PARAMS = 2; 
ALTERNATIVE_MODEL_NAME = 'resscram';
PLOT = 0;

% degrees of freedom for likelihood ratio 
% # params w1 - # params w2
% alpha, beta, gamma  VS  alpha, beta (nogamma model)
dof = 3 - ALTERNATIVE_MODEL_PARAMS;

% data structure to hold the p_values of all the results available
%pvalues = cell(length(models),1); 
%perf_idx = 1;

for i = models 

    % load model results
    current_results = ['res',num2str(i)];
    current_altern = [ALTERNATIVE_MODEL_NAME,num2str(i)];
    model = eval(current_results);
    altern_model = eval(current_altern);

    % count players
    players = unique(model(:,1));
    playersAmount = size(players,1);
    
    % get all lines except the random models (where beta == 0)
    alt_MLE_lines = find(altern_model(:,3) ~= 0); 
    alt_MLE = altern_model(alt_MLE_lines,5);
    
    % initialise performances structure
    current_pvalues = zeros(playersAmount,10);
    
    % for every player calculate best model and compare with alternative
    for playerID = 0:playersAmount-1

        % find player lines in both models
        player_lines_model = find(model(:,1) == playerID); 
        p_lines_alt   = find(altern_model(:,1) == playerID);
        
        % search for player best model precision
        [p_prec, p_line] = max(model(player_lines_model,6));
        p_prec = p_prec * 100;
        
        % search for player best alternative model precision
        [alt_prec, alt_p_line] = max(altern_model(p_lines_alt,6));
        alt_std   = altern_model(alt_p_line,7); 
        alt_ste   = alt_std / sqrt(n); 
        
        % calculate P-value
        t_v = abs((alt_prec - p_prec) / alt_ste);
        p_v = double(2 * (1-tcdf(abs(t_v),n-2)));
        
        % find best MLE full model
        [p_best_MLE, p_best_MLE_line] = min(model(player_lines_model,5));
        
        % find best MLE alternative model
        [alt_best_MLE, alt_best_MLE_line] = min(altern_model(p_lines_alt,5));
        
        % calculate Likelihood ratio (best precision model)
        chi_value = 2 * (alt_best_MLE - p_best_MLE);
        p_v_MLE = 1-chi2cdf(chi_value,dof);

        current_pvalues(playerID+1,:) = [playerID p_prec alt_prec alt_ste p_v p_v > 0.01 p_best_MLE  alt_best_MLE p_v_MLE p_v_MLE > 0.1];

        %% NOT CORRECT BECAUSE MY p_prec is already an average of 1000 datapoints
        %syms x;
        %gaussian = (1 / (sqrt(2 * pi) * r_std))  *  exp(-(x - r_prec)^2 / (2 * r_std^2));
        %pvalue = p_prec < r_prec * (2 * vpa(double(int(gaussian,-200,p_prec)),5)) + p_prec >= r_prec * (2 * vpa(double(int(gaussian,p_prec,200)),5));
        %disp(pvalue)
        
        
    end
    
    if PLOT
        % FIGURE P-value vs alternative
        fig1 = figure();
        mu = current_pvalues(:,3);
        sigma = current_pvalues(:,4);

        hold on;
        plot_variance(current_pvalues(:,1).',(mu-2*sigma).', (mu+2*sigma).',variance_yellow);

        xlab = xlabel('Players','FontSize',25);
        ylab = ylabel('Precision (%)','FontSize',25);
        set(gca,'FontSize',20);
        axis([-1 46 20 100]);
        title('Statistical Significance Full Model vs NoGamma Model','FontSize',25);

        plot(current_pvalues(:,1),mu,'-b');
        MARKER_AREA = 100;
        scatter(current_pvalues(:,1), current_pvalues(:,2), MARKER_AREA, current_pvalues(:,6) * red ,'x');

        l{1}=' 95% confidence interval'; l{2}=' Average altern model'; l{3}=' Reinforcement Learning'; 
        legend(l,'Location',[0.83 0.87 0 0]);

        alpha(0.5);
        hold off;

        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
        saveas(gcf,['graphs_shaded/g-2states-',num2str(i),'_statistical_significance_',ALTERNATIVE_MODEL_NAME,'.png']);
    end
   
end