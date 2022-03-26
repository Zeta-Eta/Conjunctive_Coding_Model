function SortSequence_Rotated(participants,rule,touchtype,setsize,N,usetrimed,userandom)
% sort trials by sequence
% pair sequences by starting point * orientation
% Different ways of accuracy calculation in "free touch" and "error stop"
% free touch accuray = correct touch/all trials
% error stop accuracy = correct touch/ number of trials that previous touches in the same trial were correct
% when touchtype = "Combined", 
% accuracy = (correct free touch touches  + correct error stop touches) / (all free touch trials + number of error stop trials that previous touches in the same trial were correct)
% 
% rotate sequence location markers to align locations in different group
% rotated location markers: 1- upper left, 2-upper right, 3- right, 4-lower
% right, 5- lower left, and 6- left.
% original locations sees "Stimuli_Location.xlsx" in "E:\Zhen\1_Working\2_RepeatMirrorChild\8_Manuscripts\0_info"
% Rotation is not applicable for participant ML


% clear

% participants = {'Adults','Children','MO','MG'};
% participants = {'MO&MG&ML'};
% rule ='repeat';
% touchtype = 'Combined';  %'freeTouch' | 'errorStop' | 'Combined'
% setsize = 4;
% 
% N = 6;
% usetrimed = 0;
% userandom = 0;



for i = 1:size(participants,2)
    %%  load data
    filepath = ['Data/' participants{i} '/'];
    
    % select dataset
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
        
    
    dataset.targets = dataset.targets(:,1:setsize);
    dataset.responses = dataset.responses(:,1:setsize);
    if strcmp(rule,'mirror')
        dataset.targets(:,1:setsize) = flipdim(dataset.targets(:,1:setsize),2);
    end
    
    %% sort trials by sequence, 30 patterns * 6 starting points * 2 orientations = 360 sequences
    sequences = unique(dataset.targets,'rows');    % sequence
    ac_sequence = zeros(size(sequences,1),1);   % sequence accuracy
    ac_sequence_order = zeros(size(sequences));   % accuracy for items in each order
    sqnsAmount = zeros(size(sequences,1),1);     % trial number of each sequence
    originalSqns = cell(size(sequences,1),1);    % save trial data
    
    for sq = 1: size(sequences,1)
        tempSequence = dataset(ismember(dataset.targets,sequences(sq,:),'rows'),:);
        sqnsAmount(sq,1) = size(tempSequence,1);
        
        ac_sequence(sq,:) = mean(sum(tempSequence.targets==tempSequence.responses,2)==setsize);
        if strcmp(touchtype,'freeTouch')
            ac_sequence_order(sq,:) = mean(tempSequence.targets==tempSequence.responses,1);
        elseif strcmp(touchtype,'errorStop')
            for tt  = 1:setsize
                validtrial = tempSequence(tempSequence.responses(:,tt)~=0,:);
                ac_sequence_order(sq,tt) = mean(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
            end
        elseif strcmp(touchtype,'Combined')
            ft_index = find(strcmp(tempSequence.touchType,'freeTouch'));
            if ~isempty(ft_index)
                ft_trials = tempSequence(ft_index,:);
            else
                ft_trials = [];
            end
            all_trials = ft_trials;
            es_index = find(strcmp(tempSequence.touchType,'errorStop'));
            es_data = tempSequence(es_index,:);
            if ~isempty(es_index)
                for tt = 1:setsize
                    validtrial = es_data(es_data.responses(:,tt)~=0,:);
                    all_validtrial = [all_trials;validtrial];
                    ac_sequence_order(sq,tt)= nanmean(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt),1);
                end
            else
                all_validtrial = all_trials;
                ac_sequence_order(sq,:) = mean(all_validtrial.targets==all_validtrial.responses,1);
            end
        end
        originalSqns{sq,1} = tempSequence;
    end
    % table of sequence (maximum 360 sequences when setsize ==4)
    sqnsACtable = table(sequences,ac_sequence,ac_sequence_order,sqnsAmount,originalSqns);
    
    %% compare the orientation (180 : 180 with the same startpoint)
    %  generate all possible sequences
