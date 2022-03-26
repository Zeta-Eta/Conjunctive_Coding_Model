function [UXid, UXidN, UX] = X2uniqueX(X)

[UXid, ~, UX] = unique(X);
UX = reshape(UX, size(X));
UXidN = size(UXid, 1);

end

