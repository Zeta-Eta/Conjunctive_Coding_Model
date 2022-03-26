function patternSet = PatternSetting(data, Experiment)

setsize = Experiment.setsize;
N = Experiment.N;

%% Pattern Generation

orientation = 0; % 1: orientation considered; 0: no orientation considered

[ptrnT, ptrnR] = sqns2ptrn(data.targets, data.responses, N, orientation);
targets = unique(ptrnT, 'rows'); % all possible patterns
patternN = size(targets, 1);

originalData = cell(patternN, 1); % original info for each pattern
RespMatrix = zeros(Experiment.setsize, Experiment.N, patternN); % output distribution for all trials
proportion = zeros(1, patternN);

for p = 1:patternN
    
    ptrnRespTypesIdx = find(ismember(ptrnT, targets(p, :), 'rows'));
    originalData{p} = data(unique(ptrnRespTypesIdx), :);
    proportion(p) = size(originalData{p}, 1);
    
    tempResps = ptrnR(ptrnRespTypesIdx, :);
    for order = 1: Experiment.setsize
        for trial = 1:size(tempResps, 1)
            item = tempResps(trial, order);
            if ~isnan(item)
                RespMatrix(order, item, p) = RespMatrix(order, item, p) + 1;
            end
        end
    end
    RespMatrix(:, :, p) = RespMatrix(:, :, p)./sum(RespMatrix(:, :, p), 2);
end

patternSet = struct;
patternSet.patternN = patternN;
patternSet.orientation = orientation;
patternSet.targets = targets;
patternSet.responses = RespMatrix;
patternSet.originalData = originalData;
patternSet.proportion = proportion./sum(proportion);
%% Reaction Time & Accuracy

% eval('[u, ~, uid] = unique(data.group);');
[u, ~, uid] = unique(data.group);
ACCptp = cell(size(u, 1), 1);
ACCptpOrder = cell(size(u, 1), Experiment.setsize);
RTptp = cell(size(u, 1), Experiment.setsize);
for i = 1:size(u, 1)
    ACCptp{i} = all(data.targets(uid == i, :) == data.responses(uid == i, :), 2);
    for o = 1:Experiment.setsize
        ACCptpOrder{i, o} = data.targets(uid == i, o) == data.responses(uid == i, o);
        RTptp{i, o} = data.RT(uid == i, o);
    end
end
ACCptp = cellfun(@(x) mean(x), ACCptp);
ACCptpOrder = cellfun(@(x) mean(x), ACCptpOrder);
RTptp = cellfun(@(x) mean(x), RTptp);

patternSet.ptp = u;
patternSet.ptpID = uid;
patternSet.ACCptp = ACCptp;
patternSet.ACCptpOrder = ACCptpOrder;
patternSet.RTptp = RTptp;
patternSet.RT = data.RT;

%% Distributions of Response Types

allRespTypes = WoR(Experiment.setsize, Experiment.N);
RespTypesPMF = zeros(size(allRespTypes, 1), patternN);
RTpattern = zeros(patternN, Experiment.setsize);

for p = 1:patternN
    
    tempPtrn = patternSet.originalData{p};
    
    RTpattern(p, :) = mean(tempPtrn.RT, 1);
    
    [~, tempPtrnR] = sqns2ptrn(tempPtrn.targets, tempPtrn.responses, N, orientation);
    
    RespTypes = unique(tempPtrnR, 'rows');
    countResp = [];
    for resp = 1:size(RespTypes, 1)
        
        countResp = [countResp; sum(ismember(tempPtrnR, RespTypes(resp, :), 'rows'))];
        
    end
    countResp = countResp./sum(countResp);
    
    RespTypesPMF(ismember(allRespTypes, RespTypes, 'rows'), p) = countResp;
    
end

patternSet.RespTypesPMF = RespTypesPMF;
patternSet.allRespTypes = allRespTypes;
patternSet.RTpattern = RTpattern;

