for i = 1: length(mle)
    figure(i);
    hist(mle(i,:));
    %axis([0 50 0 600]);
    disp(i);
end