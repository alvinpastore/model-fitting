% %% IMAGESC MODE
close all;
scram = rot90(scram_table);
fig_scram = figure();
hold on;
[h,w] = size(scram);                         %# Get the matrix size
imagesc((1:w)+0.5,flip((1:h)+0.5),scram);    %# Plot the image
colormap(gray);                              %# Use a gray colormap
axis equal                                   %# Make axes grid sizes equal
set(gca,'XTick',0.5:5:(w+1),'YTick',0.4:5:(h+1),...  %# Change some axes properties
        'XLim',[1 w+1],'YLim',[1 h+1],...
        'XTickLabel',[1,5,10,15,20,25,30,35,40,45],...
        'YTickLabel',[1,5,10]);

grid off;

% horizontal gridlines
for i = 0:size(scram,1)  
    disp(i);
    plot(1:w+1,ones(w+1,1)+i,'k-');
end

% vertical gridlines
for i = 0:size(scram,2)+1
    disp(i);
    plot(zeros(h+1,1)+i,1:h+1,'k-')
end

ylabel('Scrambled bins','FontSize',25);
xlabel('Players','FontSize',25);
set(gca,'FontSize',20);
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 40 17]); 
shading flat
%saveas(gcf,['graphs/paper/scram_table.pdf']);
print(gcf, '-depsc2', '-loose', 'graphs/paper/scram_table_loose'); % Print the figure in eps (first option) and uncropped (second object)
%print(gcf, '-dpdf', '-loose', 'graphs/paper/scram_table_loose_pdf'); % Print the figure in eps (first option) and uncropped (second object)

%writeFig300ppi(gcf, 'graphs/paper/scram_table_loose_300');

% %% PIXEL MODE
% 
% imshow(scram_table);
% 
% h = findobj(gcf,'type','image');
% 
% xdata = get(h, 'XData')
% 
% ydata = get(h, 'YData')
% 
% M = size(get(h,'CData'), 1);
% N = size(get(h,'CData'), 2);
% 
% if M > 1
%     pixel_height = diff(ydata) / (M-1);
% else
%     % Special case. Assume unit height.
%     pixel_height = 1;
% end
% 
% if N > 1
%     pixel_width = diff(xdata) / (N-1);
% else
%     % Special case. Assume unit width.
%     pixel_width = 1;
% end
% 
% y_top = ydata(1) - (pixel_height/2);
% y_bottom = ydata(2) + (pixel_height/2);
% y = linspace(y_top, y_bottom, M+1)
% 
% x_left = xdata(1) - (pixel_width/2);
% x_right = xdata(2) + (pixel_width/2);
% x = linspace(x_left, x_right, N+1)
% 
% dark = [.3 .3 .3];
% light = [.8 .8 .8];
% h = imshow(scram_table, 'InitialMagnification', 'fit');
% ax = ancestor(h, 'axes');
% line('Parent', ax, 'XData', xh, 'YData', yh, ...
%     'Color', dark, 'LineStyle', '-', 'Clipping', 'off');
% line('Parent', ax, 'XData', xh, 'YData', yh, ...
%     'Color', light, 'LineStyle', '-', 'Clipping', 'off');
% line('Parent', ax, 'XData', xv, 'YData', yv, ...
%     'Color', dark, 'LineStyle', '-', 'Clipping', 'off');
% line('Parent', ax, 'XData', xv, 'YData', yv, ...
%     'Color', light, 'LineStyle', '-', 'Clipping', 'off');