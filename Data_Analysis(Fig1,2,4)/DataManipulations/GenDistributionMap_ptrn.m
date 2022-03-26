function GenDistributionMap_ptrn(participants,rule,touchtype,setsize,N,usetrimed,userandom)

% generate distribution maps: order map, position map and distance map

%%
% clear
% % participants = {'Adults','Children','MO','MG'};
% % participants =  {'Adults','Children','MO','ML','MG'};
% participants =  {'Adults','Children','MO','MG','MO&MG'};
% rule ='repeat';
% touchtype = 'freeTouch';
% setsize = 4;
% N = 6;
% usetrimed = 0;
% userandom = 0;

% all possible order
allR = perms(1:setsize);
allR = unique(allR,'rows');

% all possible location
allLoc  = perms(1:N);
allLoc  = unique(allLoc(:,1:setsize),'rows');

for i = 1:size(participants,2)
    filepath = ['Data/' participants{i} '/'];
    
    if userandom ==1 & contains(participants{i},'M')
        prelabel = 'randomSelect';
    else
        prelabel = 'clean';
    end
    if usetrimed==1 & exist([filepath, prelabel, '_dataset_trimmed.mat'],'file')
        datafile = [filepath, prelabel, '_dataset_trimmed.mat'];
    else
        datafile = [filepath, prelabel, '_dataset.mat'];
    end
    %     datafile = [filepath, 'clean_dataset.mat'];
    load(datafile);
    if strcmp(touchtype,'freeTouch')  | strcmp(touchtype,'errorStop')
        %         if contains(participants{i},'ML')    % if ML is included, use ML's error stop, and other monkeys' touch type is difined by var 'touchtype'
        %             temp1= dataset(strcmp(rule,dataset.rule) ...
        %                 & ~strcmp('ML',dataset.participant) ...
        %                 & strcmp(touchtype,dataset.touchType) ...
        %                 & strcmp(num2str(setsize),string(dataset.setsize)),:);
        %             temp2= dataset(strcmp(rule,dataset.rule) ...
        %                 & strcmp('ML',dataset.participant) ...
        %                 & strcmp(num2str(setsize),string(dataset.setsize)),:);
        %             dataset = [temp1;temp2];
        %         else
        dataset= dataset(strcmp(rule,dataset.rule) ...
            & strcmp(touchtype,dataset.touchType) ...
            & strcmp(num2str(setsize),string(dataset.setsize)),:);
        %         end
    elseif strcmp(touchtype, 'Combined')      % use data regardless of touch type
        dataset= dataset(strcmp(rule,dataset.rule) ...
            & strcmp(num2str(setsize),string(dataset.setsize)),:);
    end
    
    if ~isempty(dataset)
        targets = dataset.targets(:,1:setsize);
        responses = dataset.responses(:,1:setsize);
        if strcmp(rule,'mirror')
            targets(:,1:setsize) = flipdim(targets(:,1:setsize),2);
        end
        
        % patterns
        [ptrnT,ptrnR] = sqns2ptrn(targets,responses,1,0);  % patterns generation,   orientaion == 0  -->30 patterns
       
        patterns = unique(ptrnT,'rows');

        for pattern =  1:size(patterns,1)
            tempT = targets(ismember(ptrnT,patterns(pattern,:),'rows'),:);
            tempR = responses(ismember(ptrnT,patterns(pattern,:),'rows'),:);
            tempRpat = ptrnR(ismember(ptrnT,patterns(pattern,:),'rows'),:);   % responded parttern
            
            % transform 0 error stop response (aka,no respones ) to NaN
            if strcmp(touchtype, 'Combined') | strcmp(touchtype, 'errorStop')
                tempR(tempR == 0) = NaN;
            end
            
            % response sqns
            NsqnsResp = nan(size(allLoc,1),1);
            for resp = 1:size(allLoc,1)
                 NsqnsResp(resp,1) = sum(sum(tempRpat == allLoc(resp,:),2) == setsize);       
            end
            ProbsqnsResp = NsqnsResp/sum(NsqnsResp,1);
            
            
            
            % Order map,  set size * (set size +1), 1st column = wrong item
            orderT = repmat(1:setsize,[size(tempT,1),1]);
            orderR = nan(size(orderT));
            for trial =  1:size(tempT,1)
                for order = 1:setsize
                    if ~isnan(tempR(trial,order)) & tempR(trial,order)~=0    %%%%
                        [~,col]=find( tempT(trial,1:setsize)==tempR(trial,order));
                        if isempty(col)
                            orderR(trial,order) = 0;
                        else
                            orderR(trial,order) = col;
                        end
                    end
                end
            end
            if setsize<N
                OrderMap = zeros(setsize+1,setsize);
                for respOrd = 1:size(OrderMap,1)
                    OrderMap(respOrd,:) = sum(ismember(orderR,respOrd-1));
                end
                
            elseif setsize==N
                OrderMap = zeros(N,setsize);
                for respOrd = 1:size(OrderMap,1)
                    OrderMap(respOrd,:) = sum(ismember(orderR,respOrd));
                end
            end
            OrderMapNum = OrderMap;
            OrderMap = round(OrderMap./sum(OrderMap,1),3);
            OrderMap = OrderMap';
            
            NResp = nan(size(allR,1)+1,1);
            % responded order
            for resp = 1:size(allR,1)
               NResp(resp,1) = sum(sum(orderR == allR(resp,:),2) == setsize);    % responded order (corret item correct/incorrect order)
            end
               NResp(resp+1,1) = sum(sum(orderR~= 0,2)<setsize);      % non-target
            ProbResp = NResp/sum(NResp,1);
            
            % non-target position error
            NonTargetMap4EachOrder = zeros(setsize,N/2);
            for order = 1:setsize
                nt_index = orderR(:,order)==0;
