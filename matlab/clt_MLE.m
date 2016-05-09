% creates a histogram for each line in MLE files 
% plotting the distribution of the MLEs
% this was used to investigate the distribution of MLEs (Central Limit Theorem) 

mle = csvread('results/MLE_model/MLE_Portfolio_[0.01, 0.25, 0.5, 0.75, 0.999]_1000_u.csv');
%mle = csvread('results/MLE_model/MLE_ModelBased_[0.01, 0.25, 0.5, 0.75, 0.999]_1000_u.csv');

for i = 1: length(mle)
    figure(i);
    mles = mle(i,5:); % skips columns 1-4 (PID and parameters) 
    hist(mles);
    %axis([0 50 0 600]);
    disp(i);
end
