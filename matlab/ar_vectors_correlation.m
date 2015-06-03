players = unique(arvectors(:,1));
playersAmount = size(players,1);

correlations = zeros(playersAmount,3);

for playerID = 0:playersAmount-1
    %disp(playerID);
    player_lines = find(arvectors(:,1) == playerID); 
    risk_vector = arvectors(player_lines,2);
    reward_vector = arvectors(player_lines,3);
    [r,p] = corrcoef(risk_vector , reward_vector);
    R = r(1,2);
    P = p(1,2);
    
    correlations(playerID+1,:)  = [playerID R P];
    
    % interesting p-values
    if p(1,2) < 0.06
        disp(playerID);
        % sort vectors according to riskiness, keep association across rewards
        p = polyfit(risk_vector,reward_vector,1);
        pp = polyval(p,risk_vector); 
        
        figure();
        hold on
        
        scatter(risk_vector, reward_vector, 'rx');
        plot(risk_vector,pp,'-b');
        
        title(['Player: ',num2str(playerID)]);
        xlabel('Risk')
        ylabel('Reward')
        legend('Scatter','Regression','Location','NorthWest')
        hold off
        
        fileName = ['graphs_correlation_risk_reward\g-',num2str(playerID),'.png'];
        print(gcf, '-dpng', fileName)
    end
    
end
