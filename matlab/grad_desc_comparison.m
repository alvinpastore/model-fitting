%% script to compare best model (set of param found using stochastic gradient descent) 
% vs random model
% vs noGamma model
function [better_than_random,model] = grad_desc_comparison(RESTRICTED,ALGORITHM,CAP,N_ACTIONS,RISK_MEASURE,COMPARISON_MEASURE,SAVE_FIG)

    % markup for figures
    MARKER_SIZE = 15;
    FONT_SIZE = 20;
    PRINT_WIDTH = 80;
    PRINT_HEIGHT = 50;
    
    % number of params of bigger model - number of params of nested model
    rnd_dof = 3-1;  % alpha, beta, gamma, (k) VS beta
    ngm_dof = 3-2;  % alpha, beta, gamma, VS alpha, beta
    
    % the original amount of transactions
    % depends only on the CAP (not restriction yet)
    transactions_number = csvread(['../results/stats/transactions_number_',num2str(CAP),'CAP.csv']);

    % the random MLE value is calculated based on 
    % the number of actions and the number of transactions
    random_MLEs = - (transactions_number - RESTRICTED) * log(1 / N_ACTIONS);

    % number of observations (for calculating BIC)
    % the original number of transactions minus the restriction (training)
    transactions = transactions_number - RESTRICTED;

    close all;

    % LOAD THE GRAD DESC MODELs TO TEST
    model = MLE_model_importer(RESTRICTED, ALGORITHM, CAP, N_ACTIONS,RISK_MEASURE);
    model = [model random_MLEs transactions_number];
    model_MLEs = model(:,5);
    
    noGamma = MLE_model_importer(RESTRICTED, ALGORITHM, CAP, N_ACTIONS,RISK_MEASURE,'_nogamma');
    noGamma = [noGamma random_MLEs transactions_number];
    noGamma_MLEs = noGamma(:,5);
    
    % count players
    playersAmount = size(model,1);    

    % calculate aic and bic for RL models and for random models
    [aic,bic]   = aicbic(-model_MLEs, ones(playersAmount,1)*3, transactions);   % 3 param
    [naic,nbic] = aicbic(-noGamma_MLEs, ones(playersAmount,1)*2, transactions); % 2 param
    [raic,rbic] = aicbic(-random_MLEs, ones(playersAmount,1), transactions);    % 1 param
    
    %% MODEL V RANDOM
    % likelihood ratio test manual
    chi_value_random = 2 * (-model_MLEs - (-random_MLEs));
    p_rand_MLE = 1-chi2cdf(chi_value_random, rnd_dof);

    % likelihood ratio test matlab
    [lrt_comparison,pValue,stat,cValue] = lratiotest(random_MLEs,model_MLEs, rnd_dof);

    aic_comparison = (raic-aic)>2;
    bic_comparison = (rbic-bic)>2;

    % get only the players and the models better than random
    if strcmp(COMPARISON_MEASURE,'AIC')
        comparison = aic_comparison;
        ic = aic; ric = raic;
    elseif strcmp(COMPARISON_MEASURE,'BIC')
        comparison = bic_comparison;
        ic = bic; ric = rbic;
    elseif strcmp(COMPARISON_MEASURE,'LRT')
        comparison = lrt_comparison;
        ic = aic; ric = raic; % LRT uses aic as a measure for the plot
    end
    
    better_than_random = model.*(repmat(comparison,1,7));
    better_than_random(all(better_than_random==0,2),:) = [];
    
    %% General comparison figure
%     fig0 = figure();
%     scatter(model(:,1), random_MLEs, 70, 'xr');
%     hold on
%     scatter(model(:,1), model_MLEs, 70, 'ob');
%     %axis([-1 46 0 30])
%     grid on
%     grid minor
%     plot(better_than_random(:,1),better_than_random(:,5),'g*');
%     title(['Model: CAP',num2str(CAP),' nActions',num2str(N_ACTIONS),' ',RESTRICTED ,'-restricted'])
%     xlabel('Player ID') 
%     ylabel('MLE') 
%     legend('Random','Model','Significant','Location','SouthEast')
%     set(gca,'FontSize',FONT_SIZE);
    
    %% MLE comparison paper figure v RANDOM
    
    fig_data = [model_MLEs, random_MLEs, comparison > 0, model(:,1)];
    fig_data = sortrows(fig_data,1);
    significant_players = find(fig_data(:,3) > 0);
    
    fig1_1 = figure();
    hold on;
    bar(fig_data(:,1),'FaceColor',[0.7,0.7,0.7]);
    plot(1:1:playersAmount,fig_data(:,2),'dr','LineWidth',MARKER_SIZE);
    plot(significant_players , max(random_MLEs) + max(random_MLEs)/20,'k*','MarkerSize',MARKER_SIZE);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 47 0 max(random_MLEs) + max(random_MLEs)/10])
    set(gca,'FontSize',FONT_SIZE);
    title('Reinforcement Learning vs Random model');
    set(gca,'XTick',1:1:46,'XTickLabel',fig_data(:,4));
    legend('RL Full Model','Random Model','Significant','Location','SouthEast')
    grid
    
