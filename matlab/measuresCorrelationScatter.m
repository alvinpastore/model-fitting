results = untitled;
players = unique(results(:,1));

playersAmount = size(players,1);
fig = figure(1);
for playerID = 0:playersAmount-1
    
    % search for playerID lines (for starts from 1 while playersid start from 0)
    player_lines            = find(results(:,1) == playerID); 

    % retrieve for playerID results
    player_subresults       = results(player_lines,5:6);            

    MLEordered_subresults   = sortrows(player_subresults,1);

    x = MLEordered_subresults(:,1);  %MLE as the independent variable
    y = MLEordered_subresults(:,2);  %prec as the dependent variable
    
    p = polyfit(x,y,1);
    
    pp = polyval(p,x);



    scatter(x,y);
    hold on
    plot(x,pp,'-r');
    hold off
    avgprec = mean(y);
    maxprec = max(y);
    title(['Player: ',num2str(playerID), ', Avg Prec: ',num2str(avgprec),', Max Prec: ',num2str(maxprec)]);
    xlabel('MLE')
    ylabel('Precision')
    legend('Scatter','Regression','Location','NorthWest')


    %caxis([min(player_subresults_plot),max(player_subresults_plot)]);
    %colorbar
    fileName = ['graphs_correlation_MLE_Prec\g-',num2str(playerID),'.eps'];
    print(fig,'-depsc',fileName)
    clear  title xlabel ylabel;
    
end
