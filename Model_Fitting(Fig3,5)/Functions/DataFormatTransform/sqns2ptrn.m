function [ptrnT, ptrnR, ID, trlID] = sqns2ptrn(t, r, N, orientation)

% convert the original sequence of targets and responses into
% relatvie-position patterns

% Format
% t: sequences of targets
% r: sequenses of responses, corresponding to each targets in the same row
% N: total number of items
% orientation: 1: orientation considered (define pattern with clockwise)
%              0: no orientation considered

setsize = size(t, 2);

T = WoR(setsize, N);
deltaT = T(:, 2:end) - T(:, 1);
[~, ~, id0] = unique(mod(deltaT, N), 'row');
if orientation == 1
    ID = id0;
elseif orientation == 0
    [~, ~, id1] = unique(mod( - deltaT, N), 'row');
    [~, ~, ID] = unique(sort([id0, id1], 2), 'row');
end

[~, trlID] = ismember(t, T, 'row');
ptrnT = T(ID(trlID), :);

B = mod(ptrnT - t, N);
A = 2.*(max(B, [], 2) == min(B, [], 2)) - 1;
ptrnR = mod(A.*(r - t) + ptrnT, N);
ptrnR(ptrnR == 0) = N;

end