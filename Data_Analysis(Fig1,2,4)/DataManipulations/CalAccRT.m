function final_output = CalAccRT(participants,rule,touchtype,setsize,usetrimed)
% calculate accuracy and rt by sessions in monkey and by participants in
% human beings


% usetrimed=1;
warning('off')
final_output=[];
for i = 1:size(participants,2)
    filepath = ['Data/' participants{i} '/'];
    % use the 'clean' dataset
    if usetrimed==1 & exist([filepath, 'clean_dataset_trimmed.mat'],'file')
        datafile = [filepath, 'clean_dataset_trimmed.mat'];
    else
        datafile = [filepath, 'clean_dataset.mat'];
    end
    a = load(datafile);
    dataset = a.dataset;
    for j = 1:size(rule,2)
        for k = 1:size(touchtype,2)
            for m =setsize
                if strcmp(touchtype{k},'Combined') & contains(participants{i},'M')
                    touchtype_index = [1:size(dataset,1)];
                else
                    touchtype_index = find(strcmp(dataset.touchType,touchtype{k}));
                end
                rule_index  = find(strcmp(dataset.rule,rule{j}));
                setsize_index = find(dataset.setsize==m);
                selected_index = intersect(intersect(touchtype_index,rule_index),setsize_index);
                if ~isempty(selected_index)
                    data_temp = dataset(selected_index,:);   % data in the condition selected
                    eachsession = unique(data_temp.session,'rows');
                    trialnum = zeros(size(eachsession,1),1);
                    acc_session = zeros(size(eachsession,1),6);rt_session= zeros(size(eachsession,1),6);
                    seqacc_session = zeros(size(eachsession,1),1);
                    acc_session_std = zeros(size(eachsession,1),6);rt_session_std= zeros(size(eachsession,1),6);
                    seqacc_session_std  = zeros(size(eachsession,1),1);
                    
                    % acc
                    if strcmp(rule{j},'mirror')
                        data_acc = (flipdim(data_temp.targets(:,1:m),2) == data_temp.responses(:,1:m));
                    else
                        data_acc = (data_temp.targets(:,1:m) == data_temp.responses(:,1:m));
                    end
                    for x = 1:size(eachsession,1)
                        session_index{x} = find(strcmp(data_temp.session,eachsession{x}));
                        % correct trials
                        correct_index{x} = find(sum(data_acc(session_index{x},1:m),2)==m);
                        session_data_temp = data_temp(session_index{x},:);
                        trialnum(x,1) = length(session_index{x});
                        % item accuracy
                        if strcmp(touchtype{k},'freeTouch') == 1
                            acc_session(x,1:m) = mean(data_acc(session_index{x},:),1);
                            acc_session_std(x,1:m) = std(data_acc(session_index{x},:),1);
                        elseif strcmp(touchtype{k},'errorStop') == 1
                            for tt  = 1:m
                                validtrial = session_data_temp(session_data_temp.responses(:,tt)~=0,:);
                                if strcmp(rule{j},'mirror')
                                    acc_session(x,tt) = mean(validtrial.targets(:,m-tt+1) ==validtrial.responses(:,tt));
                                    acc_session_std(x,tt) = std(validtrial.targets(:,m-tt+1) ==validtrial.responses(:,tt),1);
                                else
                                    acc_session(x,tt) = mean(validtrial.targets(:,tt) ==validtrial.responses(:,tt));
                                    acc_session_std(x,tt) = std(validtrial.targets(:,tt) ==validtrial.responses(:,tt),1);
                                end
                            end
                        elseif strcmp(touchtype{k},'Combined') == 1
                            ft_index = find(strcmp(session_data_temp.touchType,'freeTouch'));
                            if length(ft_index)~=0
                                ft_acc = mean(data_acc(session_index{x}(ft_index),:),1);
                                ft_trialnum = size(ft_index,1);
                                ft_acc_data = data_acc(session_index{x}(ft_index),:);
                            else
                                ft_acc = zeros(1,m);ft_trialnum=0;
                                ft_acc_data = [];
                            end
                            
                            es_index = find(strcmp(session_data_temp.touchType,'errorStop'));
                            es_session_data = session_data_temp(es_index,:);
                            if length(es_index)~=0
                                for tt = 1:m
                                    validtrial = es_session_data(es_session_data.responses(:,tt)~=0,:);
                                    es_trialnum(1,tt) = size(validtrial,1);
                                    if strcmp(rule{j},'mirror')
                                        es_acc(1,tt) = nanmean(validtrial.targets(:,m-tt+1) ==validtrial.responses(:,tt));
                                        es_acc_data{1,tt} = validtrial.targets(:,m-tt+1) ==validtrial.responses(:,tt);
                                    else
                                        es_acc(1,tt) = nanmean(validtrial.targets(:,tt) ==validtrial.responses(:,tt));
                                        es_acc_data{1,tt} = validtrial.targets(:,tt) ==validtrial.responses(:,tt);
                                    end
                                end
                            else
                                es_acc = zeros(1,m);es_trialnum=zeros(1,m);
                                es_acc_data =cell(1,m);
                            end
                            for tt = 1:m
                                acc_session(x,tt) = (ft_acc(1,tt)*ft_trialnum + es_acc(1,tt) *es_trialnum(1,tt))/(ft_trialnum+es_trialnum(1,tt));
                                if ft_acc_data
                                    acc_session_std(x,tt) = nanstd([ft_acc_data(:,tt);es_acc_data{1,tt}],1);
                                else
                                    acc_session_std(x,tt) = nanstd(es_acc_data{1,tt},1);
                                end
                            end
                        end
                        % rt in correct trials
                        rt_session(x,1:m) = mean(session_data_temp.RT(correct_index{x},1:m),1);
                        rt_session_std(x,1:m) = std(session_data_temp.RT(correct_index{x},1:m),1);
                        % sequence accuracy
                        seqacc_session(x,1) = mean(sum(data_acc(session_index{x},1:m),2)==m,1);
                        seqacc_session_std(x,1) = std(sum(data_acc(session_index{x},1:m),2)==m,1);
                    end
                    final_output = [final_output;
                        table(repmat(string(participants{i}),size(acc_session,1),1),...
                        repmat(string(rule{j}),size(acc_session,1),1),...
                        repmat(string(touchtype{k}),size(acc_session,1),1),...
                        repmat(string(m),size(acc_session,1),1),string(eachsession),acc_session,rt_session,seqacc_session,trialnum,acc_session_std,rt_session_std,seqacc_session_std)];
                end
            end
        end
    end
end

if ~exist('AccuracyAndRT','dir')
    mkdir('AccuracyAndRT');
end
save([pwd '\AccuracyAndRT\all_ACC.mat'],'final_output');