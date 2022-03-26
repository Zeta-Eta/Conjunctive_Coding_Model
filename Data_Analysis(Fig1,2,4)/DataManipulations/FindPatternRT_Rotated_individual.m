function FindPatternRT_Rotated_individual(participants,rule,touchtype,setsize,N,usetrimed,userandom)

% clear


%
% participants = {'Adults','Children','MO','MG','ML','MO&MG','MO&MG&ML'};
% % participants = {'ML'};
% rule ='repeat';
% touchtype =  'freeTouch';  %% 'freeTouch' | 'errorStop' | 'Combined'
% setsize = 4;
%
% N = 6;
% usetrimed=1;
for i = 1:size(participants,2)
    %%  load data
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
    load(datafile);
    
    % select data
    if strcmp(touchtype,'freeTouch')  | strcmp(touchtype,'errorStop')
        if contains(participants{i},'ML')    % if ML is included, use ML's error stop, and other monkeys' touch type is difined by var 'touchtype'
            temp1= dataset(strcmp(rule,dataset.rule) ...
                & ~strcmp('ML',dataset.participant) ...
                & strcmp(touchtype,dataset.touchType) ...
                & strcmp(num2str(setsize),string(dataset.setsize)),:);
            temp2= dataset(strcmp(rule,dataset.rule) ...
                & strcmp('ML',dataset.participant) ...
                & strcmp(num2str(setsize),string(dataset.setsize)),:);
            dataset = [temp1;temp2];
        else
            dataset= dataset(strcmp(rule,dataset.rule) ...
                & strcmp(touchtype,dataset.touchType) ...
                & strcmp(num2str(setsize),string(dataset.setsize)),:);
        end
    elseif strcmp(touchtype, 'Combined')      % use data regardless of touch type
        dataset= dataset(strcmp(rule,dataset.rule) ...
            & strcmp(num2str(setsize),string(dataset.setsize)),:);
    end
    
    
    %% rotate dots: to match the coordinate of the 6 loc in different parti
    % sees "Stimuli_Location.xlsx" in "E:\Zhen\1_Working\2_RepeatMirrorChild\8_Manuscripts\0_info"
    
     if strcmp('Adults', participants{i})
