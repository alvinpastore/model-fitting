
tic;
RUN_ANALYSIS = 1;% 1 run the analysys. 0 only figures (after analysis done the first time)
LOAD_MLEs = 1; % 1 if models and MLE need loading
SIMPLE_FIGURE = 0; % simple avgMLE value comparison
MULTI_FIGURE = 1; % FLAG to plot cumulative errorbar figure 
PARTIAL_FIGURES = 1; % FLAG to plot errorbar figures singularly
% offset = amount of models in gridsearch
% = 5alpha X 4betas X 5gammas
OFFSET = 100;
alpha_confidence = 0.01; % 99% confidence
iterations = 1000;
FONT_SIZE = 16;
MARKER_SIZE = 10;

if LOAD_MLEs
    risk_classified   = csvread('results/after_money_1k/_fullModel_2states_profit/Negative_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
    risk_classified = risk_classified(find(risk_classified(:,2) ~= 0),:);
    risk_MLE          = csvread('results/MLE_model/MLE_[0.01, 0.25, 0.5, 0.75, 0.999]_1000_u.csv');

    beta_classified   = csvread('results/after_money_1k/_beta_classified/Negative_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
    beta_classified = beta_classified(find(beta_classified(:,2) ~= 0),:);
    beta_MLE          = csvread('results/MLE_model/beta_classified/MLE_[0.01, 0.25, 0.5, 0.75, 0.999]_1000_u.csv');    

    stddev_classified = csvread('results/after_money_1k/_std_dev_classified/Negative_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
    stddev_classified = stddev_classified(find(stddev_classified(:,2) ~= 0),:);
    stddev_MLE        = csvread('results/MLE_model/stddev_classified/MLE_[0.01, 0.25, 0.5, 0.75, 0.999]_1000_u.csv');         
end

% count players
players = unique(risk_classified(:,1));
playersAmount = size(players,1);

% structure to store the simple avgMLE simple_avgMLE_comparison 
simple_avgMLE_comparison = zeros(playersAmount,3);

% structures to store the p-value and CIs for each simple_avgMLE_comparison and for each player
players_errorbars_rvb = zeros(playersAmount,4);
players_errorbars_rvs = zeros(playersAmount,4);
players_errorbars_bvs = zeros(playersAmount,4);
players_errorbars_bvr = zeros(playersAmount,4);
players_errorbars_svb = zeros(playersAmount,4);
players_errorbars_svr = zeros(playersAmount,4);

% vectors to store MLE lines
risk_MLE_line   = zeros(1,iterations);
beta_MLE_line   = zeros(1,iterations);
stddev_MLE_line = zeros(1,iterations);
if RUN_ANALYSIS
    
    % for every player calculate best model and compare with beta and stddev
    for playerID = 0:playersAmount-1
        disp(playerID);
        
        % search for player best model using avgMLE
        risk_lines = find(risk_classified(:,1) == playerID); 
        [risk_best_MLE, risk_best_MLE_line]  = min(risk_classified(risk_lines,5));
        % find corresponding line and store MLE line (1000 values) 
        corresponding_MLE_line = risk_best_MLE_line + (playerID * OFFSET);
        % end-1 because of trailing 0 
        risk_MLE_line = risk_MLE(corresponding_MLE_line,5:end-1); 

        % same for beta classified ...
        beta_lines = find(beta_classified(:,1) == playerID); 
        [beta_best_MLE, beta_best_MLE_line] = min(beta_classified(beta_lines,5));
        % checking the same model (set of parameters)
        corresponding_MLE_line = risk_best_MLE_line + (playerID * OFFSET);
        beta_MLE_line = beta_MLE(corresponding_MLE_line,5:end-1); 

        % ... and for stddev classified
        stddev_lines = find(stddev_classified(:,1) == playerID); 
        [stddev_best_MLE, stddev_best_MLE_line]  = min(stddev_classified(stddev_lines,5));
        % checking the same model (set of parameters)
        corresponding_MLE_line = risk_best_MLE_line + (playerID * OFFSET);
        stddev_MLE_line = stddev_MLE(corresponding_MLE_line,5:end-1); 

        % structure to save the simple_avgMLE_comparisons, at each iterations
        % it stores the outcome of the simple_avgMLE_comparison of a MLE instance 
        % against all the 1000 MLEs of the alternative classification
        MLE_simple_avgMLE_comparison = zeros(1,iterations);

        % structure to save the outcome of the three simple_avgMLE_comparison (rvb,rvs,bvs)
        % each row is the outcome of the simple_avgMLE_comparisons (1 if stat sign, 0 otherwise)
        MLE_results_player = zeros(6,iterations);
        
        % 1,2)compare each MLE instance in risk_MLE_line vs all MLE instances in beta_MLE_line and stddev_MLE_line 
        % 3,4)compare each MLE instance in beta_MLE_line vs all MLE instances in stddev_MLE_line and risk_MLE_line
        % 5,6)compare each MLE instance in stddev_MLE_line vs all MLE instances in risk_MLE_line and beta_MLE_line 
        for MLE_instance_idx = 1:1:iterations

            % 1)
            % compare risk vs beta and apply binomial CI test (clopper-pearson) at results of simple_avgMLE_comparison
            risk_MLE_instance = risk_MLE_line(MLE_instance_idx); % getting risk MLEs
            MLE_simple_avgMLE_comparison = risk_MLE_instance < beta_MLE_line;
            [phat, pci] = binofit(sum(MLE_simple_avgMLE_comparison), iterations,alpha_confidence);

            % if the Confidence Interval is above 0.5 threshold 
            % the MLE instance is stat. sign. better than alternative
            if min(phat,min(pci)) > 0.5
                MLE_results_player(1,MLE_instance_idx) = 1;
            end

            % 2)
            % compare risk vs stddev and same as before
            MLE_simple_avgMLE_comparison = risk_MLE_instance < stddev_MLE_line;
            [phat, pci] = binofit(sum(MLE_simple_avgMLE_comparison), iterations,alpha_confidence);

            if min(phat,min(pci)) > 0.5
                MLE_results_player(2,MLE_instance_idx) = 1;
            end

            % 3)
            % compare beta vs stddev and same as before
            beta_MLE_instance = beta_MLE_line(MLE_instance_idx);
            MLE_simple_avgMLE_comparison = beta_MLE_instance < stddev_MLE_line;
            [phat, pci] = binofit(sum(MLE_simple_avgMLE_comparison), iterations,alpha_confidence);

            if min(phat,min(pci)) > 0.5
                MLE_results_player(3,MLE_instance_idx) = 1;
            end
            
            % 4)
            % compare beta vs risk and same as before
            MLE_simple_avgMLE_comparison = beta_MLE_instance < risk_MLE_line;
            [phat, pci] = binofit(sum(MLE_simple_avgMLE_comparison), iterations,alpha_confidence);

            if min(phat,min(pci)) > 0.5
                MLE_results_player(4,MLE_instance_idx) = 1;
            end
            
            % 5)
            % compare stddev vs risk and same as before
            stddev_MLE_instance = stddev_MLE_line(MLE_instance_idx);
            MLE_simple_avgMLE_comparison = stddev_MLE_instance < risk_MLE_line;
            [phat, pci] = binofit(sum(MLE_simple_avgMLE_comparison), iterations,alpha_confidence);

            if min(phat,min(pci)) > 0.5
                MLE_results_player(5,MLE_instance_idx) = 1;
            end
            
            % 6)
            % compare stddev vs beta and same as before
            MLE_simple_avgMLE_comparison = stddev_MLE_instance < beta_MLE_line;
            [phat, pci] = binofit(sum(MLE_simple_avgMLE_comparison), iterations,alpha_confidence);

            if min(phat,min(pci)) > 0.5
                MLE_results_player(6,MLE_instance_idx) = 1;
            end

        end

        % apply binomial CI test (clopper-pearson) at MLE instances outcomes
        [phat1, pci1] = binofit(sum(MLE_results_player(1,:)),iterations,alpha_confidence);
        [phat2, pci2] = binofit(sum(MLE_results_player(2,:)),iterations,alpha_confidence);
        [phat3, pci3] = binofit(sum(MLE_results_player(3,:)),iterations,alpha_confidence);
        [phat4, pci4] = binofit(sum(MLE_results_player(4,:)),iterations,alpha_confidence);
        [phat5, pci5] = binofit(sum(MLE_results_player(5,:)),iterations,alpha_confidence);
        [phat6, pci6] = binofit(sum(MLE_results_player(6,:)),iterations,alpha_confidence);

        % store p values and confidence intervals for each player
        players_errorbars_rvb(playerID+1,:) = [playerID, phat1, pci1(1), pci1(2)];
        players_errorbars_rvs(playerID+1,:) = [playerID, phat2, pci2(1), pci2(2)];
        players_errorbars_bvs(playerID+1,:) = [playerID, phat3, pci3(1), pci3(2)];
        players_errorbars_bvr(playerID+1,:) = [playerID, phat4, pci4(1), pci4(2)];
        players_errorbars_svb(playerID+1,:) = [playerID, phat5, pci5(1), pci5(2)];
        players_errorbars_svr(playerID+1,:) = [playerID, phat6, pci6(1), pci6(2)];
                
        % store avg MLE values and simple_avgMLE_comparison p-vaules
        simple_avgMLE_comparison(playerID + 1,:) = [risk_best_MLE beta_best_MLE stddev_best_MLE];
        
    end
