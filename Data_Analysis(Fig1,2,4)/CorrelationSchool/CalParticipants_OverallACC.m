% calculate overall accuracy of each individuals ( regardless of patterns)

warning('off');

load('data/clean_dataset.mat');
addpath('func')

rule ={'repeat','mirror'};
touchtype ='freeTouch';   %  ''freeTouch'|'Combined'
% setsize = 4:6;
overall_table = [];
for a = 1:size(rule,2)
    data = dataset(strcmp(rule{a},dataset.rule) ...
        & strcmp(touchtype,dataset.touchType),:);
    
    Participants = unique(data.ID,'rows');
    for i =1:size(Participants,1)
        parti_index = strcmp(data.ID,Participants{i});
        parti_data = data(parti_index,:);
        
        itme_rt(i,1:4) = mean(parti_data.RT);
         
        if strcmp(rule{a}, 'mirror')
            item_acc(i,1:4) = mean(flipdim(parti_data.targets,2) == parti_data.responses);
            sqns_acc(i,1) = mean(sum(flipdim(parti_data.targets,2) == parti_data.responses,2)==4);
        else
            
            item_acc(i,1:4) = mean(parti_data.targets == parti_data.responses);
            sqns_acc(i,1) = mean(sum(parti_data.targets == parti_data.responses,2)==4);
        end
        
        parti_table = table(string(Participants{i}), string(rule{a}),itme_rt(i,:),item_acc(i,:),sqns_acc(i,:), ...
                            'VariableName',{'Participant','Rule','RT','itemACC','ACC'});
        overall_table = [overall_table;parti_table];
    end
end


%%
save('OverallTable.mat','overall_table','Participants');