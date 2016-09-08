%% script to compare best model (set of param found using stochastic gradient descent) 
% NoGamma vs Random model
% RL model vs NoGamma model
% RL model vs Random model
function [better_than_random,model,ng_better_than_random,noGamma] = grad_desc_comparison(RESTRICTED,ALGORITHM,CAP,N_ACTIONS,RISK_MEASURE,SAVE_FIG)
    close all;
    
    % markup for figures
    MARKER_SIZE = 7;
    THRESHOLD_SIZE = 5;
    FONT_SIZE = 20;
    PRINT_WIDTH = 20;
    PRINT_HEIGHT = 15;
    SAVE_FOLDER = '../graphs/paper_correction/';
    ALPHA_CONFIDENCE = 0.01; % 99% confidence
    % number of params of bigger model - number of params of nested model
    % nogamma vs random
    ngm_rnd_dof = 2-0;  % alpha, beta VS random(no param)
    threshold_2dof = 5.991;
    % rl model vs nogamma
    rlm_ngm_dof = 3-2;  % alpha, beta, gamma VS alpha, beta
    threshold_1dof = 3.841;
    % rl model vs random
    rlm_rnd_dof = 3-0;  % alpha, beta, gamma VS random(no param)
    threshold_3dof = 7.815;
    % the original amount of transactions
    % depends only on the CAP (not restriction yet)
    transactions_number = csvread(['../results/stats/transactions_number_',num2str(CAP),'CAP.csv']);
    
    % number of observations (for calculating BIC)
    % the original number of transactions minus the restriction (training)
    transactions = transactions_number - RESTRICTED;
    
    % CALCULATE THE RANDOM MODEL
    % the random MLE value is calculated based on 
    % the number of actions and the number of transactions
    random_MLEs = - transactions * log(1 / N_ACTIONS);

    % LOAD THE GRAD DESC MODELs TO TEST
    % RL MODEL
    model = MLE_model_importer(RESTRICTED, ALGORITHM, CAP, N_ACTIONS,RISK_MEASURE);
    model = [model random_MLEs transactions_number];
    model_MLEs = model(:,5);
    % NoGamma MODEL
    noGamma = MLE_model_importer(RESTRICTED, ALGORITHM, CAP, N_ACTIONS,RISK_MEASURE,'_nogamma');
    noGamma = [noGamma random_MLEs transactions_number];
    noGamma_MLEs = noGamma(:,5);
    
    % count players
    playersAmount = size(model,1);    

    %% NOGAMMA V RANDOM
    % test the simpler model (nogamma) against the random model
    
    % likelihood ratio test manual
    % chi_value_random = 2 * (-noGamma_MLEs - (-random_MLEs));
    % p_rand_MLE = 1-chi2cdf(chi_value_random, ngm_rnd_dof);

    % likelihood ratio test matlab
    [comparison,pValue,stat,cValue] = lratiotest(-noGamma_MLEs,-random_MLEs, ngm_rnd_dof);
    
    ng_better_than_random = noGamma.*(repmat(comparison,1,7));
    ng_better_than_random(all(ng_better_than_random==0,2),:) = [];

    
    % MLE comparison paper figure v RANDOM
    % fig 1_1 shows the MLE values (same as original paper)
    fig_data = [noGamma_MLEs, random_MLEs, comparison > 0, model(:,1)];
    %fig_data = sortrows(fig_data,-2);
    significant_players = find(fig_data(:,3) > 0);
    
    fig1_1 = figure();
    hold on;
    bar(fig_data(:,1),'FaceColor',[0.7,0.7,0.7]);                       % NoGamma as grey bars
    %plot(1:1:playersAmount,fig_data(:,2),'--k','LineWidth',2);          % Random as black dashed line
    plot(1:1:playersAmount,fig_data(:,2),'dk','MarkerSize',MARKER_SIZE,'LineWidth',2);         % Random as hollow diamonds
    plot(significant_players , max(random_MLEs) + max(random_MLEs)/20,'k*','MarkerSize',MARKER_SIZE);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 47 0 max(random_MLEs) + max(random_MLEs)/10])
    set(gca,'FontSize',FONT_SIZE);