end
close all;

%% plot simple avg MLE simple_avgMLE_comparison
if SIMPLE_FIGURE
    fig1 = figure();
    hold on
    plot(1:1:playersAmount,simple_avgMLE_comparison(:,1),'bx','LineWidth',4);
    plot(1:1:playersAmount,simple_avgMLE_comparison(:,2),'ro','LineWidth',4);
    plot(1:1:playersAmount,simple_avgMLE_comparison(:,3),'g*','LineWidth',4);
    [hleg1, hobj1] = legend({'risk','beta','stddev'},'FontSize',20);
    set(hleg1,'position',[0.18 0.68 0.15 0.2])
    title('MLE simple avgMLE comparison for stock classification methods');
    ylabel('Model Fitness (MLE)');
    xlabel('Player ');
    set(gca,'XTick',[0,5,10,15,20,25,30,35,40,45],...  
            'XTickLabel',[0,5,10,15,20,25,30,35,40,45],...
            'FontSize',20);
    hold off
end

%% errorbars graphs %%

if MULTI_FIGURE
    %% graph for all comparisons errorbars together (sorted according to rvb)
    fig2 = figure();
    hold on
    
    title('Risk v Beta vs Std Dev','FontSize',FONT_SIZE);
    plot([0,46],[0.5,0.5],'r-');
    axis([-1 46 -0.05 1.05]);
    labels = num2str(sorted_CI_bvs(:,1));
    set(gca,'Xtick',0:1:45,'XTickLabel',labels);
    xlabel('Player ID');
    ylabel('Probability');
    set(gca,'FontSize',FONT_SIZE);
    set(gca,'xgrid','on')
    
    [sorted_CI_rvb, sort_idx] = sortrows(players_errorbars_rvb,1);  
    sorted_CI_rvs = sortrows(players_errorbars_rvs,2);
    sorted_CI_bvs = sortrows(players_errorbars_bvs,2);
    sorted_CI_bvr = sortrows(players_errorbars_bvr,2);
    sorted_CI_svb = sortrows(players_errorbars_svb,2);
    sorted_CI_svr = sortrows(players_errorbars_svr,2);
    
    e1 = errorbar(players_errorbars_rvb(:,1),sorted_CI_rvb(sort_idx,2),...
        sorted_CI_rvb(sort_idx,2)-sorted_CI_rvb(sort_idx,3),...
        sorted_CI_rvb(sort_idx,4)-sorted_CI_rvb(sort_idx,2),'xr','MarkerSize',MARKER_SIZE);

    e2 = errorbar(players_errorbars_rvb(:,1),sorted_CI_rvs(sort_idx,2),...
        sorted_CI_rvs(sort_idx,2)-sorted_CI_rvs(sort_idx,3),...
        sorted_CI_rvs(sort_idx,4)-sorted_CI_rvs(sort_idx,2),'or','MarkerSize',MARKER_SIZE);

    e3 = errorbar(players_errorbars_rvb(:,1),sorted_CI_bvs(sort_idx,2),...
        sorted_CI_bvs(sort_idx,2)-sorted_CI_bvs(sort_idx,3),...
        sorted_CI_bvs(sort_idx,4)-sorted_CI_bvs(sort_idx,2),'*b','MarkerSize',MARKER_SIZE);

    e4 = errorbar(players_errorbars_rvb(:,1),sorted_CI_bvr(sort_idx,2),...
        sorted_CI_bvr(sort_idx,2)-sorted_CI_bvr(sort_idx,3),...
        sorted_CI_bvr(sort_idx,4)-sorted_CI_bvr(sort_idx,2),'xb','MarkerSize',MARKER_SIZE);

    e5 = errorbar(players_errorbars_rvb(:,1),sorted_CI_svb(sort_idx,2),...
        sorted_CI_svb(sort_idx,2)-sorted_CI_svb(sort_idx,3),...
        sorted_CI_svb(sort_idx,4)-sorted_CI_svb(sort_idx,2),'*g','MarkerSize',MARKER_SIZE);

    e6 = errorbar(players_errorbars_rvb(:,1),sorted_CI_svr(sort_idx,2),...
        sorted_CI_svr(sort_idx,2)-sorted_CI_svr(sort_idx,3),...
        sorted_CI_svr(sort_idx,4)-sorted_CI_svr(sort_idx,2),'og','MarkerSize',MARKER_SIZE);
        
    hleg = legend([e1 e2 e3 e4 e5 e6],...
        {'Risk v Beta','Risk v Stddev', 'Beta v Stddev',...
        'Beta v Risk','Stddev v Beta','Stddev v Risk'});
    
    set(hleg,'position',[0.18,0.68,0.2,0.2]) ;
    hold off
