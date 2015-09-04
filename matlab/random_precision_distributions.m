




for i = 1:size(CLTP3,1)
    disp(i);
    
    close all;
    
    fig_single = figure();
    v = CLTP3(i,:)./100;
    x = min(v):0.01:max(v);
    y = normpdf(x,1/3,std(v));
    
    hold on;
    title(['1k iterations, Player ', num2str(i-1)],'FontSize',28);
    
    hist(v,20);    
    plot(x,y.*(max(hist(v,20)) / max(y)));
    
    set(gca,'Xtick',0:0.1:0.8,'XTickLabel',0:10:80);
    xlab = xlabel('Precision (%)','FontSize',25);
    ylab = ylabel('Frequency','FontSize',25);
    set(gca,'FontSize',20);
    
    l{1}=' Random Precision histogram'; 
    l{2}=' Gaussian pdf'; 
    legend(l,'Location',[0.83 0.87 0 0],'FontSize',20);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 35 25]); 
    
    saveas(gcf,['graphs_CLT/player-',num2str(i-1),'.png']);
    hold off;
end

%fig_collective = figure();
%hist(CLTP3);