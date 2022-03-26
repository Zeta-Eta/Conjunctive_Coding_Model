function [ckAcc, ckErr, ckType, ckID] = Acc2ckAcc(Acc, dataSet, ErrBar)
% PMF to Order Accuracies
[ckType, ~, ckID] = unique(dataSet.ckLength, 'row');
ckTypeN = size(ckType, 1);
ckNum = sum(ckType ~= 0, 2);
[~, ckNumID] = sort(ckNum, 'descend');
ckType = ckType(ckNumID, :);

ckAcc = NaN(ckTypeN, 1);
ckErr = NaN(ckTypeN, 1);
for ckN = 1:ckTypeN
    idTemp = ckID == ckNumID(ckN);
    ckID(idTemp) = - ckN;
    
    prop = dataSet.proportion(idTemp);
    prop = prop./sum(prop);
    ckAcc(ckN) = prop*Acc(idTemp, :);
    if strcmp(ErrBar, 'SEM')
        ckErr(ckN) = std(Acc(idTemp, :), prop')./sqrt(sum(idTemp));% SEM
    else
        ckErr(ckN) = std(Acc(idTemp, :), prop'); % SD
    end
    
end

ckID = - ckID;