end


if PARTIAL_FIGURES 
    best_measure_count = zeros(1,3);
    for playerID = 1:playersAmount
                
        % compare risk vs beta AND stddev
        if min(players_errorbars_rvb(playerID,2:end)) > 0.5 &&...
           min(players_errorbars_rvs(playerID,2:end)) > 0.5 
            best_measure_count(1) = best_measure_count(1) + 1;
        end
        
        % compare beta vs risk AND stddev
        if min(players_errorbars_bvr(playerID,2:end)) > 0.5 &&...
           min(players_errorbars_bvs(playerID,2:end)) > 0.5
            best_measure_count(2) = best_measure_count(2) + 1;
        end
        
        % compare stddev vs risk AND beta
        if min(players_errorbars_svr(playerID,2:end)) > 0.5 &&...
           min(players_errorbars_svb(playerID,2:end)) > 0.5
            best_measure_count(3) = best_measure_count(3) + 1;
        end
    end
    
    disp(['risk ',num2str(best_measure_count(1)),...
          ' beta ',num2str(best_measure_count(2)),...
          ' stddev ',num2str(best_measure_count(3))]);
    
    % figure risk vs rest
    fig3 = figure();
    hold on
    [sorted_CI_rvb, sort_idx1] = sortrows(players_errorbars_rvb,2);

    errorbar(players_errorbars_rvb(:,1),players_errorbars_rvb(sort_idx1,2),...
        players_errorbars_rvb(sort_idx1,2)-players_errorbars_rvb(sort_idx1,3),...
        players_errorbars_rvb(sort_idx1,4)-players_errorbars_rvb(sort_idx1,2));
    
    errorbar(players_errorbars_rvb(:,1),players_errorbars_rvs(sort_idx1,2),...
        players_errorbars_rvs(sort_idx1,2)-players_errorbars_rvs(sort_idx1,3),...
        players_errorbars_rvs(sort_idx1,4)-players_errorbars_rvs(sort_idx1,2));
    
    title('Risk vs Beta and Stddev','FontSize',FONT_SIZE);
    plot([0,46],[0.5,0.5],'r-');
    axis([-1 46 0 1]);
    labels = num2str(sorted_CI_rvb(:,1));
    set(gca,'Xtick',0:1:45,'XTickLabel',labels);
    xlabel('Player ID');
    ylabel('Probability');
    set(gca,'FontSize',FONT_SIZE);
    hold off
    
    % figure beta vs rest
    fig4 = figure();
    hold on
    [sorted_CI_bvr,sort_idx2] = sortrows(players_errorbars_bvr,2);
    
    errorbar(players_errorbars_bvr(:,1),players_errorbars_bvr(sort_idx2,2),...
        players_errorbars_bvr(sort_idx2,2)-players_errorbars_bvr(sort_idx2,3),...
        players_errorbars_bvr(sort_idx2,4)-players_errorbars_bvr(sort_idx2,2));
    
    errorbar(players_errorbars_bvr(:,1),players_errorbars_bvs(sort_idx2,2),...
        players_errorbars_bvs(sort_idx2,2)-players_errorbars_bvs(sort_idx2,3),...
        players_errorbars_bvs(sort_idx2,4)-players_errorbars_bvs(sort_idx2,2));
    
    title('Beta vs Risk and Std dev','FontSize',FONT_SIZE);
    plot([0,46],[0.5,0.5],'r-');
    axis([-1 46 0 1]);
    labels = num2str(sorted_CI_bvr(:,1));
    set(gca,'Xtick',0:1:45,'XTickLabel',labels);
    xlabel('Player ID');
    ylabel('Probability');
    set(gca,'FontSize',FONT_SIZE);
    hold off

    % figure stddev vs rest
    fig5 = figure();
    hold on
    [sorted_CI_svr, sort_idx3] = sortrows(players_errorbars_svb,2);
    
    errorbar(players_errorbars_svr(:,1),players_errorbars_svb(sort_idx3,2),...
        players_errorbars_svb(sort_idx3,2)-players_errorbars_svb(sort_idx3,3),...
        players_errorbars_svb(sort_idx3,4)-players_errorbars_svb(sort_idx3,2));  
    
    errorbar(players_errorbars_svr(:,1),players_errorbars_svr(sort_idx3,2),...
        players_errorbars_svr(sort_idx3,2)-players_errorbars_svr(sort_idx3,3),...
        players_errorbars_svr(sort_idx3,4)-players_errorbars_svr(sort_idx3,2));      
    
    title('Std Dev vs Risk and Beta','FontSize',FONT_SIZE);
    plot([0,46],[0.5,0.5],'r-');
    axis([-1 46 0 1]);
    labels = num2str(sorted_CI_svr(:,1));
    set(gca,'Xtick',0:1:45,'XTickLabel',labels);
    xlabel('Player ID');
    ylabel('Probability');
    set(gca,'FontSize',FONT_SIZE);
    hold off
end

toc;