function y = wrapnPDF(theta, mu, kappa, n)
% Wrapped Normal Distribution
%

% old version
% for k = - n:n
% y = y + exp(- lambda.*(theta - mu + 2*pi*k).^2);
% end

k = reshape(-n:n, 1, 1, []);
y = sum(exp(- kappa.*(theta - mu + 2*pi*k).^2), 3);

y = y./sum(exp(- kappa.*(2*pi*k).^2), 3); 

end

