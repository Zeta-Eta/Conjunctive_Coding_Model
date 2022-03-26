% run this script to exclude data with issues and outliners
% run it at the beginning

clear;

% add path and define data to be processed
% data files saved in 'Data' folder
addpath(genpath('DataManipulations'));

% select participant groups
% Adults = adults, sequence lenth = 4,5,6 ( main experiment)
% Children = children, sequence lenth = 4 ( main experiment)
% MO = M1, sequence lenth = 3,4 ( main experiment)
% MG = M2, sequence lenth = 3,4 ( main experiment)
% Adults_3Dots = adults, sequence lenth = 3 
% Children_3Dots = children, sequence lenth = 3 
% Adults2 = adults, sequence lenth = 4 (multiple-session experiment) 
participants = {'Adults','Children','MO','MG','Children_3Dots','Adults_3Dots','Adults2'};
rule ={'repeat'};
touchtype = {'freeTouch' 'errorStop'};
setsize = [3:6]; % AKA sequence length
N=6;

%% define how to do the screening
% Whether exclude trials that : 1- do it!, 0 - no, thanks
is_exclude_reptrials = 1;   % exclude repetitive sample sequences
is_exclude_unfinished = 1;   % exclude unfinised trials
is_exclude_reptouches = 1;   % exclude tirals with repetitive touches (i.e. touching the same location more than once)


% How to exclude RT outliners?
Outliner_group = 'session';
% all - exclude RT outliners according to all data in dataset;
% session - exclude RT outliners by session(in monkeys)/individuals(in human)

% whether exclulde session/individual participant outliners?
Exclude_session = 0;
% -1 - will not exclude any session/individual
% any number 0 ~ 1 - session with acc lower or equal to threshold will be excluded
% 'sd'- session with mean acc outside range mean +- 3sd (of all %
% sessions/individual) will be excluded, using matlab function isoutlier

% exclude sessions/pariticipants that do not have enought trials
Exclude_trialnumber = 30;
% -1 - will not exclude any sessions/pariticipants
% any number >= 1- sessions/pariticipants with trial number less than 'Exclude_trialnumber'
% will be excluded

