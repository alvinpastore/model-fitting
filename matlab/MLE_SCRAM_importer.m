function [Num, MLESCRAMS, MLEFULL, res3] = MLE_SCRAM_importer()

%script to import all the MLE files (20mins each approx)

tic;

% import model CSV MLE 
MLEFULL = csvread('results/MLE_model/MLE_[0.01, 0.25, 0.5, 0.75, 0.999]_1000_u.csv');
res3 = csvread('results/after_money_1k/_fullModel_2states_profit/Negative_25cap_3act_1000rep_0.1-1.0_alpha10.0-40.0_beta0.01-0.999_gamma_u.csv');
% count the scrambled MLE files in the experiment folder
FolderName = 'results/MLE_scram_matlab/';
D = dir([FolderName, '/MLE_*.csv']);
Num = length(D(not([D.isdir])));

% cell array to keep all the MLE matrices
MLESCRAMS = cell(Num,1);

% Import each file in the experiment directory in the MLESCRAMS cell array
for i = 1:Num
    MLESCRAMS{i} = csvread([FolderName,D(i).name]);
    disp(D(i).name);
end

varlist = {'FolderName', 'D', 'i'};
clear (varlist{:});
clear varlist;

toc