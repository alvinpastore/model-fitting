%%% NEW VERSION %%%

models = [3];

alphas = [];
betas  = [];
gammas = [];
best_amount = 15;

for i = models
    current_results = ['resnew',num2str(i)];
    model = eval(current_results);
    players = unique(model(:,1));
    
    for playerID = players.'
              
        % select each players subresults
        subresults = model(find(model(:,1) == playerID),:);

        random_MLE = subresults(1,5);
        
        % sort the results according to MLE
        subresults = sortrows(subresults,5);

        % rearrange in descending order 
        % NOT NEEDED (LEGACY FROM Precision measure)
        %subresults = flipdim(subresults,1);

        % select best 15 models
        best  = subresults(1:best_amount,:);
        
        % add frequencies to big param lists
        for a = best(:,2).'
            alphas(end+1) = a;
        end

        for b = best(:,3).'
            betas(end+1) = b;
        end

        for g = best(:,4).'
            gammas(end+1) = g;
        end

    end
    
end




%%
figa = figure(1);
[a1,a2] = hist(alphas,unique(alphas));
frequencies = a1./sum(a1); %relative frequency (%)
bar(1:1:length(a1),frequencies);
axis([0 length(a1)+1 0 0.7]);
set(gca,'Xticklabel',a2);
set(gca,'YTick',0:0.1:0.7);
set(gca,'Yticklabel',0:10:70);
title('Alpha frequency');
ylabel('Frequency')
xlabel('Alpha')
set(gca,'FontSize',20);

%%
figb = figure(2);
[b1,b2] = hist(betas,unique(betas));
frequencies = b1./sum(b1); %relative frequency (%)
bar(1:1:length(b1),frequencies);
axis([0 length(b1)+1 0 0.7]);
set(gca,'Xticklabel',b2);
set(gca,'YTick',0:0.1:0.7);
set(gca,'Yticklabel',0:10:70);
title('Beta frequency');
ylabel('Frequency')
xlabel('Beta')
set(gca,'FontSize',20);

%%
figc = figure(3);
[g1,g2] = hist(gammas,unique(gammas));
frequencies = g1./sum(g1); %relative frequency (%)
bar(1:1:length(g1),frequencies);
axis([0 length(g1)+1 0 0.7]);
set(gca,'Xticklabel',b2);
set(gca,'YTick',0:0.1:0.7);
set(gca,'YTickLabel',0:10:70);
title('Gamma frequency');
ylabel('Frequency')
xlabel('Gamma')
set(gca,'FontSize',20);

%%
%%% OLD VERSION
%{

%better than random lines
btr_lines = find(res_model(:,6) > 0.5);

alphas = res_model(btr_lines,2);
betas  = res_model(btr_lines,3);
gammas = res_model(btr_lines,4);

figa = figure(1);
hist(alphas);
%[N,X] =   bar(X,N,0.25)
axis([0 1 0 250])
title('Alpha frequency (threshold = 0.5)');
ylabel('Frequency')
xlabel('Alpha')
set(gca,'XTick',[0.1 0.25 0.5 0.75 1])
fileName = 'graphs_param_freq\alpha-5.eps';
print(figa,'-depsc',fileName)
    
figb = figure(2);
hist(betas);
title('Beta frequency (threshold = 0.5)');
ylabel('Frequency')
xlabel('Beta')
set(gca,'XTick',[0.01 5 10 12])
fileName = 'graphs_param_freq\beta-5.eps';
print(figb,'-depsc',fileName)
    

figc = figure(3);
hist(gammas);
axis([0 1 0 360])
title('Gamma frequency (threshold = 0.5)');
ylabel('Frequency')
xlabel('Gamma')
set(gca,'XTick',[0.1 0.25 0.5 0.75 0.8 0.999])
fileName = 'graphs_param_freq\gamma-5.eps';
print(figc,'-depsc',fileName)
%}
%%%
    