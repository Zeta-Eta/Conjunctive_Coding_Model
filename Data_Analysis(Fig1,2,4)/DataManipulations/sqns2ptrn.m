function [ptrnT,ptrnR,newPosLabels] = sqns2ptrn(t,r,center,wise)

% CAUTION: center can be >1 only when wise = 1;


% convert the original sequence of targets and responses into
% relatvie-position patterns

% format
% t: sequences of targets
% r: sequenses of responses, corresponding to each targets in the same row
% center: an integer choosen from 1 to setsize
% wise: 1:distinguish clockwise and counterclockwise (define pattern with clockwise )
%       2:No concerns of orientation

setsize = size(t,2);
N = max(max(t));
ptrnT = nan(size(t));
ptrnR = nan(size(r));

posLabels = 1:N; % available locations in an absolute order
newPosLabels = repmat(posLabels,[size(t,1),1]);

for trial = 1:size(t,1)
    
    ptrnT(trial,center) = 1;
    dis = t(trial,center) - ptrnT(trial,center);
    newPosLabels(trial,:) = posLabels - dis;
    newPosLabels(newPosLabels<=0) = newPosLabels(newPosLabels<=0)+N;
    
    if wise == 1    % clockwise
        
        ptrnT(trial,:) = newPosLabels(trial,t(trial,:));
        
        for i = 1:setsize
            if ~isnan(r(trial,i)) &  r(trial,i)~=0   %%%
                ptrnR(trial,i) = newPosLabels(trial,r(trial,i));
            end
        end
        
    elseif wise == 0    % not concerning orientation
        
        tempT = newPosLabels(trial,t(trial,:));
        
        if tempT(1,3) < tempT(1,2)
            
            newPosLabels(trial,:) = N+2 - newPosLabels(trial,:);
            newPosLabels(trial,t(trial,1)) = 1;
            tempT = newPosLabels(trial,t(trial,:));
        end
        
        if tempT(1,2) > ceil(N/2)
            
            newPosLabels(trial,:) = N+2 - newPosLabels(trial,:);
            newPosLabels(trial,t(trial,1)) = 1;
        end
        
        ptrnT(trial,:) = newPosLabels(trial,t(trial,:));
        for i = 1:setsize
            if ~isnan(r(trial,i)) & r(trial,i)~=0
                ptrnR(trial,i) = newPosLabels(trial,r(trial,i));
            end
        end
        
    end
    
end

end