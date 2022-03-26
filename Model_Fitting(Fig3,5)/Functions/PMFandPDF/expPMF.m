function y = expPMF(setsize, lambda)
%expPMF for Order's Distribution

n = linspace(0, 1, setsize + 1);

x = repmat(n', 1, setsize);
mode = repmat(n(2:end) - 0.5.*n(2), setsize + 1, 1);

y = 0.5 + 0.5 .* sign(x - mode) .* (1 - exp(- lambda.*abs(x - mode)));
y = y(2:end, :) - y(1:end-1, :);

% y = y./diag(y)'; 
y = y./y(1, 1); 

end