%     title('NoGamma model vs Random model');
%     set(gca,'XTick',1:1:46,'XTickLabel',fig_data(:,4));
%     h_legend = legend('NoGamma Model','Random Model','Significant','Location','SouthEast');
%     set(h_legend,'FontSize',FONT_SIZE);
%     grid
    
    if SAVE_FIG 
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        
        fileName = [SAVE_FOLDER, 'NoGamma_vs_Random_',num2str(RESTRICTED),'restricted'];
        fileName = [fileName,'_',ALGORITHM];
        fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'_',RISK_MEASURE,'.png'];
        print(fig1_1, '-dpng', '-loose', fileName); 
    end
    
    % fig 1_2 shows the LRT for NOGAMMA V RANDOM comparison
    fig_data_diff = [2*(random_MLEs - noGamma_MLEs), comparison > 0 , model(:,1)];
    %fig_data_diff = sortrows(fig_data_diff,-1);
    significant_players = find(fig_data_diff(:,2) > 0);
    
    fig1_2 = figure();
    hold on;
    bar(fig_data_diff(:,1),'FaceColor',[0.7,0.7,0.7]);                                          % MLE difference as grey bars
    plot([0 playersAmount+1],[threshold_2dof threshold_2dof],'r','LineWidth',THRESHOLD_SIZE);    % 2 dof chi-squared threshold as red line
    plot(significant_players , max(fig_data_diff(:,1)) + max(fig_data_diff(:,1))/20,'k*','MarkerSize',MARKER_SIZE);
    
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('Likelihood Ratio Test','FontSize',FONT_SIZE);
    axis([0, 47, min(fig_data_diff(:,1)), max(fig_data_diff(:,1)) + max(fig_data_diff(:,1))/10])
    set(gca,'FontSize',FONT_SIZE);
%     title('NoGamma model vs Random model - Likelihood Ratio Test');
%     set(gca,'XTick',1:1:46,'XTickLabel',fig_data_diff(:,3));
%     h_legent = legend('LRT statistic','Significance Threshold','Significant Player','Location','NorthWest');
%     set(h_legend,'FontSize',FONT_SIZE);
%     grid
    
    if SAVE_FIG 
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        
        fileName = [SAVE_FOLDER,'LRT/', 'NoGamma_vs_Random_',num2str(RESTRICTED),'restricted'];
        fileName = [fileName,'_',ALGORITHM];
        fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'_',RISK_MEASURE,'.png'];
        print(fig1_2, '-dpng', '-loose', fileName); 
    end
    
    
    %% RL MODEL V NOGAMMA
    % test the more complex model (RL) against the simpler model (nogamma) 
    
    % fig 2_1 shows the MLE values (same as original paper)
    [comparison,pValue,stat,cValue] = lratiotest(-model_MLEs,-noGamma_MLEs, rlm_ngm_dof);
    
    fig_data = [model_MLEs, noGamma_MLEs, comparison > 0, model(:,1)];
    
    %fig_data = sortrows(fig_data,-2);
    significant_players = find(fig_data(:,3) > 0);

    fig2_1 = figure();
    hold on;
    bar(fig_data(:,1),'FaceColor',[0.7,0.7,0.7]);                       % RL model as grey bars
    plot(1:1:playersAmount,fig_data(:,2),'dk','MarkerSize',MARKER_SIZE,'MarkerFaceColor','k');   % NoGamma as black diamond
    plot(significant_players , max(noGamma_MLEs)+max(noGamma_MLEs)/20,'k*','MarkerSize',MARKER_SIZE);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 47 0 max(noGamma_MLEs)+max(noGamma_MLEs)/10])
    set(gca,'FontSize',FONT_SIZE);
%     title('Full RL vs NoGamma model');
%     set(gca,'XTick',1:1:46,'XTickLabel',fig_data(:,4));
%     h_legend = legend('RL Full Model','NoGamma Model','Significant','Location','SouthEast');
%     set(h_legend,'FontSize',FONT_SIZE);
%     grid
    
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);

        fileName = [SAVE_FOLDER, 'RL_vs_NoGamma_',num2str(RESTRICTED),'restricted'];
        fileName = [fileName,'_',ALGORITHM];
        fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'_',RISK_MEASURE,'.png'];
        print(fig2_1, '-dpng', '-loose', fileName); 
    end
    
    % fig 2_2 shows the LRT for RL MODEL V NOGAMMA comparison
    fig_data_diff = [2*(noGamma_MLEs - model_MLEs), comparison > 0 , model(:,1)];
    %fig_data_diff = sortrows(fig_data_diff,-1);
    significant_players = find(fig_data_diff(:,2) > 0);
    
    fig2_2 = figure();
    hold on;
    bar(fig_data_diff(:,1),'FaceColor',[0.7,0.7,0.7]);                                          % MLE difference as grey bars
    plot([0 playersAmount+1],[threshold_1dof threshold_1dof],'r','LineWidth',THRESHOLD_SIZE);   % 1 dof chi-squared threshold as red line
    plot(significant_players , max(fig_data_diff(:,1)) + max(fig_data_diff(:,1))/20,'k*','MarkerSize',MARKER_SIZE);
    
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('Likelihood Ratio Test','FontSize',FONT_SIZE);
    axis([0, 47, min(fig_data_diff(:,1)), max(fig_data_diff(:,1)) + max(fig_data_diff(:,1))/10])
    set(gca,'FontSize',FONT_SIZE);