%% Calculate the Dot Products of the Vectors between the Target Dots
if 0
    Vector(:, :, 1) = cos(2*pi*(1 - targets(:, 2:end)/N)) - cos(2*pi*(1 - targets(:, 1:end-1)/N));
    Vector(:, :, 2) = sin(2*pi*(1 - targets(:, 2:end)/N)) - sin(2*pi*(1 - targets(:, 1:end-1)/N));
    
    DP = zeros(patternN, setsize - 1);
    for o = 1:setsize - 1
        DP(:, o) = sum(Vector(:, o, :).*Vector(:, o + 1 - o*(o + 1 == setsize), :), 3);
    end
    
    patternSet.DP = DP;
end
%% Calculate the Path Length & Path Cross

Trad = targets.*2.*pi./N;
vctLen = abs(exp(1i.*Trad(:, 2:end)) - exp(1i.*Trad(:, 1:end - 1)));

pathCrs = zeros(patternN, 1);
allCrs = nchoosek(1:setsize - 1, 2);
for p = 1:patternN
    tempTrad = Trad(p, :);
    vctX = [cos(tempTrad); sin(tempTrad)];
    tNum = 0;
    for nCrs = 1:size(allCrs, 1)
        ta = allCrs(nCrs, 1);
        tb = allCrs(nCrs, 2);
        tNum = isCrs(vctX(:, ta:ta+1), vctX(:, tb:tb+1)) + tNum;
    end
    pathCrs(p) = tNum;
end


pathLen = sum(vctLen, 2);
patternSet.vctLen = vctLen;
patternSet.pathLen = pathLen;
patternSet.pathCrs = pathCrs;

[patternSet.UpathC, patternSet.UpathCN, patternSet.UpathCid] = X2uniqueX(pathCrs);

%% Calculate the Chunk Distraction
ckRespTypes = cell(setsize, 1);
for ckNum = 1:setsize
    ckRespTypes{ckNum} = WoR(ckNum, ckNum);
end

Dist = zeros(patternN, setsize + 1);  % sum with distance values
Dist(:, 2:setsize) = abs(targets(:, 2:setsize) - targets(:, (2:setsize) - 1));
Dist(Dist > N/2) = N - Dist(Dist > N/2);
Dist(Dist ~= 1) = 0;

ckNum = zeros(patternN, 1);
ck = cell(patternN, setsize);
ck2 = cell(patternN, setsize);
ckSize = zeros(patternN, setsize);
for p = 1:patternN
    tNum = 0;
    for slideNum = 1:setsize
        for ckSizeTemp = 1:setsize - slideNum + 1
            ckSample = [0, ones(1, ckSizeTemp - 1), 0];
            if isequal(Dist(p, slideNum:slideNum + ckSizeTemp), ckSample)
                tNum = tNum + 1;
                ck{p, tNum} = targets(p, slideNum:slideNum + ckSizeTemp - 1);
                ck2{p, tNum} = slideNum:slideNum + ckSizeTemp - 1;
                ckSize(p, slideNum:slideNum + ckSizeTemp - 1) = ckSizeTemp;
            end
        end
    end
    ckNum(p) = tNum;
end
ckItem = cellfun(@(x) mean(x), ck);
ckTarget = cellfun(@(x) mean(x), ck2);
ckLength = cellfun(@(x) length(x), ck2);

ck2RespTypes = cell(patternN, 1);
for p = 1:patternN
    ck2RespTypes{p} = reshape(cell2mat(ck2(p, ckRespTypes{ckNum(p)}')), setsize, [])';
end

patternSet.ck = ck;
patternSet.ck2 = ck2;
patternSet.ckNum = ckNum;

[patternSet.UckN, patternSet.UckNN, patternSet.UckNid] = X2uniqueX(ckNum);

patternSet.ckItem = ckItem;
patternSet.ckTarget = ckTarget;
patternSet.ckLength = ckLength;
patternSet.ckSize = ckSize;

[patternSet.UckS, patternSet.UckSN, patternSet.UckSid] = X2uniqueX(ckSize);

patternSet.ckRespTypes = ckRespTypes;
patternSet.ck2RespTypes = ck2RespTypes;

patternSet.complexity = table(ckNum, pathLen, pathCrs);

end

