function SortSequence_Rotated_OriStp(participants,rule,touchtype,setsize,N,usetrimed,userandom)
% add markers of sequences, patterns, starting points and orientations of the
% sequence in each trial. 
% generate a table that's more convinient for running statistics

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


% generate a table with the following vars :
% accuracy of each iems, accuracy of sequences, original sequences, 
% index of the sequence (1-360), index of the pattern (1-30), starting point (1-6), and
% orientation (1 = CW, 2 = CCW)


% clear

% participants = {'Adults','Children','MO','MG','MO&MG'};
% 
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
    % 

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
    
    
    item_acc = (dataset.targets == dataset.responses);
    sqns_acc = (sum(item_acc,2) == setsize);
    subj = dataset.ID;
    
    % code pattern, sequence, starting point, orientation
    sequence_marker = nan(size(dataset,1),1);
    pattern_marker = nan(size(dataset,1),1);
    stp_marker = nan(size(dataset,1),1);
    orientation_marker = nan(size(dataset,1),1);
   
    sequences = unique(dataset.targets,'rows');    % sequence
    oringinal_sqns = nan(size(dataset,1),4);
    
    for sq = 1:size(sequences,1)
        sequence_index{sq} = find(ismember(dataset.targets,sequences(sq,:),'rows'));
        sequence_marker(sequence_index{sq},1) = sq;
        oringinal_sqns(sequence_index{sq},:) = repmat(sequences(sq,:),size(sequence_index{sq},1),1);
    end
    [ptrnT,~] = sqns2ptrn(dataset.targets,dataset.responses,1,0);  % patterns generation,   orientaion == 1
    patterns = unique(ptrnT,'rows');
    for pattern = 1:size(patterns,1)
        pattern_index{pattern} = find(ismember(ptrnT,patterns(pattern,:),'rows'));
        pattern_marker(pattern_index{pattern},1) = pattern;
    end
    for startpoint = 1:N
        stp_index{startpoint} = find(ismember(dataset.targets(:,1),startpoint));
        stp_marker(stp_index{startpoint},1) = startpoint;
    end
    
    
    % orientation
        v = perms(1:N);
    GeSequences = unique(v(:,1:setsize),'rows');
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
    
    for trial = 1:size(dataset.targets,1)
        if ismember(dataset.targets(trial,:),clcSqns,'rows')
            orientation_marker(trial,1) = 1;
        elseif ismember(dataset.targets(trial,:),anticlcSqns,'rows')
            orientation_marker(trial,1) = 2;
        end
    end
    
    
    Infotable = table(subj,item_acc,sqns_acc,oringinal_sqns,sequence_marker,pattern_marker,stp_marker,orientation_marker);
    if userandom ==1 & contains(participants{i},'M')
        save([filepath,touchtype '_' rule '_' num2str(setsize) '_Infotable_random.mat'],'Infotable');
    else
        save([filepath,touchtype '_' rule '_' num2str(setsize) '_Infotable.mat'],'Infotable');
    end
    fprintf([participants{i} 'finished \n']);
end