%     if SAVE_FIG
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
%         path = '../graphs/paper/';
%         fileName = [path, 'MLE_vs_Random_',num2str(RESTRICTED),'restricted'];
%         fileName = [fileName,'_',ALGORITHM];
%         fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'.png'];
%         print(fig1_1, '-dpng', '-loose', fileName); 
%     end
    
    % bic figure
    
    fig_data = [ic, ric, comparison > 0, model(:,1)];
    fig_data = sortrows(fig_data,1);
    significant_players = find(fig_data(:,3) > 0);
    
    fig1_2 = figure();
    hold on;
    bar(fig_data(:,1),'FaceColor',[0.7,0.7,0.7]);
    %plot(1:1:playersAmount,bic,'dk','LineWidth',MARKER_SIZE);
    plot(1:1:playersAmount,fig_data(:,2),'dr','LineWidth',MARKER_SIZE);
    plot(significant_players , max(ic)+max(ic)/20,'k*','MarkerSize',MARKER_SIZE);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel(COMPARISON_MEASURE,'FontSize',FONT_SIZE);
    axis([0 47 0 max(ic)+max(ic)/10])
    set(gca,'FontSize',FONT_SIZE);
    title('Reinforcement Learning vs Random model');
    set(gca,'XTick',1:1:46,'XTickLabel',fig_data(:,4));
    legend('RL Full Model','Random Model','Significant','Location','SouthEast')
    grid%set(gca,'ygrid','on')
    
%     if SAVE_FIG
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
%         path = '../graphs/paper/';
%         fileName = [path, COMPARISON_MEASURE,'_vs_Random_',num2str(RESTRICTED),'restricted'];
%         fileName = [fileName,'_',ALGORITHM];
%         fileName = [fileName,'_',RISK_MEASURE];
%         fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'.png'];
%         print(fig1_2, '-dpng', '-loose', fileName); 
%     end
    %% MLE comparison paper figure v NOGAMMA
    % likelihood ratio test matlab
    [lrt_comparison,pValue,stat,cValue] = lratiotest(noGamma_MLEs,model_MLEs, ngm_dof);

    aic_comparison = (naic-aic)>2;
    bic_comparison = (nbic-bic)>2;
    
    if strcmp(COMPARISON_MEASURE,'AIC')
        comparison = aic_comparison;
        ic = aic; nic = naic;
    elseif strcmp(COMPARISON_MEASURE,'BIC')
        comparison = bic_comparison;
        ic = bic; nic = nbic;
    elseif strcmp(COMPARISON_MEASURE,'LRT')
        comparison = lrt_comparison;
        ic = aic; nic = naic; % LRT uses aic as a measure for the plot
    end
    
    fig_data = [model_MLEs, noGamma_MLEs, comparison > 0, model(:,1)];
    fig_data = sortrows(fig_data,1);
    significant_players = find(fig_data(:,3) > 0);

    fig2_1 = figure();
    hold on;
    bar(fig_data(:,1),'FaceColor',[0.7,0.7,0.7]);
    plot(1:1:playersAmount,fig_data(:,2),'dg','LineWidth',MARKER_SIZE);
    plot(significant_players , max(noGamma_MLEs)+max(noGamma_MLEs)/20,'k*','MarkerSize',MARKER_SIZE);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 47 0 max(noGamma_MLEs)+max(noGamma_MLEs)/10])
    set(gca,'FontSize',FONT_SIZE);
    title('Full RL vs NoGamma RL model');
    set(gca,'XTick',1:1:46,'XTickLabel',fig_data(:,4));
    legend('RL Full Model','NoGamma Model','Significant','Location','SouthEast')
    grid
    
%     if SAVE_FIG
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
%         path = '../graphs/paper/';
%         fileName = [path, 'MLE_vs_noGamma_',num2str(RESTRICTED),'restricted'];
%         fileName = [fileName,'_',ALGORITHM];
%         fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'.png'];
%         print(fig2_1, '-dpng', '-loose', fileName); 
%     end

    % bic figure
    
    fig_data = [ic, nic, comparison > 0, model(:,1)];
    fig_data = sortrows(fig_data,1);
    significant_players = find(fig_data(:,3) > 0);
    
    
    fig2_2 = figure();
    hold on;
    bar(fig_data(:,1),'FaceColor',[0.7,0.7,0.7]);
    %plot(1:1:playersAmount,bic,'dk','LineWidth',MARKER_SIZE);
    plot(1:1:playersAmount,fig_data(:,2),'dg','LineWidth',MARKER_SIZE);
    plot(significant_players , max(ic)+max(ic)/20,'k*','MarkerSize',MARKER_SIZE);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel(COMPARISON_MEASURE,'FontSize',FONT_SIZE);
    axis([0 47 0 max(ic)+max(ic)/10])
    set(gca,'FontSize',FONT_SIZE);
    title('Full RL vs NoGamma RL model');
    set(gca,'XTick',1:1:46,'XTickLabel',fig_data(:,4));
    legend('RL Full Model','Random Model','Significant','Location','SouthEast')
    grid%set(gca,'ygrid','on')
    
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        path = '../graphs/paper/';
        fileName = [path, COMPARISON_MEASURE,'_vs_noGamma_',num2str(RESTRICTED),'restricted'];
        fileName = [fileName,'_',ALGORITHM];
        fileName = [fileName,'_',RISK_MEASURE];
        fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'.png'];
        print(fig2_2, '-dpng', '-loose', fileName); 
    end
