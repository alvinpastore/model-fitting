results = untitled;
players = unique(results(:,1));
tmp = unique(results(:,2));
alpha = tmp(2:end,:);
tmp = unique(results(:,3));
beta = tmp(2:end,:);
%0.01:0.01:0.1;
alphasAmount = size(alpha,1);
betasAmount = size(beta,1);
playersAmount = size(players,1);
%unique(results(:,4));
%subPlotPosition = 1;
baseline = 1/3;
better_than_chance_lines = find(results(:,5) > baseline);
better_than_random = unique(results(better_than_chance_lines));

for playerID = 0:playersAmount-1
    player_lines            = find(results(:,1) == playerID);     % search for playerID lines (for starts from 1 while playersid start from 0)
    player_subresults       = results(player_lines,:);            % retrieve for playerID results
    %disp(playerID)

    randomMLE = player_subresults(1,4);
    player_subresults_plot       = player_subresults(2:end,4);
    
    %plot
    [x,y] = meshgrid(alpha,beta);
    g = reshape(player_subresults_plot,betasAmount,alphasAmount);
    r = zeros(betasAmount,alphasAmount)+randomMLE;
    
    %subplot(1,playersAmount,subPlotPosition) 
    %subPlotPosition = subPlotPosition + 1;
    fig = figure(1);
    surf(x, y, g)
    
    %hold on;
    %mesh(x, y, r)
    
    avgprec = mean(player_subresults(:,5));
    maxprec = max(player_subresults(:,5));
    actions = player_subresults(1,6);
    title(['Player: ',num2str(playerID),', Avg Prec: ',num2str(avgprec),', Max Prec: ',num2str(maxprec),', Actions: ',num2str(actions)]);
    xlabel('alpha')
    ylabel('beta')
    
    
    %axis([0,1,0,0.5,0,120])
    caxis([min(player_subresults_plot),max(player_subresults_plot)]);
    colorbar
    fileName = ['graphs_noGamma\g-',num2str(playerID),'.eps'];
    print(fig,'-depsc',fileName)
    clear title xlabel ylabel;
    if ismember(playerID,better_than_random)
        disp(['Player: ',num2str(playerID),', highest prec: ',num2str(max(player_subresults(:,5))),', Actions: ',num2str(actions)])
        
    end
    %hold off;
end
 