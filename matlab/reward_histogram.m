%syms u
%hist_rewards = histrew;
%x = hist_rewards(:,1);
%y = hist_rewards(:,2);
%sigma = 500;
%z = (1-exp(-u/sigma))/(1+exp(-u/sigma));
%zz =(1-exp(-u/1000))/(1+exp(-u/1000));

%fig = figure();
%hold on;
%a = ezplot(z,[-10000,80000]);
%b = ezplot(zz,[-10000,80000]);
%set(a,'color','r');
%set(a,'color','g');


%scatter(x,y,'xb');
%hold on;
%colormap('Jet');
%title('Reward distribution');
%xlabel('reward value')
%ylabel('frequency')

%legend('Hyperbolic tangent','Reward','Location','NorthEast')

%axis([-1000 1000 -5 5])

%hold off;

close all;
rews = playerstats25cap3act;


x = min(rews(:,1)):1000:max(rews(:,1));

sigma = 500;
y = (1-exp(-x./sigma))./(1+exp(-x./sigma));
yy = (1-exp(-x./10000))./(1+exp(-x./10000));

%zz =(1-exp(-u/1000))/(1+exp(-u/1000));

fig = figure(1);
hold on;
plot(x,y,'-r');
scatter(rews(:,1),rews(:,2), 'xb' );
%plot(x,yy,'-g');
%set(a,'color','r');
%set(a,'color','g');


%scatter(x,y,'xb');
hold on;
%colormap('Jet');
title('Reward distribution');
xlabel('htan sigma = 500')
ylabel('rewards')

%legend('Hyperbolic tangent','Reward','Location','NorthEast')

axis([min(rews(:,1)) max(rews(:,1)) -1.1 1.1])

hold off;


