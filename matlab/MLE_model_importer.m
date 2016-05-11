function [ MLEFULL, model ] = MLE_model_importer( model_type )
%MLE_MODEL_IMPORTER loads models and MLE csv files 
%for both model free and model based

    if strcmpi(model_type,'model_free')
        
        MLEFULL = csvread('../results/MLE_model/beta_classified/MLE_Portfolio_[0.01, 0.25, 0.5, 0.75, 0.999]_1000_u.csv');
        model = csvread('../results/after_money_1k/_fullModel_2states_profit/Negative_Portfolio_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
    
    elseif strcmpi(model_type,'model_based')
        
        MLEFULL = csvread('../results/MLE_model/model_based/MLE_ModelBased_[0.01, 0.25, 0.5, 0.75, 0.999]_1000_u.csv');
        model = csvread('../results/after_money_1k/_model_based/ModelBased_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
    
    end
    
    
end

