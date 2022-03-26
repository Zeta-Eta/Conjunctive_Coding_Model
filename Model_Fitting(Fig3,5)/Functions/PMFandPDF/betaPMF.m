function y = betaPMF(setsize, lambda)
%betaPMF for Order's Distribution

n = linspace(0, 1, setsize + 1);

x = repmat(n', 1, setsize);
mode = repmat(n(2:end) - 0.5.*n(2), setsize + 1, 1);

SK = (1 - 2.*mode).*(lambda - 1);

alpha = lambda - SK;
beta = lambda + SK;

y = betacdf(x, alpha, beta);
y = y(2:end, :) - y(1:end-1, :);

y = y./diag(y)'; 

end

