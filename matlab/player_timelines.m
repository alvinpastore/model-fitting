% produces graphs representing the timeline of the player interactions
% x axis is time in transactions discrete steps
% y axis is action risk in discrete bins 
% the bubble represent the actions (transactions)
% the color represent the outcome (red-loss, yellow-even, green-win)
% the size represent the size of the win/loss

DISCRETISED = 1;

risk_type = 'beta';
SAVE_FIG = 1;

yellow	=[1,1,0];
magenta	=[1,0,1];
cyan	=[0,1,1];
red     =[1,0,0];
green	=[0,1,0];
blue	=[0,0,1];
white	=[1,1,1];
black	=[0,0,0];

% load players actions-rewards vectors
arvectors = csvread(['../results/ar_vectors/ar_vectors_',risk_type,'.csv']);
players = unique(arvectors(:,1));
playersAmount = size(players,1);

% these thresholds come from the discretisation of the stocks 
% in 3 bins of risk using beta or risk
if strcmp(risk_type,'risk')
    lower_t = 0.0655;
    higher_t = 0.1655;
elseif strcmp(risk_type,'beta')
    lower_t = 0.86;
    higher_t = 1.10;
end

risk = arvectors(:,2);
if DISCRETISED
    for i = 1:length(arvectors(:,2))
        if arvectors(i,2) < lower_t
            risk(i,2) = 0;
        else
            if arvectors(i,2) < higher_t
                risk(i,2) = 1;
            else
                risk(i,2) = 2;
            end
        end

    end
end

for playerID = 0:playersAmount-1
    disp(playerID+1);
    
    player_lines = find(arvectors(:,1) == playerID); 
    risk_vector = risk(player_lines,2);
    reward_vector = arvectors(player_lines,3);
    
    figure();
    font_size = 20;
    hold on;
    set(gcf, 'Position', [200 200 1800 1000])
    
    scatter( 1:1:size(player_lines,1) , risk_vector, ...
    abs(reward_vector)*1500 , reward_vector,...
    'filled','MarkerEdgeColor',blue,...
    'LineWidth',2.5);  
    
    map = [red 
        yellow 
        green];
    
    colormap(map);
    %cmap = colormap;
    %cmap = flipud(cmap);
    %colormap(cmap);
    
    ch = colorbar('Ticks',[-0.8,0,0.8],'TickLabels',{'Loss','Even','Gain'});
    caxis([-1, 1]);
    ch.Label.String = 'Reward / Punishment';
    ch.FontSize = font_size;
    
    title(['Player: ',num2str(playerID+1)],'FontSize',font_size + 5);
    xlabel('Transaction','FontSize',font_size);
    ylabel('Risk','FontSize',font_size);
    %axis([0 (size(player_lines,1) + 3) -0.09 1]);
    if DISCRETISED
        axis([0 28 -1 3]);
        set(gca,'Ytick',0:2,'YTickLabel',{'Low', 'Mid', 'High'})
    else
        axis([0 28 -0.09 1]);
    end
    set(gca,'FontSize',font_size)
    hold off;

    if SAVE_FIG
        fileName = ['../graphs/graph_players_timelines/g-',num2str(playerID+1),'_',risk_type,'.png'];
        %print(gcf, '-dpng', fileName)
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0 0 27 21]); %x_width=10cm y_width=15cm
        saveas(gcf,fileName);
    end
    close(gcf);
end
