function [Num, MLESCRAMS] = MLE_SCRAM_importer(restricted, algorithm, CAP, nActions)
    %% script to import all the scrambled MLE files generated via gradient descent
    % restricted    = the number of transactions skipped for the MLE calculation. 
    %                 using 0 will automatically search in un_restricted folder.
    % algorithm     = the algorithm used to generated the MLEs (qlearning/sarsa)
    % CAP           = transactions CAP
    % nActions      = number of actions 
    
    tic;
    
    if restricted == 0
        restricted = 'un_';
    else
        restricted = num2str(restricted);
    end

    % count the scrambled MLE files in the experiment folder
    folder_path = ['../results/gradient_descent/',restricted,'restricted/',algorithm,'/scrambled/'];
    D = dir([folder_path, '/grad_desc_',num2str(CAP),'CAP_',num2str(nActions),'act_ur*.csv']);
    Num = length(D(not([D.isdir])));

    % cell array to keep all the MLE matrices
    MLESCRAMS = cell(Num,1);
    for i = 1:Num
        MLESCRAMS{i} = csvread([folder_path,D(i).name]);
        disp(D(i).name);
    end

    varlist = {'FolderName', 'D', 'i'};
    clear (varlist{:});
    clear varlist;
    disp('MLE_SCRAM_importer');
    toc

%     % OLD VERSION, before gradient descent and deterministic MLE
%     % script to import all the MLE files (20mins each approx by manual import)
%     % if the MLESCRAMS have been already imported use 0 as input and use a dummy for MLESCRAMS
%     
%     tic;
% 
%     % count the scrambled MLE files in the experiment folder
%     FolderName = '../results/MLE_scram_matlab/';
%     D = dir([FolderName, '/MLE_*.csv']);
%     Num = length(D(not([D.isdir])));
% 
% 
%     % cell array to keep all the MLE matrices
%     MLESCRAMS = cell(Num,1);
% 
%     % goes through scrams only if the input flag is true
%     if scram_flag
%         % Import each file in the experiment directory in the MLESCRAMS cell array
%         for i = 1:Num
%             MLESCRAMS{i} = csvread([FolderName,D(i).name]);
%             disp(D(i).name);
% 
%         end
%     end
% 
%     varlist = {'FolderName', 'D', 'i'};
%     clear (varlist{:});
%     clear varlist;
%     disp('MLE_SCRAM_importer');
%     toc
end