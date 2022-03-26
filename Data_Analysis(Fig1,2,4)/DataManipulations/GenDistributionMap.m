function GenDistributionMap(participants,rule,touchtype,setsize,N,usetrimed,userandom)

% generate distribution maps: order map, position map and distance map

%%
% clear
% % participants = {'Adults','Children','MO','MG'};
% % participants =  {'Adults','Children','MO','ML','MG'};
% participants =  {'MO'};
% rule ='repeat';
% touchtype = 'freeTouch';
% setsize = 4;
% N = 6;

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
    
    %     dataset= dataset(strcmp(participants{i},dataset.participant)...
    %         & strcmp(rule,dataset.rule) ...
    %         & strcmp(touchtype,dataset.touchType) ...
    %         & strcmp(num2str(setsize),string(dataset.setsize)),:);
    %
    %     dataset= dataset(strcmp(rule,dataset.rule) ...
    %         & strcmp(touchtype,dataset.touchType) ...
    %         & strcmp(num2str(setsize),string(dataset.setsize)),:);
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
        targets = dataset.targets;
        responses = dataset.responses;
        if strcmp(rule,'mirror')
            targets(:,1:setsize) = flipdim(targets(:,1:setsize),2);
        end   
        
        % transform 0 error stop response (aka,no respones ) to NaN
        if strcmp(touchtype, 'Combined') | strcmp(touchtype, 'errorStop')
            responses(responses == 0) = NaN; 
        end
              
         % Order map,  set size * (set size +1), 1st column = wrong item  
        orderT = repmat(1:setsize,[size(targets,1),1]);
        orderR = nan(size(orderT));
        for trial =  1:size(targets,1)
            for order = 1:setsize
                if ~isnan(responses(trial,order)) & responses(trial,order)~=0    %%%%
                    [~,col]=find( targets(trial,1:setsize)==responses(trial,order));
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
        OrderMap = round(OrderMap./sum(OrderMap,1),3);
        OrderMap = OrderMap';
        
        % non-target position error
        NonTargetMap4EachOrder = zeros(setsize,N/2);
        for order = 1:setsize
            nt_index = orderR(:,order)==0;
            %                 nt_index = (sum(ismember(orderR,order),2)==0);
            tempErrors = responses(nt_index,order)-targets(nt_index,order);
            tempErrors(tempErrors>3)=N-tempErrors(tempErrors>3);
            count = 0;
            for distance = 0:3
                count = count+1;
                NonTargetMap4EachOrder(order,count) = nansum(ismember(tempErrors,distance));
            end
        end
        NonTargetMapMapNum = NonTargetMap4EachOrder;
        NonTargetMap4EachOrder = NonTargetMap4EachOrder./sum(NonTargetMap4EachOrder,2);
        
        
        % ordinal error position error
        TargetMap4EachOrder = zeros(setsize,N/2);
        for order = 1:setsize
            nt_index = (orderR(:,order)~=0 & orderR(:,order)~=order);
            tempErrors = responses(nt_index,order)-targets(nt_index,order);
            tempErrors(tempErrors>3)=N-tempErrors(tempErrors>3);
            count = 0;
            for distance = 0:3
                count = count+1;
                TargetMap4EachOrder(order,count) = nansum(ismember(tempErrors,distance));
            end
        end
        TargetMapMapNum = TargetMap4EachOrder;
        TargetMap4EachOrder = TargetMap4EachOrder./sum(TargetMap4EachOrder,2);
        
        
        % Position map ( center = 0)
        PosMap = zeros(setsize,N);
        for order = 1:setsize
            tempErrors = responses(:,order)-targets(:,order);
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
        tlabel = reshape(targets(:,1:setsize),[size(targets,1)*setsize,1]);
        rlabel = reshape(responses(:,1:setsize),size(tlabel));
        [PositionMap, ~] = confusionmat(rlabel',tlabel');
        PositionMap = PositionMap./sum(PositionMap,2);
        
        % position error plot
        PositionMap4EachOrder = zeros(N,N,setsize);           
        for order = 1: setsize
            [mat, ~] = confusionmat(targets(:,order)',responses(:,order)');
            PositionMap4EachOrder(:,:,order) = mat;
        end
      
        % distance map(center = 0), setsize * N/2 +1,column = distance 0 to N/2
        DistMap = zeros(setsize,N/2);
        for order = 1:setsize
            tempErrors = abs(responses(:,order)-targets(:,order));
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
        if userandom ==1 & contains(participants{i},'M')
            save([filepath,touchtype '_' rule '_' num2str(setsize) '_DistributionMap_random.mat'],'*MapNum','*Map','PositionMap4EachOrder','NonTargetMap4EachOrder','TargetMap4EachOrder');
        else
            save([filepath,touchtype '_' rule '_' num2str(setsize) '_DistributionMap.mat'],'*MapNum','*Map','PositionMap4EachOrder','NonTargetMap4EachOrder','TargetMap4EachOrder');
        end
      
    end
    
    
end