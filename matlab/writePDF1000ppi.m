    
            %% Print an image in PDF with 1000ppi with white background
            
function writePDF1000ppi(figNo, fileName)



%make the backgroung white
set(figNo,'color','w');

%get figure size
set(gca,'units','centimeters');
op = get(gca,'OuterPosition');

%create a page the same size as the figure
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [op(3) op(4)]);

%locate the figure in the page
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 op(3) op(4)]);

%print in PDF with resolution of 600ppi
print(gcf, '-dpdf', '-r600', fileName)