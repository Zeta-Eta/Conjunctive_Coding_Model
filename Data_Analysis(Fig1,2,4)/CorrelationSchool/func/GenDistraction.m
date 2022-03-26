function [item_comp,which_pattern] = GenDistraction(input_pattern)




N = 6;
setsize = 4;
orientation = 0 ;

v = num2cell(repmat(1:N,setsize,1),2);
[v{setsize:-1:1}] = ndgrid(v{:});
mdlTypes = reshape(cat(setsize,v{:}),[],setsize);
GeSequences = [];

for type = 1:size(mdlTypes,1)
    if size(unique(mdlTypes(type,:)),2)==setsize
        GeSequences = [GeSequences;mdlTypes(type,:)];
    end
end

[ptrnT,~] = sqns2ptrn(GeSequences,GeSequences,1,orientation);  % patterns generation,
patterns = unique(ptrnT,'rows');                                       % all possible patterns


which_pattern = find(sum(patterns == input_pattern,2)==4);




% make a table for all element
ckStruct = struct();
ckStruct.patternIdx = [];
ckStruct.patterns = [];
ckStruct.orders = {};
% ckStruct.ACall = [];
% ckStruct.ACallasChunk = [];
% ckStruct.nTrials = [];
ckStruct.stpinPatterns = [];
ckStruct.size = [];
ckStruct.CKposcenter = [];
ckStruct.CKordercenter =[];
% extract the possible chunks
targetDistance = abs(patterns(which_pattern,2:end) - patterns(which_pattern,1:end-1));
targetDistance(targetDistance>ceil(6./2)) = 6 - targetDistance(targetDistance>ceil(6./2));
targetDistance(targetDistance~=1) = 0;
targetDistance = [zeros(size(targetDistance,1),1),targetDistance,zeros(size(targetDistance,1),1)];

count = 0;
for slideIdx= 1:setsize
    for  cksize = 1: setsize - slideIdx +1
        window = [0,ones(1,cksize-1),0];
        if ismember(targetDistance(1,slideIdx:slideIdx+cksize),window,'rows')==1
            count = count+1;
            orderchunk(1,slideIdx:slideIdx+cksize-1)=cksize;
            chunkLabels(1,slideIdx:slideIdx+cksize-1) = count;
            chunkMap4order(slideIdx:slideIdx+cksize-1,slideIdx:slideIdx+cksize-1)=1;
        end
    end
end
lbschunk = unique(chunkLabels);
chunkLocs = nan(1,size(lbschunk,2));
for i = 1:size(lbschunk,2)
    chunkLocs(1,i) = mean(patterns(which_pattern,ismember(chunkLabels,lbschunk(1,i))));
end
% calculate the chunking and distraction
cnt2 = 0;
for slideIdx  = 1:setsize       % including chunks from 0-4
    
    % the relative distance and chunk labels in a pattern
    
    for cksize= 1:setsize -slideIdx + 1
        window = [0,ones(1,cksize-1),0];   % the chunk window
        
        if ismember(targetDistance(1,slideIdx:slideIdx+cksize),window,'rows') ==1
            
            cnt2 = cnt2+1;
%             tempTrials = patternset.original{pattern,1};
            tempOrders = slideIdx:slideIdx+cksize-1;
            ckStruct.size = [ckStruct.size;cksize];
            ckStruct.chunks = {};
            ckStruct.orders = [ckStruct.orders;slideIdx:slideIdx+cksize-1];
            ckStruct.patterns = [ckStruct.patterns;patterns(which_pattern,:)];
            ckStruct.patternIdx = [ckStruct.patternIdx;which_pattern];
%             ckStruct.nTrials = [ckStruct.nTrials;size(tempTrials,1)];
            ckStruct.stpinPatterns = [ckStruct.stpinPatterns;slideIdx];
            
            % Accuracy
%             tempAC = nanmean(sum(tempTrials.targets(:,tempOrders)== tempTrials.responses(:,tempOrders),2)==cksize);
%             ckStruct.ACall = [ckStruct.ACall;tempAC];
            
            % chunk accuracy : ignoring exchange
%             count = 0;
%             for trial = 1:size(tempTrials,1)
%                 if sum(ismember(tempTrials.responses(trial,tempOrders),tempTrials.targets(trial,tempOrders)),2)==cksize,
%                     count = count + 1;
%                 end
%             end
%             tempACck = count./size(tempTrials,1);
%             ckStruct.ACallasChunk = [ckStruct.ACallasChunk;tempACck];
            
            % distraction and chunk labels
            
            ckStruct.CKposcenter = [ckStruct.CKposcenter;mean(patterns(which_pattern,tempOrders))];
            ckStruct.CKordercenter =[ckStruct.CKordercenter;lbschunk(1,cnt2)];
            
        end
    end
end
ckTable = table();
ckTable.patternIdx = ckStruct.patternIdx;
ckTable.patterns=ckStruct.patterns;
ckTable.orders=ckStruct.orders;
% ckTable.ACall=ckStruct.ACall;
% ckTable.ACallasChunk=ckStruct.ACallasChunk;
% ckTable.nTrials=ckStruct.nTrials;
ckTable.stpinPatterns=ckStruct.stpinPatterns;
ckTable.size=ckStruct.size;
ckTable.CKposcenter=ckStruct.CKposcenter;
ckTable.CKordercenter = ckStruct.CKordercenter;
% ckTable.ckEx = ckStruct.CkEx;
% cktable.CkExRatio=ckStruct.CkExRatio;

[CkDistraction, orderDist, posDist] = distractionAnalysis(ckTable);
ckTable.ckDistraction= CkDistraction;

% extrac item distraction
item_comp = [];
for a = 1:size(ckTable)
    orders = ckTable.orders{a};
    for b = 1:length(orders)
       item_comp = [item_comp,ckTable.ckDistraction(a)];
    end
end


