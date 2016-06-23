% script to compare best model (set of param) 
% found using stochastic gradient descent vs random MLE

% number of params of bigger model - number of params of nested model
rnd_dof = 3-1;  % alpha, beta, gamma, (k) VS beta

%restricted = '10act'; restr_trans = 10;
restricted = 'un'; restr_trans = 0;
CAP = 107;
nActions = 5;
nogamma = '';%'_nogamma';
algorithm = 'sarsa';%'qlearning';
% the original amount of transactions
% depends only on the CAP (not restriction yet)
transactions_number = csvread(['../results/stats/transactions_number_',num2str(CAP),'CAP.csv']);

% the random MLE value is calculated based on 
% the number of actions and the number of transactions
random_MLEs = - (transactions_number - restr_trans) * log(1 / nActions);

% number of observations (for calculating BIC)
% the original number of transactions minus the restriction (training)
transactions = transactions_number - restr_trans;

close all;

% LOAD THE GRAD DESC MODEL TO TEST
model_file = ['../results/gradient_descent/', restricted ,'_restricted/',algorithm,'/grad_desc_',num2str(CAP),'CAP_',num2str(nActions),'act',nogamma,'.csv'];
disp(['using file: ',model_file]);
model = csvread(model_file);
model = [model random_MLEs transactions_number];

playersAmount = size(model,1);

% the model MLE is derived from the grad desc results (model)
model_MLEs = model(:,5);

scatter(model(:,1), random_MLEs, 70, 'xr');
hold on
scatter(model(:,1), model_MLEs, 70, 'ob');
%axis([-1 46 0 30])
grid on
grid minor

% calculate aic for RL models
[aic,bic] = aicbic(-model_MLEs, ones(playersAmount,1)*3, transactions);
[raic,rbic] = aicbic(-random_MLEs, ones(playersAmount,1), transactions);

% likelihood ratio test manual
chi_value_random = 2 * (-model_MLEs - (-random_MLEs));
p_rand_MLE = 1-chi2cdf(chi_value_random, rnd_dof);

% likelihood ratio test matlab
[h,pValue,stat,cValue] = lratiotest(random_MLEs,model_MLEs, rnd_dof);

aic_comparison = aic<raic;
bic_comparison = bic<rbic;

% get only the players and the models better than random
better_than_random = model.*(repmat(h,1,7));
better_than_random(all(better_than_random==0,2),:) = [];

plot(better_than_random(:,1),better_than_random(:,5),'g*');
title(['Model: CAP',num2str(CAP),' nActions',num2str(nActions),' ',restricted ,'-restricted'])
xlabel('Player ID') 
ylabel('MLE') 
legend('Random','Model','Significant','Location','best')
set(gca,'FontSize',20);