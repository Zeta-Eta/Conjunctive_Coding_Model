function orderAcc = PMF2Acc4CP(PMF, Targets, RespTypes)
% PMF to Order Accuracies for Conditional Probability
orderAcc = zeros(size(Targets));
for p = 1:size(orderAcc, 1)
    orderAcc(p, 1) = sum(PMF(RespTypes(:, 1) == Targets(p, 1), p));
    for o = 2:size(orderAcc, 2)
        orderAcc(p, o) = sum(PMF(ismember(RespTypes(:, 1:o), Targets(p, 1:o), 'row'), p))./orderAcc(p, o-1);
    end
end

end