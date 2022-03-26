% add extra output: orderDist, posDist;  zyf, 200427

function [CkDistraction, orderDist_output, posDist_output] = distractionAnalysis(ckTable)

    % distraction analysis 
    % with the use of ckTable infomation 
    nCKs = size(ckTable,1);
    CkDistraction = nan(nCKs,1);
    orderDist_output = [];
    posDist_output = [];
    for i = 1:nCKs
        
        % info about current chunk;
        ckOrder = ckTable.CKordercenter(i);
        ckPos = ckTable.CKposcenter(i);
        Ckpattern = ckTable.patternIdx(i,:);
        
        % find distractors
        unCks = ckTable;
        unCks(i,:) = [];         
        inPatternCKs = unCks(ismember(unCks.patternIdx,Ckpattern),:);  
        
        distractorPos = inPatternCKs.CKposcenter;
        distractorOrder = inPatternCKs.CKordercenter;
        
        
        orderDist = abs(ckOrder-distractorOrder);
        posDist = abs(ckPos-distractorPos);
        posDist(posDist>3)= 6-posDist(posDist>3);
        
        % calculate the distraction 
        % power law or exponential
        tempDistraction = sum((1./orderDist).*(1./(exp(posDist))));
        CkDistraction(i,1) = tempDistraction;
        
        orderDist_output = [orderDist_output,orderDist];
        posDist_output = [posDist_output,posDist];
    end

end

