%% script to generate and save figures for both paper or presentation versions
%   usage:
%   [performance_fit] = paper_figures(paper_save,presentation_save)
%   paper_save and presentation_save are both flags 
%   paper_save has priority 
%   (1,1 will save only in paper; 0,1 will save in presentation)
%   (also used to load the performance_fit matrix)
%   [playerID model_MLE random_MLE nogamma_MLE p_nog_MLE p_rand_MLE chi_value_random chi_value_nogamma]
function [performance_fit] = paper_figures(paper_save,presentation_save)
    tic;
    close all;
    
    % FLAGS for figure save folders
    PAPER = paper_save;                 % 1 to save pictures to PAPER folder
    PRESENTATION = presentation_save;   % 1 to save to presentation folder (paper has priority, needs to be 0)

    % print figures dimensions
    PRINT_WIDTH = 20;
    PRINT_HEIGHT = 15;

    % markup static values
    FONT_SIZE = 20;
    MARKER_SIZE = 15;
    ASTERISK_OFFSET = 23;

    % res3 are the results for the fullmodel
    fullmodel = csvread('../results/after_money_1k/_fullModel_2states_profit/Negative_Portfolio_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
    fullmodel = csvread('../results/after_money_1k/_model_based/Negative_Portfolio_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
    model = fullmodel(fullmodel(:,2) ~= 0,:);

    % load nogamma results
    nogamma = csvread('../results/after_money_1k/_nogamma/profit_states/Negative_Portfolio_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.0-0.0_gamma_u.csv');
    %results_25cap_3act_1000rep_0.1-1_alpha10-40_beta0-0_gamma_u.csv');
    nogamma = nogamma(nogamma(:,2) ~= 0,:);

    % degrees of freedom = 
    % number of params of bigger model - number of params of nested model
    rnd_dof = 3-1;
    ng_dof = 3-2;
    
    % count players
    players = unique(model(:,1));
    playersAmount = size(players,1);

    % data structure to hold the p values and chi-values for all the comparisons
    performance_fit = zeros(playersAmount,8);

    % column which contains MLE in the results
    MLE_column = 5;

    % for every player calculate best model and compare with random and nogamma
    for playerID = 0:playersAmount-1

        % search for player random MLE
        random_MLE = fullmodel(fullmodel(:,1) == playerID & fullmodel(:,2) == 0,5); 

        % search for player best model MLE
        model_lines = find(model(:,1) == playerID); 
        model_MLE  = min(model(model_lines,MLE_column));

        % search for player best nogamma MLE
        nogamma_lines = find(nogamma(:,1) == playerID); 
        nogamma_MLE  = min(nogamma(nogamma_lines,MLE_column));

        % calculate p-value (likelihood ratio)
        % calculate Likelihood ratio (best MLE model)
        chi_value_random = 2 * (random_MLE - model_MLE);
        p_rand_MLE = 1-chi2cdf(chi_value_random,rnd_dof);

        % calculate p-value (likelihood ratio)
        % calculate Likelihood ratio (best MLE model)
        chi_value_nogamma = 2 * (nogamma_MLE - model_MLE);
        p_nog_MLE = 1-chi2cdf(chi_value_nogamma,ng_dof);

        % populate performances matrix
        performance_fit(playerID+1,:) = [playerID model_MLE random_MLE nogamma_MLE p_nog_MLE p_rand_MLE chi_value_random chi_value_nogamma];

    end
    
    performance_fit = sortrows(performance_fit,-3);

    if PAPER
        path = 'graphs/paper/new/portfolio/';
    elseif PRESENTATION
        path = 'graphs/presentation/portfolio/';
    end

    %%%%%%%%% RANDOM PLOTs %%%%%%%%%%%%

    %% RANDOM MLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% full image
    rand0_comparison = figure();
    hold on;
    bar(performance_fit(:,2),'FaceColor',[0.7,0.7,0.7]);
    plot(1:1:length(performance_fit),performance_fit(1:length(performance_fit),3),'-.r','LineWidth',4);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 47 0 30])
    set(gca,'FontSize',FONT_SIZE);

    if PRESENTATION || PAPER
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        saveas(gcf,[path,'vsRandom_full.eps']);
        print(gcf, '-depsc2', '-loose', [path,'vsRandom_full_loose']);
    end

    %% RANDOM MLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% first half
    rand1_comparison = figure();
    hold on;
    bar(performance_fit(1:23,2),'FaceColor',[0.7,0.7,0.7]);
    plot(1:1:23,performance_fit(1:23,3),'-.r','LineWidth',4);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 24 0 30])
    set(gca,'FontSize',FONT_SIZE);
    set(gca,'XTick',[1,5,10,15,20,25,30,35,40,45],...  
            'XTickLabel',[1,5,10,15,20,25,30,35,40,45]);

    if PRESENTATION || PAPER
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        saveas(gcf,[path,'vsRandom_half1.eps']);
        print(gcf, '-depsc2', '-loose', [path,'vsRandom_half1_loose']);
    end

    %% RANDOM MLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% second half
    rand2_comparison = figure();
    hold on;
    bar(24:1:length(performance_fit),performance_fit(24:length(performance_fit),2),'FaceColor',[0.7,0.7,0.7]);
    plot(24:1:length(performance_fit),performance_fit(24:length(performance_fit),3),'-.r','LineWidth',4);
    hold off;
    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([23 length(performance_fit)+1 0 30])
    set(gca,'FontSize',FONT_SIZE);

    if PRESENTATION || PAPER
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]);
        saveas(gcf,[path,'vsRandom_half2.eps'])
        print(gcf, '-depsc2', '-loose', [path,'vsRandom_half2_loose']);
    end

    %%%%%%%%%% RANDOM Likelihood - RATIO %%%%%%%%%%
    % 
    % rand2_comparison = figure();
    % hold on;
    % bar(performance_fit(:,7),'FaceColor',[0.7,0.7,0.7]);
    % %plot(1:1:length(performance_fit),performance_fit(:,3),'xk');
    % hold off;
    % xlabel('Players','FontSize',FONT_SIZE);
    % ylabel('Likelihood ratio (chi-squared)','FontSize',FONT_SIZE);
    % %axis([0 47 0 30])
    % set(gca,'FontSize',FONT_SIZE);
    % set(gcf, 'PaperUnits', 'centimeters');
    % set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
    % saveas(gcf,['graphs/paper/vsRandom1.eps']);

    %% %%%%%%%%% %%%%%%%%% NoGamma %%%%%%%%% %%%%%%%%%%%%
    performance_fit = sortrows(performance_fit,-4);

    significative = performance_fit(:,5) < 0.05;
    sig1 = significative(1:23);
    sig2 = significative(24:end);

    signif_all_x = find(significative > 0);
    signif_all_y = significative(signif_all_x) * ASTERISK_OFFSET;

    signif_x_1 = find(sig1 > 0);
    signif_y_1 = sig1(signif_x_1) * ASTERISK_OFFSET; 

    signif_x_2 = find(sig2 > 0)+23; % offset for second half of players
    signif_y_2 = sig2(signif_x_2-23) * ASTERISK_OFFSET; 

    % nogamma bars, diamonds and stars
    % % % % % % % % % % % % % % % % % % % % % % % full 
    nogamma0_comparison = figure();
    hold on;

    bar(performance_fit(:,2),'FaceColor',[0.7,0.7,0.7]);

    plot( 1:1:46 , performance_fit(:,4), ...
    '-.g','MarkerEdgeColor',[0,0,0],...
    'LineWidth',4); 

    plot(signif_all_x , signif_all_y,'k*','MarkerSize',MARKER_SIZE);

    hold off;

    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 47 0 25]);

    set(gca,'FontSize',FONT_SIZE);
    set(gca,'XTick',[1,5,10,15,20,25,30,35,40,45],'YTick',0:5:25,...  
            'YTickLabel',[0,5,10,15,20,25],...
            'XTickLabel',[]);

    if PRESENTATION || PAPER
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]); 
        saveas(gcf,[path,'vsNogammaAlt1.eps']);
        print(gcf, '-depsc2', '-loose', [path,'vsNogammaAlt1_loose']);
    end
    % nogamma bars, diamonds and stars
    % % % % % % % % % % % % % % % % % % % % % % % % % first half
    nogamma1_comparison = figure();
    hold on;

    bar(performance_fit(1:23,2),'FaceColor',[0.7,0.7,0.7]);

    plot( 1:1:23 , performance_fit(1:23,4), ...
    '-.g','MarkerEdgeColor',[0,0,0],...
    'LineWidth',4); 

    plot(signif_x_1 , signif_y_1,'k*','MarkerSize',MARKER_SIZE);

    hold off;

    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([0 24 0 25]);

    set(gca,'FontSize',FONT_SIZE);
    set(gca,'XTick',[1,5,10,15,20,25,30,35,40,45],'YTick',0:5:25,...  
            'YTickLabel',[0,5,10,15,20,25],...
            'XTickLabel',[]);
    if PRESENTATION || PAPER
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]); 
        saveas(gcf,[path,'vsNogammaAlt1.eps']);
        print(gcf, '-depsc2', '-loose', [path,'vsNogammaAlt1_loose']);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % second half
    nogamma2_comparison = figure();
    hold on;

    bar(24:1:length(performance_fit),performance_fit(24:end,2),'FaceColor',[0.7,0.7,0.7]);

    plot( 24:1:length(performance_fit) , performance_fit(24:end,4), ...
    '-.g','MarkerEdgeColor',[0,0,0],...
    'LineWidth',4);  

    plot(signif_x_2 , signif_y_2,'k*','MarkerSize',MARKER_SIZE);

    hold off;

    xlabel('Players','FontSize',FONT_SIZE);
    ylabel('MLE','FontSize',FONT_SIZE);
    axis([23 length(performance_fit)+1 0 25]);

    set(gca,'FontSize',FONT_SIZE);
    set(gca,'XTick',0:5:46,'YTick',0:5:25,...  
            'YTickLabel',[0,5,10,15,20,25],...
            'XTickLabel',[]);
    if PRESENTATION || PAPER
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 PRINT_WIDTH PRINT_HEIGHT]); 
        saveas(gcf,[path,'vsNogammaAlt2.eps']);
        print(gcf, '-depsc2', '-loose', [path,'vsNogammaAlt2_loose']);
    end
    %% nogamma 3d
    % 
    % nogamma3_comparison = figure();
    % handle = gca(1);
    % 
    % bars = [performance_fit(:,[2,4]), significative*20];
    % bar_handle = bar3(bars);
    % 
    % alpha(0.4);
    % 
    % black = [0,0,0];
    % dark_grey = black + 0.2;
    % grey = black + 0.5;
    % light_grey = black + 0.8;
    % white = black + 1;
    % 
    % col = {light_grey; grey; dark_grey};
    % 
    % for handle_idx = 1:length(bar_handle)
    %     set(bar_handle(handle_idx),'FaceColor',col{handle_idx})
    % end
    % 
    % %axis([0 size(bars,2) 0 47 min(min(plot_perf))-10, max(max(plot_perf))+10]);
    % %zlim([min(min(plot_perf))-10, max(max(plot_perf))+10]);
    % 
    % %set(gca,'Ytick',1:46);
    % %set(gca,'YtickLabel',sorted_performances(:,1),'FontSize',18);
    % %set(gca,'YTick',[]);
    % %set(gca,'XTick',[]);
    % 
    % 
    % ylab = ylabel('Players','FontSize',FONT_SIZE);
    % zlab = zlabel('MLE','FontSize',FONT_SIZE);
    % 
    % %l{1}=' 3 Actions'; l{2}=' 4 Actions'; l{3}=' 5 Actions'; l{4}=' 10 Actions'; 
    % %hLegend = legend(bar_handle,l,'Location',[0.7 0.5 0 0]);
    % %set(hLegend,'FontSize',24);
    % 
    % %set(handle,'FontName','Hiragino Kaku Gothic Pro');
    % 
    % %writePDF1000ppi(gcf, 'prova');

    %% no gamma grouped
    % nogamma1_comparison = figure();
    % bar([performance_fit(1:23,2),performance_fit(1:23,4)]);
    % set(gca,'FontSize',FONT_SIZE);
    % set(gcf, 'PaperUnits', 'centimeters');
    % set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
    % saveas(gcf,['graphs/paper/vsNogamma1.png']);
    % 
    % nogamma2_comparison = figure();
    % bar([performance_fit(24:end,2),performance_fit(24:end,4)]);
    % set(gca,'FontSize',FONT_SIZE);
    % set(gcf, 'PaperUnits', 'centimeters');
    % set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
    % saveas(gcf,['graphs/paper/vsNogamma2.png']);
    disp('paper_figures')
    toc
end