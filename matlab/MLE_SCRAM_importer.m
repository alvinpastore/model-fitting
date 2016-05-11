function [Num, MLESCRAMS] = MLE_SCRAM_importer(scram_flag)

    % script to import all the MLE files (20mins each approx by manual import)
    % if the MLESCRAMS have been already imported use 0 as input and use a dummy for MLESCRAMS
    
    tic;

    % count the scrambled MLE files in the experiment folder
    FolderName = '../results/MLE_scram_matlab/';
    D = dir([FolderName, '/MLE_*.csv']);
    Num = length(D(not([D.isdir])));


    % cell array to keep all the MLE matrices
    MLESCRAMS = cell(Num,1);

    % goes through scrams only if the input flag is true
    if scram_flag
        % Import each file in the experiment directory in the MLESCRAMS cell array
        for i = 1:Num
            MLESCRAMS{i} = csvread([FolderName,D(i).name]);
            disp(D(i).name);

        end
    end

    varlist = {'FolderName', 'D', 'i'};
    clear (varlist{:});
    clear varlist;
    disp('MLE_SCRAM_importer');
    toc
end