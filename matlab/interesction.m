

ACTIONS_AMOUNT = 5;


% get list of players from model results
players = unique(res_model(:,1));
playersAmount = size(players,1);

% store random model precision
p_random = 1/ACTIONS_AMOUNT;

best_players = zeros(playersAmount, 8);

%better than Dumb Players
for playerID = 0:playersAmount-1
    player_line = playerID + 1;
    % search for player best model precision
    p_model_lines = find(res_model(:,1) == playerID); 
    p_model_best  = max(res_model(p_model_lines,6));
    
    disp([num2str(playerID),'  ', num2str(p_model_best)])
    
    if p_model_best > p_random
        if sum(p_model_best > dumbplayers(player_line, 2:6)) >= ACTIONS_AMOUNT
            
            rnd_comp = ((p_model_best-p_random)/p_random)*100;
            d1_comp = ((p_model_best-dumbplayers(player_line, 2))/dumbplayers(player_line, 2))*100;
            d2_comp = ((p_model_best-dumbplayers(player_line, 3))/dumbplayers(player_line, 3))*100;
            d3_comp = ((p_model_best-dumbplayers(player_line, 4))/dumbplayers(player_line, 4))*100;
            d4_comp = ((p_model_best-dumbplayers(player_line, 5))/dumbplayers(player_line, 5))*100;
            d5_comp = ((p_model_best-dumbplayers(player_line, 6))/dumbplayers(player_line, 6))*100;
            
            best_players(playerID,:) = [playerID p_model_best rnd_comp d1_comp d2_comp d3_comp d4_comp d5_comp];
            
        end
    end
end

% get rid of all void lines (players not in the intersection)
best_players = best_players(best_players(:,1) > 0 ,:);

% if comparison value is inf reduce to the highest, non inf, value + 100 
%best_players(isinf(best_players)) = max(best_players(best_players < inf)) + 100;
[ii,jj] = find(isinf(best_players));
best_players(isinf(best_players)) = mean(best_players((~isinf(best_players(:,jj))),jj)); 


% round to keep only 3 decimal digits
best_players = round(best_players,3); format long g

% halve the comparisons above 1000 (to squeeze the graph)
%best_players = best_players ./ ((best_players > 1000) + 1);


%%--- --- --- FIGURE --- --- ---

hold on

title('Intersection: players who perform better than other models','FontSize', 24);

bar_handle = bar(best_players(:,3:end),'grouped');
%alpha(0.5);

axis([0 9 0 (max(best_players(best_players < inf))/2)]);

dark_grey_blue = [0.3,0.5,0.5];
light_purple = [0.4,0.4,0.7];
violet = [0.7,0.4,1];
bright_yellow = [1,0.9,0];
azure = [0,0.5,0.7];
redd = [0.8,0.2,0.2];

set(bar_handle(1),'FaceColor',redd)
set(bar_handle(2),'FaceColor',bright_yellow)
set(bar_handle(3),'FaceColor',azure)
set(bar_handle(4),'FaceColor',dark_grey_blue)
set(bar_handle(5),'FaceColor',light_purple)
set(bar_handle(6),'FaceColor',violet)

%% XTICKLABELS
xlabels = best_players(:,1);
%zlabels = {'Random';'DP1';'DP2';'DP3';'DP4';'DP5'};
set(gca,'XTick', 1:8, 'XtickLabel',xlabels,'FontSize',18);
%set(gca, 'XTick', 1:6, 'XTickLabel', xlabels);

%% LEGEND
l{1}='Random'; l{2}='Dumb Player 1'; l{3}='Dumb Player 2'; l{4}='Dumb Player 3'; l{5}='Dumb Player 4'; l{6}='Dumb Player 5'; 
hLegend = legend(bar_handle,l);
set(hLegend,'FontSize',20);

%% LABELS
%xlabel('Comparison model');
xlabel('Players IDs','FontSize',18);
ylabel('Improvement (% beteter than alternative model)','FontSize',18);

%% Caption in a box
%S = {'Averages:'; 'avg1'; 'avg2'};
%annotation('textbox', [0.1,0.7,0.1,0.1],...
%           'String', S);

       
%% 4 mesh (one for each comparison: rnd, dp1, dp2, dp3)
%[X,Y] = meshgrid(.5:.2:4.5, 0:.2:9);
%Z = 200.* ones(size(X,1),size(Y,2));
%hSurface = surf(X,Y,Z);
%hMesh = mesh(X,Y,Z)
%hSurf = surf(X,Y,Z,'EdgeColor','none','LineStyle','none','FaceLighting','phong');
%alpha(0.5);
%set(hSurface,'FaceColor',[1 0 0],'FaceAlpha',0.5);
%plot([0 9],[mean(best_players(:,3)) mean(best_players(:,3))] ,'Color', redd,'LineWidth',2);
%plot([0 9],[mean(best_players(:,4)) mean(best_players(:,4))] ,'Color', bright_yellow, 'LineWidth',2);
%plot([0 9],[mean(best_players(:,5)) mean(best_players(:,5))] ,'Color', azure, 'LineWidth',2);
%plot([0 9],[mean(best_players(:,6)) mean(best_players(:,6))] ,'Color', dark_grey_blue,'LineWidth',2);
%plot([0 9],[mean(best_players(:,7)) mean(best_players(:,7))] ,'Color', light_purple,'LineWidth',2);
%plot([0 9],[mean(best_players(:,8)) mean(best_players(:,8))] ,'Color', violet,'LineWidth',2);
hold off