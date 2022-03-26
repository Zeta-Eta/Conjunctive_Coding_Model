function B = WoR(order, item)
% Without Replacement

A = nchoosek(1:item, order);
B = arrayfun(@(k)perms(A(k,:)), (1:size(A,1))', 'UniformOutput', false);
B = unique(cell2mat(B), 'row');

end