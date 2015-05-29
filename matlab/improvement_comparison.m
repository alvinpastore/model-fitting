
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


% get rid of all void lines (players not in the intersection)

performances = performances(~cellfun('isempty',performances)); 

plot_perf = [];
for k = 1:length(performances)
    plot_perf = [plot_perf, performances{k}(:,3)];
end
plot_perf(:,5) = 0:size(plot_perf,1)-1;

%% Unsorted
%figure();
%bar3(plot_perf);
%alpha(0.5);
%zlim([min(min(plot_perf))-10, max(max(plot_perf))+10]);
%axis([0 5 0 47]);

%% Sorted
% sort according to the improvement of the model in column 
%1 res10
%2 res3
%3 res4
%4 res5
MODEL_ORDER_CRITERION = 1;
sorted_performances = sortrows(plot_perf,MODEL_ORDER_CRITERION);

% A(:,[i,j])=A(:,[j,i]);
% swap column 5 and 3 so the order is descending. works only for 10-5-4-3
sorted_performances(:,[2,4]) = sorted_performances(:,[4,2]);
sorted_performances = fliplr(flipud(sorted_performances));

figure(1);
handle = gca(1);

bar_handle = bar3(sorted_performances(:,2:end));

alpha(0.4);

dark_grey_blue = [0.3,0.5,0.5];
light_purple = [0.4,0.4,0.7];
violet = [0.7,0.4,1];
bright_yellow = [1,0.9,0];
azure = [0,0.5,0.7];
redd = [0.8,0.2,0.2];

set(bar_handle(1),'FaceColor',redd)
set(bar_handle(2),'FaceColor',bright_yellow)
set(bar_handle(3),'FaceColor',azure)
set(bar_handle(4),'FaceColor',violet)

axis([0 5 0 47 min(min(plot_perf))-10, max(max(plot_perf))+10]);
%zlim([min(min(plot_perf))-10, max(max(plot_perf))+10]);

%set(gca,'Ytick',1:46);
%set(gca,'YtickLabel',sorted_performances(:,1),'FontSize',18);
set(gca,'YTick',[]);
set(gca,'XTick',[]);


ylab = ylabel('Players','FontSize',25);
zlab = zlabel('% Improvement','FontSize',25);

l{1}=' 10 Actions'; l{2}=' 5 Actions'; l{3}=' 4 Actions'; l{4}=' 3 Actions'; 
hLegend = legend(bar_handle,l,'Location',[0.7 0.5 0 0]);
set(hLegend,'FontSize',24);

%set(handle,'FontName','Hiragino Kaku Gothic Pro');

writePDF1000ppi(gcf, 'prova');

toc
