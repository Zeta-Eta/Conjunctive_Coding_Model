function orderAcc = PMF2Acc(PMF, Targets, RespTypes)
% PMF to Order Accuracies
orderAcc = zeros(size(Targets));
for p = 1:size(orderAcc, 1)
    for o = 1:size(orderAcc, 2)
        orderAcc(p, o) = sum(PMF(RespTypes(:, o) == Targets(p, o), p));
    end
end

end

