function CombineMonkeys(Target_parti,participants,usetrimed,userandom)

% combine data from different monkeys, and save a combined dataset

% clear;

% usetrimed=1;


for i =1:size(Target_parti,2)
    dataset = [];
    for j = 1:size(participants,2)
        if contains(Target_parti{i},participants{j})
            % whether used random selected trials
            if userandom ==1 & contains(participants{j},'M')
                prelabel = 'randomSelect';
            else
                prelabel = 'clean';
            end
            
            filepath = ['Data/' participants{j} '/'];
            % whether use trimmed data
            if usetrimed==1 & exist([filepath, prelabel, '_dataset_trimmed.mat'],'file')
                datafile = [filepath, prelabel, '_dataset_trimmed.mat'];
            else
                datafile = [filepath, prelabel, '_dataset.mat'];
            end
            a= load(datafile);
            % formatting
            % delete extra column
            if size(a.dataset.targets,2)>4
                a.dataset.targets(:,5:end)=[];
                a.dataset.responses(:,5:end)=[];
                a.dataset.RT(:,5:end)=[];
            end
            % change format
            if ~iscell(a.dataset.ID)
                a.dataset.ID = num2cell(a.dataset.ID);
            end
            % merge data
            dataset = [dataset;a.dataset];
            clear a
        end
    end
    % save output
    if usetrimed==1
        save(['Data/' Target_parti{i} '/' prelabel, '_dataset_trimmed.mat'],'dataset');  % save data set
    else
        save(['Data/' Target_parti{i} '/' prelabel, '_dataset.mat'],'dataset');  % save data set
    end
    clear dataset
end