%     v = num2cell(repmat(1:N,setsize,1),2);
%     [v{setsize:-1:1}] = ndgrid(v{:});
%     mdlTypes = reshape(cat(setsize,v{:}),[],setsize);
%     GeSequences = [];
%     
%     for type = 1:size(mdlTypes,1)
%         if size(unique(mdlTypes(type,:)),2)==setsize
%             GeSequences = [GeSequences;mdlTypes(type,:)];
%         end
%     end
    
    v = perms(1:N);
    GeSequences = unique(v(:,1:setsize),'rows');
    
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
    
    clctrialnum = nan(size(clcSqns,1),1);
    clcAC = nan(size(clcSqns,1),1);
    clcACorder = nan(size(clcSqns));
    anticlctrialnum = nan(size(anticlcSqns,1),1);
    anticlcAC = nan(size(anticlcSqns,1),1);
    anticlcACorder = nan(size(anticlcSqns));
    
    for k = 1: size(clcSqns,1)
        tempclcSqns = clcSqns(k,:);
        tempanticlcSqns = anticlcSqns(k,:);
        
        tempclcIdx = sqnsACtable(ismember(sqnsACtable.sequences,tempclcSqns,'rows'),:);
        if ~isempty(tempclcIdx)
            clctrialnum(k,1) = tempclcIdx.sqnsAmount;
            clcAC(k,:) = tempclcIdx.ac_sequence;
            clcACorder(k,:) = tempclcIdx.ac_sequence_order;
        end
        
        tempanticlcIdx = sqnsACtable(ismember(sqnsACtable.sequences,tempanticlcSqns,'rows'),:);
        if ~isempty(tempanticlcIdx)
            anticlctrialnum(k,1) = tempanticlcIdx.sqnsAmount;
            anticlcAC(k,:) = tempanticlcIdx.ac_sequence;
            anticlcACorder(k,:) = tempanticlcIdx.ac_sequence_order;
        end
    end
    
    clcSqnsTable = table(clcSqns,clcAC,clcACorder,clctrialnum);
    anticlcSqnsTable = table(anticlcSqns,anticlcAC,anticlcACorder,anticlctrialnum);
    SqnsTable = table(clcSqns,clcAC,clcACorder,clctrialnum,anticlcSqns,anticlcAC,anticlcACorder,anticlctrialnum);
    
    
    
    %% pair sequence to 60 pairs, patterns(30) * orientation (2), paired by starting points
    [ptrnT,~] = sqns2ptrn(dataset.targets,dataset.responses,1,1);  % patterns generation,   orientaion == 1
    patterns = unique(ptrnT,'rows');                                       % all possible patterns
    
    for pattern = 1:size(patterns,1)
        PatternData = dataset(ismember(ptrnT,patterns(pattern,:),'rows'),:);
        for startpoint = 1:N
            sqnsIdx = find(ismember(PatternData.targets(:,1),startpoint));
            tempSequences = PatternData(sqnsIdx,:);
            tempT = tempSequences.targets;
            tempR = tempSequences.responses;
            
            stpACtable(pattern,startpoint) = nanmean(nansum(tempT == tempR,2)==setsize);
            stpACtable(pattern,startpoint+N) = length(sqnsIdx);   % trial number
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
            tempT = tempSequences.targets;
            tempR = tempSequences.responses;
            
            stpACtable2(pattern,startpoint) = nanmean(nansum(tempT == tempR,2)==setsize);
            stpACtable2(pattern,startpoint+N) = length(sqnsIdx);   % trial number
        end
        
    end
    
    
    
    %% grouped by patterns, 30 patterns regardless of starting point and orientation
    [ptrnT2,~] = sqns2ptrn(dataset.targets,dataset.responses,1,0);  % patterns generation,   orientaion == 0  -->30 patterns
    patterns2 = unique(ptrnT2,'rows');                                       % all possible patterns
    
    for pattern = 1:size(patterns2,1)
        
        PatternData2 = dataset(ismember(ptrnT2,patterns2(pattern,:),'rows'),:);
        tempT = PatternData2.targets;
        tempR = PatternData2.responses;
        % split orientation, collaped starting point --- > 30 pattern pairs
        tempclcIdx = find(ismember(tempT,clcSqns,'rows'));
        ptrntrial_clc(pattern,1) = length(tempclcIdx);
        if ~isempty(tempclcIdx)
            clc_tempData = PatternData2(tempclcIdx,:);
            clc_tempT = tempT(tempclcIdx,1:setsize); clc_tempR = tempR(tempclcIdx,1:setsize);
            
            ptrnAC_clc(pattern,1) = nanmean(nansum(clc_tempT == clc_tempR ,2)==setsize);
            ptrnSD_clc(pattern,1) = nanstd(nansum(clc_tempT == clc_tempR,2)==setsize);
            ptrnSE_clc(pattern,1) = ptrnSD_clc(pattern,1)/sqrt(length(nansum(clc_tempT == clc_tempR,2)==setsize));
            %
            if strcmp(touchtype,'freeTouch') == 1
                ptrnACorder_clc(pattern,1:setsize) = nanmean(clc_tempT(:,1:setsize) == clc_tempR(:,1:setsize),1);
                ptrnSDorder_clc(pattern,1:setsize) = nanstd(clc_tempT(:,1:setsize) == clc_tempR(:,1:setsize),1);
                ptrnSEorder_clc(pattern,1:setsize) = ptrnSDorder_clc(pattern,1:setsize)/sqrt(size(clc_tempT(:,1:setsize) == clc_tempR(:,1:setsize),1));
            elseif strcmp(touchtype,'errorStop')
                for tt  = 1:setsize
                    validtrial = clc_tempData(clc_tempT(:,tt)~=0,:);
                    ptrnACorder_clc(pattern,tt) = nanmean(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                    ptrnSDorder_clc(pattern,tt) = nanstd(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                    ptrnSEorder_clc(pattern,tt) = ptrnSDorder_clc(pattern,tt)/sqrt(size(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1));
                end
            elseif strcmp(touchtype,'Combined')
                ft_index = find(strcmp(clc_tempData.touchType,'freeTouch'));
                if ~isempty(ft_index)
                    ft_trials = clc_tempData(ft_index,:);
                else
                    ft_trials = [];
                end
                all_trials = ft_trials;
                es_index = find(strcmp(clc_tempData.touchType,'errorStop'));
                es_data = clc_tempData(es_index,:);
                if ~isempty(es_index)
                    for tt = 1:setsize
                        validtrial = es_data(es_data.responses(:,tt)~=0,:);
                        all_validtrial = [all_trials;validtrial];
                        ptrnACorder_clc(pattern,tt) = nanmean(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt),1);
                        ptrnSDorder_clc(pattern,tt) = nanstd(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt),1);
                        ptrnSEorder_clc(pattern,tt) = ptrnSDorder_clc(pattern,tt)/sqrt(size(all_validtrial.targets(:,tt) == all_validtrial.responses(:,tt),1));
                    end
                else
                    all_validtrial = all_trials;
                    ptrnACorder_clc(pattern,1:setsize) = nanmean(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1);
                    ptrnSDorder_clc(pattern,1:setsize) = nanstd(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1);
                    ptrnSEorder_clc(pattern,1:setsize) = ptrnSDorder_clc(pattern,1:setsize)/sqrt(size(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1));
                end
            end
            target_clc{pattern,1} =tempT(tempclcIdx,:);
        end
        tempanticlcIdx = find(ismember(tempT,anticlcSqns,'rows'));
        ptrntrial_anticlc(pattern,1) = length(tempanticlcIdx);
        if ~isempty(tempanticlcIdx)
            anticlc_tempData = PatternData2(tempanticlcIdx,:);
            anticlc_tempT = tempT(tempanticlcIdx,1:setsize); anticlc_tempR = tempR(tempanticlcIdx,1:setsize);
            
            ptrnAC_anticlc(pattern,1) = nanmean(nansum(anticlc_tempT == anticlc_tempR ,2)==setsize);
            ptrnSD_anticlc(pattern,1) = nanstd(nansum(anticlc_tempT == anticlc_tempR,2)==setsize);
            ptrnSE_anticlc(pattern,1) = ptrnSD_anticlc(pattern,1)/sqrt(length(nansum(anticlc_tempT == anticlc_tempR,2)==setsize));
            %
            if strcmp(touchtype,'freeTouch') == 1
                ptrnACorder_anticlc(pattern,1:setsize) = nanmean(anticlc_tempT(:,1:setsize) == anticlc_tempR(:,1:setsize),1);
                ptrnSDorder_anticlc(pattern,1:setsize) = nanstd(anticlc_tempT(:,1:setsize) == anticlc_tempR(:,1:setsize),1);
                ptrnSEorder_anticlc(pattern,1:setsize) = ptrnSDorder_anticlc(pattern,1:setsize)/sqrt(size(anticlc_tempT(:,1:setsize) == anticlc_tempR(:,1:setsize),1));
            elseif strcmp(touchtype,'errorStop')
                for tt  = 1:setsize
                    validtrial = anticlc_tempData(anticlc_tempT(:,tt)~=0,:);
                    ptrnACorder_anticlc(pattern,tt) = nanmean(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                    ptrnSDorder_anticlc(pattern,tt) = nanstd(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                    ptrnSEorder_anticlc(pattern,tt) = ptrnSDorder_anticlc(pattern,tt)/sqrt(size(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1));
                end
            elseif strcmp(touchtype,'Combined')
                ft_index = find(strcmp(anticlc_tempData.touchType,'freeTouch'));
                if ~isempty(ft_index)
                    ft_trials = anticlc_tempData(ft_index,:);
                else
                    ft_trials = [];
                end
                all_trials = ft_trials;
                es_index = find(strcmp(anticlc_tempData.touchType,'errorStop'));
                es_data = anticlc_tempData(es_index,:);
                if ~isempty(es_index)
                    for tt = 1:setsize
                        validtrial = es_data(es_data.responses(:,tt)~=0,:);
                        all_validtrial = [all_trials;validtrial];
                        ptrnACorder_anticlc(pattern,tt) = nanmean(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt),1);
                        ptrnSDorder_anticlc(pattern,tt) = nanstd(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt),1);
                        ptrnSEorder_anticlc(pattern,tt) = ptrnSDorder_anticlc(pattern,tt)/sqrt(size(all_validtrial.targets(:,tt) == all_validtrial.responses(:,tt),1));
                        
                    end
                else
                    all_validtrial = all_trials;
                    ptrnACorder_anticlc(pattern,1:setsize) = nanmean(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1);
                    ptrnSDorder_anticlc(pattern,1:setsize) = nanstd(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1);
                    ptrnSEorder_anticlc(pattern,1:setsize) = ptrnSDorder_anticlc(pattern,1:setsize)/sqrt(size(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1));
                end
            end
            target_anticlc{pattern,1} =tempT(tempanticlcIdx,:);
        end
        
        % sequence acc in each pattern type
        all_sqns  = unique(tempT,'rows');
        for sequences = 1:size(all_sqns,1)
            tempsqnsindex = find(ismember(tempT,all_sqns(sequences,:),'rows'));
            ptrntrial_sqns(sequences,1) = length(tempsqnsindex);
            if ~isempty(tempsqnsindex) 
                sqns_tempData = PatternData2(tempsqnsindex,:);
                sqns_tempT = tempT(tempsqnsindex,1:setsize); sqns_tempR = tempR(tempsqnsindex,1:setsize);
                
                ptrnAC_sqns(sequences,pattern) = nanmean(nansum(sqns_tempT == sqns_tempR,2)==setsize);
                ptrnSD_sqns(sequences,pattern) = nanstd(nansum(sqns_tempT == sqns_tempR,2)==setsize);
                ptrnSE_sqns(sequences,pattern) = ptrnSD_sqns(sequences,pattern)/sqrt(length(nansum(sqns_tempT == sqns_tempR,2)==setsize));
                
                if strcmp(touchtype,'freeTouch') == 1
                    ptrnACorder_sqns(pattern,sequences,1:setsize) = nanmean(sqns_tempT(:,1:setsize) == sqns_tempR(:,1:setsize),1);
                    ptrnSDorder_sqns(pattern,sequences,1:setsize) = nanstd(sqns_tempT(:,1:setsize) == sqns_tempR(:,1:setsize),1);
                    ptrnSEorder_sqns(pattern,sequences,1:setsize) = ptrnSDorder_sqns(pattern,sequences,1:setsize)/sqrt(size(sqns_tempT(:,1:setsize) == sqns_tempR(:,1:setsize),1));
                elseif strcmp(touchtype,'errorStop')
                    for tt  = 1:setsize
                        validtrial = sqns_tempData(sqns_tempT(:,tt)~=0,:);
                        ptrnACorder_sqns(pattern,sequences,tt) = nanmean(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                        ptrnSDorder_sqns(pattern,sequences,tt) = nanstd(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                        ptrnSEorder_sqns(pattern,sequences,tt) = ptrnSDorder_sqns(pattern,sequences,tt)/sqrt(size(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1));
                    end
                elseif strcmp(touchtype,'Combined')
                    ft_index = find(strcmp(sqns_tempData.touchType,'freeTouch'));
                    if ~isempty(ft_index)
                        ft_trials = sqns_tempData(ft_index,:);
                    else
                        ft_trials = [];
                    end
                    all_trials = ft_trials;
                    es_index = find(strcmp(sqns_tempData.touchType,'errorStop'));
                    es_data = sqns_tempData(es_index,:);
                    if ~isempty(es_index)
                        for tt = 1:setsize
                            validtrial = es_data(es_data.responses(:,tt)~=0,:);
                            all_validtrial = [all_trials;validtrial];
                            ptrnACorder_sqns(pattern,sequences,tt) = nanmean(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt),1);
                            ptrnSDorder_sqns(pattern,sequences,tt) = nanstd(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt),1);
                            ptrnSEorder_sqns(pattern,sequences,tt) = ptrnSDorder_sqns(pattern,sequences,tt)/sqrt(size(all_validtrial.targets(:,tt) == all_validtrial.responses(:,tt),1));
                        end
                    else
                        all_validtrial = all_trials;
                        ptrnACorder_sqns(pattern,sequences,1:setsize) = nanmean(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1);
                        ptrnSDorder_sqns(pattern,sequences,1:setsize) = nanstd(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1);
                        ptrnSEorder_sqns(pattern,sequences,1:setsize) = ptrnSDorder_sqns(pattern,sequences,1:setsize)/sqrt(size(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1));
                    end
                end
                target_sqns{sequences,pattern} = [tempT(tempsqnsindex,:),tempR(tempsqnsindex,:),nansum(tempT(tempsqnsindex,:) == tempR(tempsqnsindex,:),2)==setsize];
            end
        end
        
        %collapsed starting points and orientations
        ptrnAC(pattern,1) = nanmean(nansum(tempT == tempR,2)==setsize);
        ptrnSD(pattern,1) = nanstd(nansum(tempT == tempR,2)==setsize);
        ptrnSE(pattern,1) = ptrnSD(pattern,1)/sqrt(length(nansum(tempT == tempR,2) ==setsize));
        
        if strcmp(touchtype,'freeTouch') == 1
            ptrnACorder(pattern,1:setsize) = nanmean(tempT(:,1:setsize) == tempR(:,1:setsize));
            ptrnSDorder(pattern,1:setsize) = nanstd(tempT(:,1:setsize) == tempR(:,1:setsize));
            ptrnSEorder(pattern,1:setsize) = ptrnSDorder(pattern,1:setsize)/sqrt(size(tempT(:,1:setsize) == tempR(:,1:setsize),1));
        elseif strcmp(touchtype,'errorStop')
            validtrial = PatternData2(tempT(:,tt)~=0,:);
            for tt  = 1:setsize
                ptrnACorder(pattern,tt) = nanmean(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                ptrnSDorder(pattern,tt) = nanstd(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                ptrnSEorder(pattern,tt) = ptrnSDorder(pattern,tt)/sqrt(size(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1));
            end
        elseif strcmp(touchtype,'Combined')
            ft_index = find(strcmp(PatternData2.touchType,'freeTouch'));
            if ~isempty(ft_index)
                ft_trials =  PatternData2(ft_index,:);
            else
                ft_trials = [];
            end
            all_trials = ft_trials;
            es_index = find(strcmp(PatternData2.touchType,'errorStop'));
            es_data = PatternData2(es_index,:);
            if ~isempty(es_index)
                for tt = 1:setsize
                    validtrial = es_data(es_data.responses(:,tt)~=0,:);
                    all_validtrial = [all_trials;validtrial];
                    ptrnACorder(pattern,tt) = nanmean(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt));
                    ptrnSDorder(pattern,tt) = nanstd(all_validtrial.targets(:,tt) ==all_validtrial.responses(:,tt));
                    ptrnSEorder(pattern,tt) = ptrnSDorder(pattern,tt)/sqrt(size(all_validtrial.targets(:,tt) == all_validtrial.responses(:,tt),1));

                end
            else
                 all_validtrial = all_trials;
                 ptrnACorder(pattern,1:setsize) = nanmean(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize));
                 ptrnSDorder(pattern,1:setsize) = nanstd(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize));
                 ptrnSEorder(pattern,1:setsize) = ptrnSDorder(pattern,1:setsize)/sqrt(size(all_validtrial.targets(:,1:setsize) == all_validtrial.responses(:,1:setsize),1));
            end
        end
    end
        ptrnACtable = table(patterns2,ptrnAC,ptrnSD,ptrnSE,...
            target_clc,ptrnAC_clc, ptrnSD_clc,ptrnSE_clc,...
            target_anticlc,ptrnAC_anticlc, ptrnSD_anticlc,ptrnSE_anticlc,...
            ptrntrial_clc,ptrntrial_anticlc,...
            ptrnACorder_clc, ptrnSDorder_clc,ptrnSEorder_clc,...
            ptrnACorder_anticlc, ptrnSDorder_anticlc,ptrnSEorder_anticlc,...
            ptrnACorder,ptrnSDorder,ptrnSEorder);  % table for 30 patterns and 30 pattern pairs(paired by orientation)
        
        sqnsInptrnACtable = table(ptrnAC_sqns,ptrnSD_sqns,ptrnSE_sqns,target_sqns);
        sqnsInptrnACordertable=table(ptrnACorder_sqns,ptrnSDorder_sqns,ptrnSEorder_sqns);
        if userandom ==1 & contains(participants{i},'M')
            save([filepath,touchtype '_' rule '_' num2str(setsize) '_SqnsTable_random.mat'],'*SqnsTable','sqnsACtable','stpACtable','stpACtable2','ptrnACtable','sqnsInptrnACtable','sqnsInptrnACordertable');
        else
            save([filepath,touchtype '_' rule '_' num2str(setsize) '_SqnsTable.mat'],'*SqnsTable','sqnsACtable','stpACtable','stpACtable2','ptrnACtable','sqnsInptrnACtable','sqnsInptrnACordertable');
        end
        fprintf([participants{i} 'finished \n']);
end
