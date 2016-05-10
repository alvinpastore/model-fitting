% DEPRECATED
% calculate and plot the performance of a model against the corresponding random
% uses precision instead of Maximum Likelihood Estimate (deprecated)
% Explanation from Daw: there is a mismatch in the forward model prediction. 
% It is asking too much to fit the exploratory part of the learning
tic;


% get all the variables in the workspace
all_results = who;

% data structure to hold the performances of all the results available
performances = cell(length(who),1);
perf_idx = 1;

for i = 1:length(all_results)   
    
    current_results = all_results(i);
    current_results = current_results{1};
    
    % find results variables (resXX)
    if length(current_results) > 3 && strcmp(current_results(1:3),'res')
        disp(['Processing ', current_results]);

        % load model results
        model = eval(current_results);
        
        % count players
        players = unique(model(:,1));
        playersAmount = size(players,1);

        % initialise performances
        current_performances = zeros(playersAmount,3);
        
        % use the actions to calculate random precision
        ACTIONS_AMOUNT = str2double(current_results(4:end));
        
        p_random = 1/ACTIONS_AMOUNT;
        disp(['random precision: ' , num2str(p_random)]);
        
        
        % for every player calculate best model and compare with random
        for playerID = 0:playersAmount-1

            % search for player best model precision
            p_model_lines = find(model(:,1) == playerID); 
            p_model_best  = max(model(p_model_lines,6));

            % calculate improvement rates (over random model)
            improv_rate_random = ((p_model_best-p_random)/p_random)*100;

            % populate performances matrix
            current_performances(playerID+1,:) = [playerID p_model_best improv_rate_random];

        end
        performances{perf_idx} = current_performances;
        perf_idx = perf_idx + 1;
    end
    
end

% get rid of all void performances lines (instantiated in the beginning
% because of the collection of all the variables in the workspace)
performances = performances(~cellfun('isempty',performances)); 

% get only the improvement columns from the calculated performances
plot_perf = [];
for k = 1:length(performances)
    plot_perf = [plot_perf, performances{k}(:,3)];
end


% A(:,[i,j])=A(:,[j,i]);
% swap column for model 5 and model 3 so the order is descending. 
% works only for 10-3-4-5 -> 10-5-4-3
%plot_perf(:,[2,4]) = plot_perf(:,[4,2]);
%plot_perf = fliplr(flipud(plot_perf));

% general solution:
% 10,2,3  shifted of -1 (one to the left) according to cols becomes 2,3,10
plot_perf = circshift(plot_perf,-1,2);

% add ids as last column
plot_perf(:,size(plot_perf,2)+1) = 0:size(plot_perf,1)-1;

%% Unsorted
%figure();
%bar3(plot_perf);
%alpha(0.5);
%zlim([min(min(plot_perf))-10, max(max(plot_perf))+10]);
%axis([0 5 0 47]);

%% Sorted
% sort according to the improvement of the model in column 
% the higher the MOC the higher the actions in the model (ie 1 = 10actions)
% size(sorted_performances,2) means order by id
%MODEL_ORDER_CRITERION = size(plot_perf,2);
MODEL_ORDER_CRITERION = size(plot_perf,2)-1;
sorted_performances = sortrows(plot_perf,-MODEL_ORDER_CRITERION);

%sorted_performances = flipud(sorted_performances);

figure(1);
handle = gca(1);

bar_handle = bar3(sorted_performances(:,1:end-1));

alpha(0.4);

dark_grey_blue = [0.3,0.5,0.5];
light_purple = [0.4,0.4,0.7];
violet = [0.7,0.4,1];
bright_yellow = [1,0.9,0];
azure = [0,0.5,0.7];
redd = [0.8,0.2,0.2];

col = {redd; bright_yellow; azure; violet; dark_grey_blue; light_purple};

for handle_idx = 1:length(bar_handle)
    set(bar_handle(handle_idx),'FaceColor',col{handle_idx})
end


axis([0 size(sorted_performances,2) 0 47 min(min(plot_perf))-10, max(max(plot_perf))+10]);
%zlim([min(min(plot_perf))-10, max(max(plot_perf))+10]);

%set(gca,'Ytick',1:46);
%set(gca,'YtickLabel',sorted_performances(:,1),'FontSize',18);
set(gca,'YTick',[]);
set(gca,'XTick',[]);


ylab = ylabel('Players','FontSize',25);
zlab = zlabel('% Improvement','FontSize',25);

%l{1}=' 3 Actions'; l{2}=' 4 Actions'; l{3}=' 5 Actions'; l{4}=' 10 Actions'; 
%hLegend = legend(bar_handle,l,'Location',[0.7 0.5 0 0]);
%set(hLegend,'FontSize',24);

%set(handle,'FontName','Hiragino Kaku Gothic Pro');

%writePDF1000ppi(gcf, 'prova');

toc
