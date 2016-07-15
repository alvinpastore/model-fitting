function [ model ] = MLE_model_importer( restricted , algorithm, CAP, nActions,riskMeasure,noGamma)
    %% script to import best model MLE and parameters generated via gradient descent
    % restricted    = the number of transactions skipped for the MLE calculation. 
    %                 using 0 will automatically search in un_restricted folder.
    % algorithm     = the algorithm used to generated the MLEs (qlearning/sarsa)
    % CAP           = transactions CAP
    % nActions      = number of actions 
    % noGamma       = '_nogamma' flag (used as a string for the filename)
    tic
    
    if nargin < 6
        noGamma = '';
    end
    
    if restricted == 0
        restricted = 'un_';
    else
        restricted = [num2str(restricted),'act_'];
    end
    
    folder_path = ['../results/gradient_descent/',restricted,'restricted/',algorithm,'/',riskMeasure,'/'];
    file_path = [folder_path, 'grad_desc_',num2str(CAP),'CAP_',num2str(nActions),'act',noGamma,'.csv'];
    disp(['importing model: ',file_path]);
    model = csvread(file_path);
        
    toc
end

% % OLD VERSION, before gradient descent and deterministic MLE
% if strcmpi(model_type,'model_free')
% 
%     filename = ['MLE_REAL_Portfolio_',num2str(cap),'cap_',num2str(act),'act_u_',date,'.csv'];
%     MLEFULL = csvread(['../results/MLE_model/risk_classified/',filename]);
%     filename = ['Negative_Portfolio_REAL_',num2str(cap),'cap_3act_1rep_u_',date,'.csv'];
%     model = csvread(['../results/after_money_1k/_risk_classified/',filename]);
%     %_fullModel_2states_profit
% elseif strcmpi(model_type,'model_based')
% 
%     %TODO still needs to adapt to new Model based filename
%     MLEFULL = csvread(['../results/MLE_model/model_based/MLE_ModelBased_[0.01, 0.25, 0.5, 0.75, 0.999]_',num2str(CAP),'_u_',num2str(k),'k.csv']);
%     model = csvread(['../results/after_money_1k/_model_based/ModelBased_25cap_3act_',num2str(CAP),'rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u_',num2str(k),'k.csv']);
% 
% end