%                 nt_index = (sum(ismember(orderR,order),2)==0);
                tempErrors = tempR(nt_index,order)-tempT(nt_index,order);               
                tempErrors(tempErrors>3)=N-tempErrors(tempErrors>3);  
                count = 0;
                for distance = 0:3
                    count = count+1;
                    NonTargetMap4EachOrder(order,count) = nansum(ismember(tempErrors,distance));
                end
            end
            NonTargetMapNum = NonTargetMap4EachOrder;
              NonTargetMap4EachOrder = NonTargetMap4EachOrder./sum(NonTargetMap4EachOrder,2); 
              
           % ordinal error position error
            TargetMap4EachOrder = zeros(setsize,N/2);
            for order = 1:setsize
                t_index = (orderR(:,order)~=0 & orderR(:,order)~=order);
                tempErrors = tempR(t_index,order)-tempT(t_index,order);               
                tempErrors(tempErrors>3)=N-tempErrors(tempErrors>3);  
                count = 0;
                for distance = 0:3
                    count = count+1;
                    TargetMap4EachOrder(order,count) = nansum(ismember(tempErrors,distance));
                end
            end
            TargetMapNum = TargetMap4EachOrder;
              TargetMap4EachOrder = TargetMap4EachOrder./sum(TargetMap4EachOrder,2);               
              
              
            
            % Position map ( center = 0)
            PosMap = zeros(setsize,N);
            for order = 1:setsize
                tempErrors = tempR(:,order)-tempT(:,order);
                tempErrors(tempErrors>3)=N-tempErrors(tempErrors>3);
                tempErrors(tempErrors<=-3)=N+tempErrors(tempErrors<=-3);
                
                count = 0;
                for pos = -2:3
                    count = count+1;
                    PosMap(order,count) = nansum(ismember(tempErrors,pos));
                end
            end
            % normalise PosMap
            PosMap = PosMap./sum(PosMap,2);
            
            % postition map
            tlabel = reshape(tempT(:,1:setsize),[size(tempT,1)*setsize,1]);
            rlabel = reshape(tempR(:,1:setsize),size(tlabel));
            [PositionMap, ~] = confusionmat(rlabel',tlabel');
            PositionMap = PositionMap./sum(PositionMap,2);
            
            % position error plot
            PositionMap4EachOrder = zeros(N,N,setsize);
            for order = 1: setsize
                [mat, ~] = confusionmat(tempT(:,order)',tempR(:,order)');
                PositionMap4EachOrder(:,:,order) = mat;
            end
            
            % distance map(center = 0), setsize * N/2 +1,column = distance 0 to N/2
            DistMap = zeros(setsize,N/2);
            for order = 1:setsize
                tempErrors = abs(tempR(:,order)-tempT(:,order));
                tempErrors(tempErrors>3)=N-tempErrors(tempErrors>3);
                
                count = 0;
                for distance = 0:3
                    count = count+1;
                    DistMap(order,count) = nansum(ismember(tempErrors,distance));
                end
            end
            % normalise DistMap
            DistMapNum = DistMap;
            DistMap = DistMap./sum(DistMap,2);
            
            if ~exist([filepath '/ptrnDistributionMap'],'dir')
                mkdir([filepath '/ptrnDistributionMap']);
            end
            if userandom ==1 & contains(participants{i},'M')
                 save([filepath '/ptrnDistributionMap/',num2str(pattern) '_' touchtype '_' rule '_' num2str(setsize) '_DistributionMap_random.mat'],...
                     '*Map','*MapNum','PositionMap4EachOrder','ProbResp','NResp','ProbsqnsResp','NsqnsResp','NonTargetMap4EachOrder','TargetMap4EachOrder');
            else
            
            save([filepath '/ptrnDistributionMap/',num2str(pattern) '_' touchtype '_' rule '_' num2str(setsize) '_DistributionMap.mat'],...
                '*Map','*MapNum','PositionMap4EachOrder','ProbResp','NResp','ProbsqnsResp','NsqnsResp','NonTargetMap4EachOrder','TargetMap4EachOrder');
        
            end
        end
    end
    
    
end