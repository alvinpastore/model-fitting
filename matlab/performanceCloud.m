%players = sort(performances(:,1));
plAmount = size(perfs(:,1),1);
best_prec = zeros(plAmount,1);
for pid = 0:plAmount-1
    pl_lines = find(res_model(:,1)==pid);
    best_prec(pid+1) = max(res_model(pl_lines,6));
end

sorted_perfs = sortrows(perfs,1);
x = sorted_perfs(:,2);
y = best_prec;
labels = num2str(sorted_perfs(:,1));

fig = figure(1);
hold on

scatter(x, y, 'bx');
plot(0:0.01:250,1/3,'-r');

dx = 0.1;
dy = 0.007;

t = text(x + dx, y+dy ,labels,'FontSize',5);

axis([50 220 0.25 0.75]);
title('Performance VS Fitness');
ylabel('Precision')
xlabel('Player Performance')
hold off

fileName = 'graphs_prec_vs_performance\scatter_prec_VS_performance.eps';
print(fig,'-depsc',fileName)