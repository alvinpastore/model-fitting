%% plot action probability against beta value for softmax action policy

% choose initial Q values
q = [1.2;0.9;0.6];

% choose beta range
betas = 0:0.01:30;

% generate softmax denominator for 3 actions
den = [sum(exp(q*betas)) ; sum(exp(q*betas)) ; sum(exp(q*betas))];

% calculate probabilities
ps = exp(q*betas)./den;

% figure
fig1 = figure();

plot(betas,ps(1,:),'-b','LineWidth',5)
hold on

plot(betas,ps(2,:),'-g','LineWidth',5)
hold on

plot(betas,ps(3,:),'-r','LineWidth',5)

set(gca,'FontSize',20)

axis([0 20 0 1])