function [ MLEFULL, model ] = MLE_model_importer( model_type , rep, k)
%MLE_MODEL_IMPORTER loads models and MLE csv files 
%for both model free and model based
    disp(['importing model: ',model_type]);
    tic
    if strcmpi(model_type,'model_free')
        
        MLEFULL = csvread(['../results/MLE_model/beta_classified/MLE_Portfolio_[0.01, 0.25, 0.5, 0.75, 0.999]_',num2str(rep),'_u.csv']);
        model = csvread(['../results/after_money_1k/_beta_classified/Negative_Portfolio_25cap_3act_',num2str(rep),'rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv']);
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

