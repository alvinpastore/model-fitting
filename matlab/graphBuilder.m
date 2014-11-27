results = untitled;
players = unique(results(:,1));

tmp = unique(results(:,2));
alpha = tmp(2:end,:);
tmp = unique(results(:,3));
beta = tmp(2:end,:);
tmp = unique(results(:,4));
gamma = tmp(2:end,:);

alphasAmount  = size(alpha,1);
betasAmount   = size(beta,1);
gammasAmount  = size(gamma,1);
playersAmount = size(players,1);

baseline = 1/3;
better_than_chance_lines = find(results(:,6) > baseline);
better_than_random = unique(results(better_than_chance_lines));

for playerID = 0:playersAmount-1
    for bi = 1:betasAmount

        b = beta(bi);
        % search for playerID lines (for starts from 1 while playersid start from 0)
        player_lines            = find(results(:,1) == playerID); 

        % retrieve for playerID results
        player_subresults       = results(player_lines,:);            

        % retrieve beta lines
        player_sub_beta_lines   = find(player_subresults(:,3) == b);
        results_beta            = player_subresults(player_sub_beta_lines,:);
        
        randomMLE = player_subresults(1,5);
        player_subresults_plot  = results_beta(:,5);
        
        %plot
        [x,y] = meshgrid(alpha, gamma);
        g = reshape(player_subresults_plot, gammasAmount, alphasAmount);
        %%% r = zeros(gammasAmount,alphasAmount)+randomMLE; 

        fig = figure(1);
        surf(x, y, g)

        %%%hold on;
        %%%mesh(x, y, r)

        avgprec = mean(player_subresults(:,6));
        maxprec = max(player_subresults(:,6));
        transactions = player_subresults(1,7);
        title(['Player: ',num2str(playerID),', Beta: ',num2str(b),', Avg Prec: ',num2str(avgprec),', Max Prec: ',num2str(maxprec),', Actions: ',num2str(transactions)]);
        xlabel('alpha')
        ylabel('gamma')


        caxis([min(player_subresults_plot),max(player_subresults_plot)]);
        colorbar
        fileName = ['graphs_gamma\g-',num2str(playerID),'_b-',num2str(b),'.eps'];
        print(fig,'-depsc',fileName)
        clear title xlabel ylabel;
        if ismember(playerID,better_than_random)
            disp(['Player: ',num2str(playerID),', Beta: ',num2str(b),', highest prec: ',num2str(maxprec),', Actions: ',num2str(transactions)])

        end
        %%%hold off;
    end
end
