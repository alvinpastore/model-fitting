function [ MLEFULL, model ] = MLE_model_importer( model_type , rep, k)
%MLE_MODEL_IMPORTER loads models and MLE csv files 
%for both model free and model based
    disp(['importing model: ',model_type]);
    tic
    if strcmpi(model_type,'model_free')
        
        filename = ['MLE_REAL_Portfolio_[0.0, 0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.999]_',num2str(rep),'_u.csv'];
        MLEFULL = csvread(['../results/MLE_model/risk_classified/',filename]);
        filename = ['Negative_Portfolio_REAL_25cap_3act_',num2str(rep),'rep_0.01-1.0_alpha1.0-100.0_beta0.0-0.999_gamma_u.csv'];
        model = csvread(['../results/after_money_1k/_risk_classified/',filename]);
        %_fullModel_2states_profit
    elseif strcmpi(model_type,'model_based')
        
        MLEFULL = csvread(['../results/MLE_model/model_based/MLE_ModelBased_[0.01, 0.25, 0.5, 0.75, 0.999]_',num2str(rep),'_u_',num2str(k),'k.csv']);
        model = csvread(['../results/after_money_1k/_model_based/ModelBased_25cap_3act_',num2str(rep),'rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u_',num2str(k),'k.csv']);
    
    elseif strcmpi(model_type,'no_gamma')
        
        MLEFULL = csvread(['../results/MLE_model/nogamma/MLE_Portfolio_[0.0]_',num2str(rep),'_u.csv']);
        model = csvread(['../results/after_money_1k/_nogamma/profit_states/Negative_Portfolio_25cap_3act_',num2str(rep),'rep_0.1-1.0_alpha10.0-40.0_beta0.0-0.0_gamma_u.csv']);
        
    end
    toc
end