%% just do it
% final_output=[];
for i = 1:size(participants,2)
    recordcount =0;
    % generate a log 
    log.condition = [];
    log.trialnum =[];
    log.procedure = {'original';'excluded repetetive trials';'excluded unifinished';'excluded repetitive touches';...
        'excluded outlier RT trial';'excluded outliner sessions';'excluded not enough trials'};
    log.operation = {' '; is_exclude_reptrials;is_exclude_unfinished;is_exclude_reptouches;Outliner_group;Exclude_session;Exclude_trialnumber};
    
    % load data
    filepath = ['Data/' participants{i} '/'];
    datafile = [filepath, 'dataset.mat'];
    load(datafile);
    clean_data =[];
    
    
    % change ID in children data - > all ID in format:1AM99,
    % grade-class-gender-number
    if strcmp(participants{i},'Children')
        for x = 1:size(dataset.ID,1)
            dataset.ID{x,1} = dataset.ID{x,1}(1:5);
            dataset.session{x,1} = dataset.session{x,1}(1:5);
        end
    end
    
    
    for j = 1:size(rule,2)
        for k = 1:size(touchtype,2)
            for m =setsize
                
                % find the trials in a specific condition ( according to
                % touch type, rule and setsize
                touchtype_index = find(strcmp(dataset.touchType,touchtype{k}));
                rule_index  = find(strcmp(dataset.rule,rule{j}));
                setsize_index = find(dataset.setsize==m);
                selected_index = intersect(intersect(touchtype_index,rule_index),setsize_index);
                
                % continue when there are trials in that condition:
                if ~isempty(selected_index)
                    data_temp = dataset(selected_index,:);   % data in the condition selected
                    size_original = size(data_temp,1);    % data size before doing anything
                    recordcount = recordcount +1;
                    log.condition = [log.condition;{touchtype{k},rule{j},m}];    
                    
                    % log: trial number per session/individual
                    eachsession_before = unique(data_temp.session);
                    trialnum_before  = zeros(size(eachsession_before ,1),1);
                    for x = 1:size(eachsession_before ,1)
                        session_index_before{x} = find(strcmp(data_temp.session,eachsession_before{x}));
                        trialnum_before(x,1) = length(session_index_before{x});
                    end   
                    log.originalsize{j,k}.session{m,1} = eachsession_before;
                    log.originalsize{j,k}.trialnum{m,1} = trialnum_before;
                    
                 %% exclude trials
                   % remove repetitive training data (sample), keep the
                   % first trial
                    if is_exclude_reptrials == 1
                        for y = size(data_temp,1):-1:2
                            if data_temp.targets(y,:) == data_temp.targets(y-1,:),data_temp(y,:) =[];end
                        end
                    end
                    size_exclrepdata = size(data_temp,1);
                    
                    % exclude unfinished trials
                    if is_exclude_unfinished ==1
                        if strcmp(touchtype{k},'freeTouch')
                            data_temp(data_temp.responses(:,m) ==0,:)=[];
                        elseif strcmp(touchtype{k},'errorStop')  
%                             data_temp(sum(data_temp.responses(:,1:m)~=0,2) < m,:)=[];
                            data_temp(data_temp.responses(:,1) ==0,:)=[];
                        end
                    end
                    size_exclunfdata = size(data_temp,1);
                    
                    
                    % repetitive touches (in the same trial) record
                    [sametouchlabel,sametouch] = find_rep_touch(data_temp.responses(:,1:m),m);
                    [ptrnT2,~] = sqns2ptrn(data_temp.targets(:,1:m),data_temp.responses(:,1:m),1,0);  % patterns generation,   orientaion == 0  -->30 patterns
                    patterns2 = unique(ptrnT2,'rows');                                       % all possible patterns
                    
                    for pattern = 1:size(patterns2,1)
                        PatternData = dataset(ismember(ptrnT2,patterns2(pattern,:),'rows'),:);
                        tempT = PatternData.targets; tempR = PatternData.responses;
                        [sametouchlabel_pat,sametouch_pat] = find_rep_touch(tempR(:,1:m),m);
                        if pattern ==1
                            pattern_touchsame=table(sametouchlabel_pat,sametouch_pat','VariableNames',{'touchsame',['ptrn' num2str(pattern)]});
                        else
                            pattern_touchsame =[pattern_touchsame,table(sametouch_pat','VariableNames',{['ptrn' num2str(pattern)]})];
                        end
                    end
                    
                    % exclude trials with repetitive touches
                    if is_exclude_reptouches == 1
                        if strcmp(touchtype{k},'freeTouch')
                            reptouch_index = [];
                            for  aa = 1:size(data_temp,1)
                                if length(unique(data_temp.responses(aa,1:m)))<m
                                    reptouch_index = [reptouch_index;aa];
                                end
                            end
                        elseif strcmp(touchtype{k},'errorStop')
                            reptouch_index = [];
                            for  aa = 1:size(data_temp,1)
                                if size(unique(data_temp.responses(aa,data_temp.responses(aa,1:m)~=0)),2)<sum(data_temp.responses(aa,1:m)~=0,2)
                                    reptouch_index = [reptouch_index;aa];
                                end
                            end

                        end
                       data_temp(reptouch_index,:)=[];
                    end
                    size_exclreptouchdata = size(data_temp,1);
                    
                    %% exclude outliners according to RT:
                    outliner_index = [];
                    if strcmp(Outliner_group,'session')
                        outliner_index_trial =[];
                        person = unique(data_temp.ID);
                        for n =1:size(person,1)
                            if iscell(person)
                                person_index = find(strcmp(data_temp.ID, person{n,1}));   % find each parti or session
                            else
                                person_index = find(data_temp.ID==person(n,1));   % find each parti or session
                            end
                            
                            RT_temp = data_temp.RT(person_index,1:m);
                            OutlierIdx = isoutlier(RT_temp,'mean');
%                             OutlierIdx = isoutlier(RT_temp);
                            [row,~]= find(OutlierIdx==1);
                            outliner_index = unique(row);
                            data_temp(person_index(outliner_index,1),:)=[];
                            outliner_index_trial =[outliner_index_trial;person_index(outliner_index,1)];
                        end
                    elseif strcmp(Outliner_group,'all')
                        RT_temp = data_temp.RT(:,1:m);
%                         OutlierIdx = isoutlier(RT_temp);
                        OutlierIdx = isoutlier(RT_temp,'mean');
                        [row,~]= find(OutlierIdx==1);
                        outliner_index = unique(row);
                        
                        data_temp(outliner_index,:)=[];
                        outliner_index_trial =[outliner_index_trial;outliner_index];
                    end
                    size_validdata1 = size(data_temp,1);
                    
                    % acc
                    if strcmp(rule{j},'mirror')
                        data_acc = (flipdim(data_temp.targets(:,1:m),2) == data_temp.responses(:,1:m));
                    else
                        data_acc = (data_temp.targets(:,1:m) == data_temp.responses(:,1:m));
                    end
                    % calculate acc; by session/ individual participant
                    eachsession = unique(data_temp.session,'rows');
                    trialnum = zeros(size(eachsession,1),1);
                    acc_session = zeros(size(eachsession,1),6);rt_session= zeros(size(eachsession,1),6);
                    seqacc_session = zeros(size(eachsession,1),1);
                    for x = 1:size(eachsession,1)
                        session_index{x} = find(strcmp(data_temp.session,eachsession{x}));
                        correct_index{x} = find(sum(data_acc(session_index{x},1:m),2)==m);
                        session_data_temp = data_temp(session_index{x},:);
                        trialnum(x,1) = length(session_index{x});
                        acc_session(x,1:m) = mean(data_acc(session_index{x},:),1);
                        rt_session(x,1:m) = mean(session_data_temp.RT(correct_index{x},1:m),1);
                        seqacc_session(x,1) = mean(sum(data_acc(session_index{x},1:m),2)==m,1);
                    end
                    
                    %% now, turn to session/individual participant outliners
                    if ischar(Exclude_session)   % exclude outliner according to mean
                        OutlierIdx = isoutlier(seqacc_session,'mean');   
                        [row,~]= find(OutlierIdx==1);
                        outliner_index_session = unique(row);
                    elseif ~ischar(Exclude_session)
                        if Exclude_session >=0  % exclude outliner according to threshold
                            outliner_index_session = find(seqacc_session<=Exclude_session);
                        end
                    end
                    
                    % exclude outliners (session/individual)
                    if ~isempty(outliner_index_session)
                        acc_session(outliner_index_session,:) = [];
                        rt_session(outliner_index_session,:) = [];
                        seqacc_session(outliner_index_session,:) = [];
                        trialnum(outliner_index_session,:) = [];
                        toexclude=[];
                        for y = 1: size(outliner_index_session,1)
                            toexclude = [toexclude;session_index{outliner_index_session(y,1)}];
                        end
                        data_temp(toexclude,:) = [];
                        eachsession = unique(data_temp.session);
                    end
                    size_validdata2 = size(data_temp,1);
                                    
                    %% exclude sessions/pariticipants that do not have enought trials
                    if Exclude_trialnumber >0
                        outliner_index_trialnum = find(trialnum < Exclude_trialnumber);
                        if ~isempty(outliner_index_trialnum)
                            acc_session(outliner_index_trialnum,:) = [];
                            rt_session(outliner_index_trialnum,:) = [];
                            seqacc_session(outliner_index_trialnum,:) = [];
                            trialnum(outliner_index_trialnum,:) = [];
                            toexclude=[];
                            for y = 1: size(outliner_index_trialnum,1)
                                toexclude = [toexclude;session_index{outliner_index_trialnum(y,1)}];
                            end
                            
                            data_temp(toexclude,:) = [];
                            eachsession = unique(data_temp.session);
                        end
                    end
                    size_validdata3 = size(data_temp,1);
                    clean_data =[clean_data;data_temp];
                    
                    % log: trial number per session/individual
                    eachsession_after = unique(data_temp.session,'rows');
                    trialnum_after  = zeros(size(eachsession_after ,1),1);
                    for x = 1:size(eachsession_after ,1)
                        session_index_after{x} = find(strcmp(data_temp.session,eachsession_after{x}));
                        trialnum_after(x,1) = length(session_index_after{x});
                    end
                    log.finalsize{j,k}.session{m,1} = eachsession_before;
                    log.finalsize{j,k}.trialnum{m,1} = trialnum_before;
                    
                    %% log: trial number
                    log.trialnum =  [log.trialnum,[size_original;size_exclrepdata;size_exclunfdata;size_exclreptouchdata;size_validdata1;size_validdata2;size_validdata3]];
                    log.sametouch{recordcount,1} = table(sametouchlabel,sametouch');
                    log.pattern_touchsame{recordcount,1} =pattern_touchsame;
                    
                  %% output for plotting: mean item acc and rt dataset
                    % after exclusions of outliners
%                     final_output = [final_output;
%                         table(repmat(string(participants{i}),size(acc_session,1),1),...
%                         repmat(string(rule{j}),size(acc_session,1),1),...
%                         repmat(string(touchtype{k}),size(acc_session,1),1),...
%                         repmat(num2str(m),size(acc_session,1),1),string(eachsession),acc_session,rt_session,trialnum)];
                end
            end
        end
    end
    % save the new clean dataset and a log file
    dataset = clean_data;
    save([filepath '/clean_dataset.mat'],'dataset');  % save data set
    log.output = table(log.procedure,log.operation ,log.trialnum,'VariableNames',{'data','operation','trialnum'});
    save([filepath '/log.mat'],'log');  % save log
    clear log pattern_touchsame;
    
end


