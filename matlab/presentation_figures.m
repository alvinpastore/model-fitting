
tic;

% res3 are the results for the fullmodel
fullmodel = csvread('results/after_money_1k/_fullModel_2states_profit/Negative_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
model = fullmodel(find(fullmodel(:,2) ~= 0),:);

% load nogamma results
nogamma = csvread('results/after_money_1k/_nogamma/profit_states/results_25cap_3act_1000rep_0.1-1_alpha10-40_beta0-0_gamma_u.csv');
nogamma = nogamma(find(nogamma(:,2) ~= 0),:);

% degrees of freedom = 3-2 = 1
dof = 1;

% count players
players = unique(model(:,1));
playersAmount = size(players,1);

% data structure to hold the performances of all the results available
fit = zeros(playersAmount,8);


% for every player calculate best model and compare with random and nogamma
for playerID = 0:playersAmount-1

    % search for player random MLE
    random_MLE = fullmodel(find(fullmodel(:,1) == playerID & fullmodel(:,2) == 0),5); 
        
    % search for player best model precision
    model_lines = find(model(:,1) == playerID); 
    model_MLE  = min(model(model_lines,5));

    % search for player best nogamma precision
    nogamma_lines = find(nogamma(:,1) == playerID); 
    nogamma_MLE  = min(nogamma(nogamma_lines,5));
    
    % calculate p-value (likelihood ratio)
    % calculate Likelihood ratio (best precision model)
    chi_value_random = 2 * (random_MLE - model_MLE);
    p_rand_MLE = 1-chi2cdf(chi_value_random,dof);
    
    % calculate p-value (likelihood ratio)
    % calculate Likelihood ratio (best precision model)
    chi_value_nogamma = 2 * (nogamma_MLE - model_MLE);
    p_nog_MLE = 1-chi2cdf(chi_value_nogamma,dof);

    % populate performances matrix
    fit(playerID+1,:) = [playerID model_MLE random_MLE nogamma_MLE p_nog_MLE p_rand_MLE chi_value_random chi_value_nogamma];

end
close all;
fit = sortrows(fit,-3);
path = 'graphs/presentation/';
size_X = 20;
size_Y = 15;
%%%%%%%%% RANDOM PLOTs %%%%%%%%%%%%

%% RANDOM MLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% first half
rand1_comparison = figure();
hold on;

bar(fit(:,2),'FaceColor',[0.7,0.7,0.7]);
plot(1:1:length(fit),fit(1:length(fit),3),'-.r','LineWidth',4);

hold off;
%xlabel('Players','FontSize',20);
%ylabel('MLE','FontSize',20);
axis([0 47 0 30])
set(gca,'FontSize',20);
set(gca,'XTick',[1,5,10,15,20,25,30,35,40,45],...  
        'XTickLabel',[]);%[1,5,10,15,20,25,30,35,40,45]);
    
set(gca,'YTick',[0,10,20,30],...  
    'YTickLabel',[]);
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 size_X size_Y]);
saveas(gcf,[path,'vsRandom1.eps']);
print(gcf, '-depsc2', '-loose', [path,'vsRandom1_loose']);
%% RANDOM MLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% second half


%%%%%%%%%% RANDOM Likelihood - RATIO %%%%%%%%%%
% 
% rand2_comparison = figure();
% hold on;
% bar(fit(:,7),'FaceColor',[0.7,0.7,0.7]);
% %plot(1:1:length(fit),fit(:,3),'xk');
% hold off;
% xlabel('Players','FontSize',20);
% ylabel('Likelihood ratio (chi-squared)','FontSize',20);
% %axis([0 47 0 30])
% set(gca,'FontSize',20);
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
% saveas(gcf,['graphs/paper/vsRandom1.eps']);

%% %%%%%%%%% %%%%%%%%% NoGamma %%%%%%%%% %%%%%%%%%%%%
asterisk_offset = 16.7;
significative = fit(:,5) < 0.05;
sig1 = significative(1:23);
sig2 = significative(24:end);

signif_x_1 = find(sig1 > 0);
signif_y_1 = sig1(signif_x_1)*asterisk_offset; 

signif_x_2 = find(sig2 > 0)+23; % offset for second half of players
signif_y_2 = sig2(signif_x_2-23)*asterisk_offset; 


% nogamma bars, diamonds and stars
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % first half
nogamma1_comparison = figure();
hold on;

bar(fit(:,2),'FaceColor',[0.7,0.7,0.7]);

scatter( 1:1:46 , fit(:,4), ...
100 , [0.2,0.2,0.2],...
'filled','d','MarkerEdgeColor',[0,0,0],...
'LineWidth',.5); 

plot(signif_x_1 , signif_y_1,'k*','MarkerSize',15);

axis([0 24 0 18]);
hold off;
xlabel('Players','FontSize',20);
ylabel('MLE','FontSize',20);
set(gca,'FontSize',20);
set(gca,'XTick',[1,5,10,15,20,25,30,35,40,45],'YTick',0:5:15,...  
        'YTickLabel',[0,5,10,15],...
        'XTickLabel',[1,5,10,15,20,25,30,35,40,45]);
    
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 size_X size_Y]); 
saveas(gcf,[path,'vsNogammaAlt1.eps']);
print(gcf, '-depsc2', '-loose', [path,'vsNogammaAlt1_loose']);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % second half





plot(signif_x_2 , signif_y_2,'k*','MarkerSize',15);

axis([23 length(fit)+1 0 18]);
hold off;
xlabel('Players','FontSize',20);
ylabel('MLE','FontSize',20);
set(gca,'FontSize',20);
set(gca,'XTick',0:5:46,'YTick',0:5:15,...  
        'YTickLabel',[0,5,10,15],...
        'XTickLabel',[1,5,10,15,20,25,30,35,40,45]);
    
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 size_X size_Y]); 
saveas(gcf,[path,'vsNogammaAlt2.eps']);
print(gcf, '-depsc2', '-loose', [path,'vsNogammaAlt2_loose']);

%% nogamma 3d
% 
% nogamma3_comparison = figure();
% handle = gca(1);
% 
% bars = [fit(:,[2,4]), significative*20];
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
% ylab = ylabel('Players','FontSize',20);
% zlab = zlabel('MLE','FontSize',20);
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
% bar([fit(1:23,2),fit(1:23,4)]);
% set(gca,'FontSize',20);
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
% saveas(gcf,['graphs/paper/vsNogamma1.png']);
% 
% nogamma2_comparison = figure();
% bar([fit(24:end,2),fit(24:end,4)]);
% set(gca,'FontSize',20);
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperPosition', [0 0 35 25]); %x_width=10cm y_width=15cm
% saveas(gcf,['graphs/paper/vsNogamma2.png']);

toc