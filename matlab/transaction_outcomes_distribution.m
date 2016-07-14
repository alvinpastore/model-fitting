%transaction_outcomes = csvread('../data/player_transaction_outcomes.csv');
close all

[rows,cols] = size(playertransactionoutcomes(:,2:end)); 

to = reshape(playertransactionoutcomes(:,2:end),rows*cols,1);

subplot(2,1,1)
hist(to,1000);
title('Transaction outcome distribution');
xlabel('Profit per transaction (£)')
ylabel('Frequency') 
set(gca,'FontSize',20);

subplot(2,1,2)
hist(to,100);
title('Transaction outcome distribution');
xlabel('Profit per transaction (£)')
ylabel('Frequency') 
set(gca,'FontSize',20);

players_performances = zeros(1,46);
for i=1:46
    tmp = playertransactionoutcomes(i,:);
    players_performances(i) = sum(tmp(~isnan(tmp)));
end

figure
hist(players_performances,100);