%         loc_order = [5:-1:1,6];
%         
%         dataset.targets = 6 - dataset.targets;
%         dataset.targets(dataset.targets == 0) = 6;
%         dataset.responses = 6 - dataset.responses;
%         dataset.responses(dataset.responses == 0) = 6;
        
    elseif strcmp('Children', participants{i})
        dataset.targets = dataset.targets +1;
        dataset.targets(dataset.targets > 6) = 1;
        dataset.responses = dataset.responses+1;
        dataset.responses(dataset.responses > 6) = 1; 
    else 
        MG_index = strcmp('MG',dataset.participant);
        MO_index = strcmp('MO',dataset.participant);
        if ~isempty(MG_index)

            temp_dataset = dataset(MG_index,:);
            dataset(MG_index,:) = [];
            temp_dataset.targets = temp_dataset.targets +2;
            temp_dataset.targets(temp_dataset.targets > 6) = temp_dataset.targets(temp_dataset.targets > 6)-6;
            temp_dataset.responses = temp_dataset.responses+2;
            temp_dataset.responses(temp_dataset.responses > 6) = temp_dataset.responses(temp_dataset.responses > 6)-6;
            dataset =[dataset;temp_dataset];
        
        end
        if ~isempty(MO_index)
            temp_dataset = dataset(MO_index,:);
            dataset(MO_index,:) = [];
            temp_dataset.targets = temp_dataset.targets +1;
            temp_dataset.targets(temp_dataset.targets > 6) = 1;
            temp_dataset.responses = temp_dataset.responses+1;
            temp_dataset.responses(temp_dataset.responses > 6) = 1;
            dataset =[dataset;temp_dataset];
        end
    end   
        temp_dataset = dataset;
    allparti = unique(dataset.session,'rows');
        for individual = 1:size(allparti,1)
        
        dataset = temp_dataset(strcmp(temp_dataset.session,allparti(individual,:)),:);
    
    
    dataset.targets = dataset.targets(:,1:setsize);
    dataset.responses = dataset.responses(:,1:setsize);
    
    if strcmp(rule,'mirror')
        dataset.targets(:,1:setsize) = flipdim(dataset.targets(:,1:setsize),2);
    end
    % correct trials only
    correct_index = find(sum(dataset.targets(:,1:setsize) == dataset.responses(:,1:setsize),2)==setsize);
    dataset= dataset(correct_index,:);
    dataset.targets = dataset.targets(:,1:setsize);
    dataset.responses = dataset.responses(:,1:setsize);
    dataset.RT = dataset.RT(:,1:setsize);
    
    
    %% sort trials by sequence, 30 patterns * 6 starting points * 2 orientations = 360 sequences
    sequences = unique(dataset.targets,'rows');    % sequence
    ac_sequence = zeros(size(sequences,1),1);   % sequence accuracy
    ac_sequence_order = zeros(size(sequences));   % accuracy for items in each order
    sqnsAmount = zeros(size(sequences,1),1);     % trial number of each sequence
    originalSqns = cell(size(sequences,1),1);    % save trial data
    
    rt_sequence_order = zeros(size(sequences,1),setsize);
    for sq = 1: size(sequences,1)
        tempSequence = dataset(ismember(dataset.targets,sequences(sq,:),'rows'),:);
        sqnsAmount(sq,1) = size(tempSequence,1);
        %         ac_sequence(sq,:) = mean(sum(tempSequence.targets==tempSequence.responses,2)==setsize);
        %         ac_sequence_order(sq,:) = mean(tempSequence.targets==tempSequence.responses);
        rt_sequence_order(sq,:) = mean(tempSequence.RT);
        originalSqns{sq,1} = tempSequence;
    end
    % table of sequence (maximum 360 sequences when setsize ==4)
    sqnsRTtable = table(sequences,rt_sequence_order,sqnsAmount,originalSqns);
    %% compare the orientation (180 : 180 with the same startpoint)
    %  generate all possible sequences
    v = num2cell(repmat(1:N,setsize,1),2);
    [v{setsize:-1:1}] = ndgrid(v{:});
    mdlTypes = reshape(cat(setsize,v{:}),[],setsize);
    GeSequences = [];
    
    for type = 1:size(mdlTypes,1)
        if size(unique(mdlTypes(type,:)),2)==setsize
            GeSequences = [GeSequences;mdlTypes(type,:)];
        end
    end
    
    %%  pair sequences to 180 pairs:   pattern(30) * starting point(6)
    clcSqns = [];
    anticlcSqns = [];
    while ~isempty(GeSequences)
        tempSqns = GeSequences(1,:);
        sumdist2stp = 2*tempSqns(1,1);
        temp_orient1 = tempSqns;
        temp_orient2 = sumdist2stp-tempSqns;
        temp_orient2(temp_orient2<=0)= temp_orient2(temp_orient2<=0)+N;
        temp_orient2(temp_orient2>6)= temp_orient2(temp_orient2>6)-N;
        
        % coordinated from the 2nd point, and calculate the angel between
        % first stroke and scond stroke, the stroke angel larger than 0is
        % colockwise
        
        % convert dots to coordinates ( >0: clc; <0:anticlc)
        temp_coor = sqns2coord(tempSqns);
        vector1 = temp_coor(:,1)-temp_coor(:,2);
        vector2 = temp_coor(:,3)-temp_coor(:,2);
        dotUV = dot(vector1',vector2');
        detUV = vector1(1,1)*vector2(2,1) - vector1(2,1)*vector2(1,1);
        theta = atan2(detUV,dotUV);
        %         normU = sqrt(sum(vector1.^2));
        %         normV = sqrt(sum(vector2.^2));
        %         theta = acos(dotUV/(normU * normV));
        realangle = theta*180/pi;
        
        if realangle <=0
            clcSqns = [clcSqns;temp_orient2];
            anticlcSqns = [anticlcSqns;temp_orient1];
        elseif realangle >=0
            clcSqns = [clcSqns;temp_orient1];
            anticlcSqns = [anticlcSqns;temp_orient2];
        end
        GeSequences(ismember(GeSequences,temp_orient1,'rows'),:)=[];
        GeSequences(ismember(GeSequences,temp_orient2,'rows'),:)=[];
    end
    
    %% pair sequence to 60 pairs, patterns(30) * orientation (2), paired by starting points
    [ptrnT,~] = sqns2ptrn(dataset.targets,dataset.responses,1,1);  % patterns generation,   orientaion == 1
    patterns = unique(ptrnT,'rows');                                       % all possible patterns
    
    for pattern = 1:size(patterns,1)
        PatternData = dataset(ismember(ptrnT,patterns(pattern,:),'rows'),:);
        for startpoint = 1:N
            sqnsIdx = find(ismember(PatternData.targets(:,1),startpoint));
            tempSequences = PatternData(sqnsIdx,:);
            %             tempT = tempSequences.targets;
            %             tempR = tempSequences.responses;
            tempRT = tempSequences.RT(:,1);           % responese time of the 1st item only
            
            stpRTtable(pattern,startpoint) = nanmean(tempRT);
            stpRTtable(pattern,startpoint+N) = length(sqnsIdx);   % trial number
        end
        
    end
    
    
    %% pair sequence to 30 pairs, patterns(30) , paired by starting points£¬ regardless of orientation
    
    [ptrnT,~] = sqns2ptrn(dataset.targets,dataset.responses,1,0);  % patterns generation,   orientaion == 0
    patterns = unique(ptrnT,'rows');                                       % all possible patterns
    
    for pattern = 1:size(patterns,1)
        PatternData = dataset(ismember(ptrnT,patterns(pattern,:),'rows'),:);
        for startpoint = 1:N
            sqnsIdx = find(ismember(PatternData.targets(:,1),startpoint));
            tempSequences = PatternData(sqnsIdx,:);
            %             tempT = tempSequences.targets;
            %             tempR = tempSequences.responses;
            tempRT = tempSequences.RT(:,1);           % responese time of the 1st item only
            
            stpRTtable2(pattern,startpoint) = nanmean(tempRT);
            stpRTtable2(pattern,startpoint+N) = length(sqnsIdx);   % trial number
        end
        
    end
    
    
    %% grouped by patterns, 30 patterns regardless of starting point and orientation
    [ptrnT2,~] = sqns2ptrn(dataset.targets,dataset.responses,1,0);  % patterns generation,   orientaion == 0  -->30 patterns
    patterns2 = unique(ptrnT2,'rows');                                       % all possible patterns
    
    for pattern = 1:size(patterns2,1)
        
        PatternData2 = dataset(ismember(ptrnT2,patterns2(pattern,:),'rows'),:);
        tempT = PatternData2.targets;
        tempRT = PatternData2.RT;
        %         tempR = PatternData2.responses;
        % split orientation, collaped starting point --- > 30 pattern pairs
        tempclcIdx = find(ismember(tempT,clcSqns,'rows'));
        ptrntrial_clc(pattern,1) = length(tempclcIdx);
        if ~isempty(tempclcIdx)
            %             ptrnAC_clc(pattern,1) = nanmean(nansum(tempT(tempclcIdx,:) == tempR(tempclcIdx,:),2)==setsize);
            %             ptrnSD_clc(pattern,1) = nanstd(nansum(tempT(tempclcIdx,:) == tempR(tempclcIdx,:),2)==setsize);
            %             ptrnSE_clc(pattern,1) = ptrnSD_clc(pattern,1)/sqrt(length(nansum(tempT(tempclcIdx,:) == tempR(tempclcIdx,:),2)==setsize));
            ptrnRT_clc(pattern,1:setsize) = nanmean(tempRT(tempclcIdx,1:setsize));
            ptrnRTSD_clc(pattern,1:setsize) = nanstd(tempRT(tempclcIdx,1:setsize));
            ptrnRTSE_clc(pattern,1:setsize) = ptrnRTSD_clc(pattern,1:setsize)./sqrt(size(~isnan(tempRT(tempclcIdx,1:setsize)),1));
            target_clc{pattern,1} =tempT(tempclcIdx,:);
        end
        tempanticlcIdx = find(ismember(tempT,anticlcSqns,'rows'));
        ptrntrial_anticlc(pattern,1) = length(tempanticlcIdx);
        if ~isempty(tempanticlcIdx)
            %             ptrnAC_anticlc(pattern,1) = nanmean(nansum(tempT(tempanticlcIdx,:) == tempR(tempanticlcIdx,:),2)==setsize);
            %             ptrnSD_anticlc(pattern,1) = nanstd(nansum(tempT(tempanticlcIdx,:) == tempR(tempanticlcIdx,:),2)==setsize);
            %             ptrnSE_anticlc(pattern,1) = ptrnSD_anticlc(pattern,1)/sqrt(length(nansum(tempT(tempanticlcIdx,:) == tempR(tempanticlcIdx,:),2)==setsize));
            ptrnRT_anticlc(pattern,1:setsize) = nanmean(tempRT(tempanticlcIdx,1:setsize));
            ptrnRTSD_anticlc(pattern,1:setsize) = nanstd(tempRT(tempanticlcIdx,1:setsize));
            ptrnRTSE_anticlc(pattern,1:setsize) = ptrnRTSD_anticlc(pattern,1:setsize)./sqrt(size(~isnan(tempRT(tempanticlcIdx,1:setsize)),1));
            target_anticlc{pattern,1} =tempT(tempanticlcIdx,:);
        end
        
        % sequence acc in each pattern type
        all_sqns  = unique(tempT,'rows');
        for sequences = 1:size(all_sqns,1)
            tempsqnsindex = find(ismember(tempT,all_sqns(sequences,:),'rows'));
            ptrntrial_sqns(sequences,1) = length(tempsqnsindex);
            if ~isempty(tempsqnsindex)
                %                 ptrnAC_sqns(sequences,pattern) = nanmean(nansum(tempT(tempsqnsindex,:) == tempR(tempsqnsindex,:),2)==setsize);
                %                 ptrnSD_sqns(sequences,pattern) = nanstd(nansum(tempT(tempsqnsindex,:) == tempR(tempsqnsindex,:),2)==setsize);
                %                 ptrnSE_sqns(sequences,pattern) = ptrnSD_sqns(sequences,pattern)/sqrt(length(nansum(tempT(tempsqnsindex,:) == tempR(tempsqnsindex,:),2)==setsize));
                ptrnRT_sqns(pattern,sequences,1:setsize) = nanmean(tempRT(tempsqnsindex,1:setsize));
                ptrnRTSD_sqns(pattern,sequences,1:setsize) = nanstd(tempRT(tempsqnsindex,1:setsize));
                ptrnRTSE_sqns(pattern,sequences,1:setsize) = ptrnRTSD_sqns(pattern,sequences,1:setsize)./sqrt(size(tempRT(tempsqnsindex,1:setsize),1));
                
                target_sqns{pattern,sequences} = [tempT(tempsqnsindex,:),tempRT(tempsqnsindex,:)];
            end
        end
        
        %collapsed starting points and orientations
        ptrnRT(pattern,1:setsize) = nanmean(tempRT(:,1:setsize));
        ptrnRTSD(pattern,1:setsize) = nanstd(tempRT(:,1:setsize));
        ptrnRTSE(pattern,1:setsize) = ptrnRTSD(pattern,1:setsize)./sqrt(size(~isnan(tempRT(:,1:setsize)),1));
    end
    ptrnRTtable = table(patterns2,ptrnRT,ptrnRTSD,ptrnRTSE,...
        target_clc,ptrnRT_clc, ptrnRTSD_clc,ptrnRTSE_clc,...
        target_anticlc,ptrnRT_anticlc, ptrnRTSD_anticlc,ptrnRTSE_anticlc,ptrntrial_clc,ptrntrial_anticlc);  % table for 30 patterns and 30 pattern pairs(paired by orientation)
    
    sqnsInptrnRTtable = table(ptrnRT_sqns,ptrnRTSD_sqns,ptrnRTSE_sqns,target_sqns);
    if userandom ==1 & contains(participants{i},'M')
        save([filepath,touchtype '_' rule '_' num2str(setsize) '_' allparti{individual,:} '_SqnsRTTable_random.mat'],'sqnsRTtable','ptrnRTtable','sqnsInptrnRTtable',...
            'stpRTtable','stpRTtable2');
    else
        save([filepath,touchtype '_' rule '_' num2str(setsize) '_' allparti{individual,:}  '_SqnsRTTable.mat'],'sqnsRTtable','ptrnRTtable','sqnsInptrnRTtable',...
            'stpRTtable','stpRTtable2');
    end
    end
    fprintf([participants{i} 'finished \n']);
    
    
    
end