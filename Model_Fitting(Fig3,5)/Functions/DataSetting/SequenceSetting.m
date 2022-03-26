function sequenceSet = SequenceSetting(data, Experiment, theta)

setsize = Experiment.setsize;
N = Experiment.N;

%% Sequence Generation

orientation = 0; % 1: orientation considered; 0: no orientation considered

% targets = unique(sqnsT, 'rows');
targets = WoR(Experiment.setsize, Experiment.N); % all possible sequences

if theta ~= 0
    [~, sqnsID] = ismember(data.targets, targets, 'rows');
    tbl = tabulate(sqnsID);
    count = tbl(:, 2);
    
    data(ismember(data.targets, targets(count < theta, :), 'rows'), :) = [];
    targets(count < theta, :) = [];
end

sqnsT = data.targets;
sqnsR = data.responses;

sequenceN = size(targets, 1);

originalData = cell(sequenceN, 1); % original info for each sequence
RespMatrix = zeros(Experiment.setsize, Experiment.N, sequenceN); % output distribution for all trials
proportion = zeros(1, sequenceN);

for s = 1:sequenceN
    
    sqnsRespTypesIdx = find(ismember(sqnsT, targets(s, :), 'rows'));
    originalData{s} = data(unique(sqnsRespTypesIdx), :);
    proportion(s) = size(originalData{s}, 1);
    
    tempResps = sqnsR(sqnsRespTypesIdx, :);
    for order = 1: Experiment.setsize
        for trial = 1:size(tempResps, 1)
            item = tempResps(trial, order);
            if ~isnan(item)
                RespMatrix(order, item, s) = RespMatrix(order, item, s) + 1;
            end
        end
    end
    RespMatrix(:, :, s) = RespMatrix(:, :, s)./sum(RespMatrix(:, :, s), 2);
end

sequenceSet = struct;
sequenceSet.sequenceN = sequenceN;
sequenceSet.orientation = orientation;
sequenceSet.targets = targets;
sequenceSet.responses = RespMatrix;
sequenceSet.originalData = originalData;
sequenceSet.proportion = proportion./sum(proportion);
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

sequenceSet.ptp = u;
sequenceSet.ptpID = uid;
sequenceSet.ACCptp = ACCptp;
sequenceSet.ACCptpOrder = ACCptpOrder;
sequenceSet.RTptp = RTptp;
sequenceSet.RT = data.RT;

%% Distributions of Response Types

allRespTypes = WoR(Experiment.setsize, Experiment.N);
RespTypesPMF = zeros(size(allRespTypes, 1), sequenceN);
RTsequence = zeros(sequenceN, Experiment.setsize);

for s = 1:sequenceN
    
    tempSqns = sequenceSet.originalData{s};
    
    RTsequence(s, :) = mean(tempSqns.RT, 1);
    
    tempSqnsR = tempSqns.responses;
    
    RespTypes = unique(tempSqnsR, 'rows');
    countResp = [];
    for resp = 1:size(RespTypes, 1)
        
        countResp = [countResp; sum(ismember(tempSqnsR, RespTypes(resp, :), 'rows'))];
        
    end
    countResp = countResp./sum(countResp);
    
    RespTypesPMF(ismember(allRespTypes, RespTypes, 'rows'), s) = countResp;
    
end

sequenceSet.RespTypesPMF = RespTypesPMF;
sequenceSet.allRespTypes = allRespTypes;
sequenceSet.RTsequence = RTsequence;

%% Calculate the Dot Products of the Vectors between the Target Dots
if 0
    Vector(:, :, 1) = cos(2*pi*(1 - targets(:, 2:end)/N)) - cos(2*pi*(1 - targets(:, 1:end-1)/N));
    Vector(:, :, 2) = sin(2*pi*(1 - targets(:, 2:end)/N)) - sin(2*pi*(1 - targets(:, 1:end-1)/N));
    
    DP = zeros(sequenceN, setsize - 1);
    for o = 1:setsize - 1
        DP(:, o) = sum(Vector(:, o, :).*Vector(:, o + 1 - o*(o + 1 == setsize), :), 3);
    end
    
    sequenceSet.DP = DP;