%     title('RL model vs NoGamma model - Likelihood Ratio Test');
%     set(gca,'XTick',1:1:46,'XTickLabel',fig_data_diff(:,3));
%     h_legend = legend('LRT statistic','Significance Threshold','Significant Player','Location','NorthWest');
%     set(h_legend,'FontSize',FONT_SIZE);
%     grid
     
    if SAVE_FIG 
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        
        fileName = [SAVE_FOLDER,'LRT/', 'RL_vs_NoGamma_',num2str(RESTRICTED),'restricted'];
        fileName = [fileName,'_',ALGORITHM];
        fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'_',RISK_MEASURE,'.png'];
        print(fig2_2, '-dpng', '-loose', fileName); 
    end

    %% RL MODEL V RANDOM
    % test the more complex model (RL) against the random model
    
    % fig 3_1 shows the MLE values (same as original paper)
    [comparison,pValue,stat,cValue] = lratiotest(-model_MLEs,-random_MLEs, rlm_rnd_dof);
    
    better_than_random = model.*(repmat(comparison,1,7));
    better_than_random(all(better_than_random==0,2),:) = [];
    
    fig_data = [model_MLEs, random_MLEs, comparison > 0, model(:,1)];
    %fig_data = sortrows(fig_data,-2);
    significant_players = find(fig_data(:,3) > 0);

    fig3_1 = figure();
    hold on;
    bar(fig_data(:,1),'FaceColor',[0.7,0.7,0.7]);                                      % RL model as grey bars
    plot(1:1:playersAmount,fig_data(:,2),'+k','MarkerSize',MARKER_SIZE,'LineWidth',2);          % Random as hollow diamonds
    plot(significant_players , max(random_MLEs)+max(random_MLEs)/20,'k*','MarkerSize',MARKER_SIZE);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 47 0 max(random_MLEs)+max(random_MLEs)/10])
    set(gca,'FontSize',FONT_SIZE);
%     title('Full RL vs Random model');
%     set(gca,'XTick',1:1:46,'XTickLabel',fig_data(:,4));
%     h_legend = legend('RL Full Model','Random Model','Significant','Location','SouthEast');
%     set(h_legend,'FontSize',FONT_SIZE);
%     grid
    
    if SAVE_FIG
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);

        fileName = [SAVE_FOLDER, 'RL_vs_Random_',num2str(RESTRICTED),'restricted'];
        fileName = [fileName,'_',ALGORITHM];
        fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'_',RISK_MEASURE,'.png'];
        print(fig3_1, '-dpng', '-loose', fileName); 
    end
    
    % fig 3_2 shows the LRT for RL MODEL V NOGAMMA comparison
    fig_data_diff = [2*(random_MLEs - model_MLEs), comparison > 0 , model(:,1)];
    %fig_data_diff = sortrows(fig_data_diff,-1);
    significant_players = find(fig_data_diff(:,2) > 0);
    
    fig3_2 = figure();
    hold on;
    bar(fig_data_diff(:,1),'FaceColor',[0.7,0.7,0.7]);                                          % MLE difference as grey bars
    plot([0 playersAmount+1],[threshold_3dof threshold_3dof],'r','LineWidth',THRESHOLD_SIZE);   % 3 dof chi-squared threshold as red line
    plot(significant_players , max(fig_data_diff(:,1)) + max(fig_data_diff(:,1))/20,'k*','MarkerSize',MARKER_SIZE);
    
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('Likelihood Ratio Test','FontSize',FONT_SIZE);
    axis([0, 47, min(fig_data_diff(:,1)), max(fig_data_diff(:,1)) + max(fig_data_diff(:,1))/10])
    set(gca,'FontSize',FONT_SIZE);
%     title('RL model vs Random - Likelihood Ratio Test');
%     set(gca,'XTick',1:1:46,'XTickLabel',fig_data_diff(:,3));
%     h_legend = legend('LRT statistic','Significance Threshold','Significant Player','Location','NorthWest');
%     set(h_legend,'FontSize',FONT_SIZE);
%     grid
    
    if SAVE_FIG 
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);

        fileName = [SAVE_FOLDER,'LRT/', 'RL_vs_Random_',num2str(RESTRICTED),'restricted'];
        fileName = [fileName,'_',ALGORITHM];
        fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'_',RISK_MEASURE,'.png'];
        print(fig3_2, '-dpng', '-loose', fileName); 
    end
    
% population model statistical test
[phat, pci] = binofit(size(better_than_random,1),playersAmount,ALPHA_CONFIDENCE);
fig4 = figure();
hold on;
eh1 = errorbar(1, phat, phat - pci(1), pci(2) - phat, 'b.');
eh1.LineWidth = 5;
eh1.MarkerSize = 30;
plot([0,2],[0.5,0.5],'r-');
axis([0.5 1.5 0 0.6]);
xlabel('Population');
ylabel('Probability');
set(gca,'FontSize',FONT_SIZE);
set(gca,'Ytick',0:0.25:1);
set(gca,'XtickLabels',[]);
hold off;

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
fileName = [SAVE_FOLDER,'Population_statistic',num2str(RESTRICTED),'restricted'];
fileName = [fileName,'_',ALGORITHM];
fileName = [fileName,'_CAP',num2str(CAP),'_nAct',num2str(N_ACTIONS),'_',RISK_MEASURE,'.png'];
print(fig4, '-dpng', '-loose', fileName); 