end
%% Calculate the Path Length & Path Cross

Trad = targets.*2.*pi./N;
vctLen = abs(exp(1i.*Trad(:, 2:end)) - exp(1i.*Trad(:, 1:end - 1)));

pathCrs = zeros(sequenceN, 1);
allCrs = nchoosek(1:setsize - 1, 2);
for s = 1:sequenceN
    tempTrad = Trad(s, :);
    vctX = [cos(tempTrad); sin(tempTrad)];
    tNum = 0;
    for nCrs = 1:size(allCrs, 1)
        ta = allCrs(nCrs, 1);
        tb = allCrs(nCrs, 2);
        tNum = isCrs(vctX(:, ta:ta+1), vctX(:, tb:tb+1)) + tNum;
    end
    pathCrs(s) = tNum;
end


pathLen = sum(vctLen, 2);
sequenceSet.vctLen = vctLen;
sequenceSet.pathLen = pathLen;
sequenceSet.pathCrs = pathCrs;

[sequenceSet.UpathC, sequenceSet.UpathCN, sequenceSet.UpathCid] = X2uniqueX(pathCrs);

%% Calculate the Chunk Distraction
ckRespTypes = cell(setsize, 1);
for ckNum = 1:setsize
    ckRespTypes{ckNum} = WoR(ckNum, ckNum);
end

Dist = zeros(sequenceN, setsize + 1);  % sum with distance values
Dist(:, 2:setsize) = abs(targets(:, 2:setsize) - targets(:, (2:setsize) - 1));
Dist(Dist > N/2) = N - Dist(Dist > N/2);
Dist(Dist ~= 1) = 0;

ckNum = zeros(sequenceN, 1);
ck = cell(sequenceN, setsize);
ck2 = cell(sequenceN, setsize);
ckSize = zeros(sequenceN, setsize);
for s = 1:sequenceN
    tNum = 0;
    for slideNum = 1:setsize
        for ckSizeTemp = 1:setsize - slideNum + 1
            ckSample = [0, ones(1, ckSizeTemp - 1), 0];
            if isequal(Dist(s, slideNum:slideNum + ckSizeTemp), ckSample)
                tNum = tNum + 1;
                ck{s, tNum} = targets(s, slideNum:slideNum + ckSizeTemp - 1);
                ck2{s, tNum} = slideNum:slideNum + ckSizeTemp - 1;
                ckSize(s, slideNum:slideNum + ckSizeTemp - 1) = ckSizeTemp;
            end
        end
    end
    ckNum(s) = tNum;
end
ckItem = cellfun(@(x) mean(x), ck);
ckTarget = cellfun(@(x) mean(x), ck2);
ckLength = cellfun(@(x) length(x), ck2);

ck2RespTypes = cell(sequenceN, 1);
for s = 1:sequenceN
    ck2RespTypes{s} = reshape(cell2mat(ck2(s, ckRespTypes{ckNum(s)}')), setsize, [])';
end

sequenceSet.ck = ck;
sequenceSet.ck2 = ck2;
sequenceSet.ckNum = ckNum;

[sequenceSet.UckN, sequenceSet.UckNN, sequenceSet.UckNid] = X2uniqueX(ckNum);

sequenceSet.ckItem = ckItem;
sequenceSet.ckTarget = ckTarget;
sequenceSet.ckLength = ckLength;
sequenceSet.ckSize = ckSize;

[sequenceSet.UckS, sequenceSet.UckSN, sequenceSet.UckSid] = X2uniqueX(ckSize);

sequenceSet.ckRespTypes = ckRespTypes;
sequenceSet.ck2RespTypes = ck2RespTypes;

sequenceSet.complexity = table(ckNum, pathLen, pathCrs);

end

