% % calculate overall accuracy of each individuals ( regardless of patterns)

clear;
warning('off');

load('data/clean_dataset.mat');
addpath('func')

rule ='repeat';
touchtype ='freeTouch';   %  ''freeTouch'|'Combined'
N = 6;
setsize = 4;
orientation = 0 ;

% extract patterns 
v = num2cell(repmat(1:N,setsize,1),2);
[v{setsize:-1:1}] = ndgrid(v{:});
mdlTypes = reshape(cat(setsize,v{:}),[],setsize);
GeSequences = [];

for type = 1:size(mdlTypes,1)
    if size(unique(mdlTypes(type,:)),2)==setsize
        GeSequences = [GeSequences;mdlTypes(type,:)];
    end
end

[ptrnT,~] = sqns2ptrn(GeSequences,GeSequences,1,orientation);  % patterns generation,
patterns = unique(ptrnT,'rows');            
%% calculate accuracy and rt
all_table = [];

data = dataset(strcmp(rule,dataset.rule) ...
    & strcmp(touchtype,dataset.touchType),:);

Participants = unique(data.ID,'rows');
for i =1:size(Participants,1)
    parti_index = strcmp(data.ID,Participants{i});
    parti_data = data(parti_index,:);
    
    
    [ptrnT,ptrnR,~] = sqns2ptrn(parti_data.targets,parti_data.responses,1,0);
    
    all_patterns = unique(ptrnT,'rows');
    
    pattern_rt = zeros(size(all_patterns,1),4);
    pattern_acc = zeros(size(all_patterns,1),4);
    pattern_sqns_acc = zeros(size(all_patterns,1),1);
    item_comp = zeros(size(all_patterns,1),4);
    sqns_comp = zeros(size(all_patterns,1),1);
    chunk_num = zeros(size(all_patterns,1),1);
    
    chunk_index{i,1} = [];
    nochunk_index{i,1} = [];
    triangle_index{i,1} =[];
    
    pattern_index30 = zeros(size(all_patterns,1),1);
    for j = 1:size(all_patterns,1)
        pattern_index30(j,1) = find(sum(patterns(:,1:4) == all_patterns(j,:),2)==4);
        
        item_comp(j,:) =  GenDistraction(all_patterns(j,:));
        sqns_comp(j,1) = sum(item_comp(j,:),2);
        
        pattern_index = find(sum(ptrnT == all_patterns(j,:),2)==4);
        % cal target distance:
        target_dis = abs( all_patterns(j,1:end-1)- all_patterns(j,2:end));
        if sum(target_dis==1,2)==0
            chunk_num(j,1) =4;
            nochunk_index{i,1} = [nochunk_index{i,1};pattern_index];
        elseif sum(target_dis==1,2)==1
            chunk_num(j,1) =3;
            chunk_index{i,1} = [chunk_index{i,1};pattern_index];
        elseif sum(target_dis==1,2)==2
            chunk_num(j,1) =2;
            chunk_index{i,1} = [chunk_index{i,1};pattern_index];
        else
            chunk_num(j,1) =1;
            chunk_index{i,1} = [chunk_index{i,1};pattern_index];
        end
        
        if sum(all_patterns(j,1:3) == [1 2 6],2)==3
             triangle_index{i,1} = [triangle_index{i,1};pattern_index];
        end
        

        pattern_rt(j,1:4)=mean(parti_data.RT(pattern_index,1:4));        
        if strcmp(rule, 'mirror')
            pattern_acc(j,1:4) = mean(flipdim(parti_data.targets(pattern_index,1:4),2) == parti_data.responses(pattern_index,1:4));
            pattern_sqns_acc(j,1) = mean(sum(flipdim(parti_data.targets(pattern_index,1:4),2) == parti_data.responses(pattern_index,1:4),2)==4);
        else
            pattern_acc(j,1:4) = mean(parti_data.targets(pattern_index,1:4) == parti_data.responses(pattern_index,1:4));
            pattern_sqns_acc(j,1) = mean(sum(parti_data.targets(pattern_index,1:4) == parti_data.responses(pattern_index,1:4),2)==4);
        end
    end
    chunk_individual_rt(i,1:4) = mean(parti_data.RT(chunk_index{i,1},1:4));
    nochunk_individual_rt(i,1:4) = mean(parti_data.RT(nochunk_index{i,1},1:4));
    if strcmp(rule, 'mirror')
        chunk_individual_acc(i,1:4) = mean(flipdim(parti_data.targets(chunk_index{i,1},1:4),2) == parti_data.responses(chunk_index{i,1},1:4));
        chunk_individual_sqns_acc(i,1) = mean(sum(flipdim(parti_data.targets(chunk_index{i,1},1:4),2) == parti_data.responses(chunk_index{i,1},1:4),2)==4);
        nochunk_individual_acc(i,1:4) = mean(flipdim(parti_data.targets(nochunk_index{i,1},1:4),2) == parti_data.responses(nochunk_index{i,1},1:4));
        nochunk_individual_sqns_acc(i,1) = mean(sum(flipdim(parti_data.targets(nochunk_index{i,1},1:4),2) == parti_data.responses(nochunk_index{i,1},1:4),2)==4);


    else 
        chunk_individual_acc(i,1:4) = mean(parti_data.targets(chunk_index{i,1},1:4) == parti_data.responses(chunk_index{i,1},1:4));
       chunk_individual_sqns_acc(i,1) = mean(sum(parti_data.targets(chunk_index{i,1},1:4) == parti_data.responses(chunk_index{i,1},1:4),2)==4);
        nochunk_individual_acc(i,1:4) = mean(parti_data.targets(nochunk_index{i,1},1:4) == parti_data.responses(nochunk_index{i,1},1:4));
       nochunk_individual_sqns_acc(i,1) = mean(sum(parti_data.targets(nochunk_index{i,1},1:4) == parti_data.responses(nochunk_index{i,1},1:4),2)==4);
    end
    
    parti_table = table(repmat(string(Participants{i}),size(all_patterns,1),1),repmat(string(rule),size(all_patterns,1),1),pattern_index30,all_patterns,sqns_comp,chunk_num,...
        pattern_rt,pattern_acc,pattern_sqns_acc, ...
        'VariableName',{'Participant','Rule','PatternIndex','Pattern','Complexity','ChunkNumber','RT','itemACC','ACC'});
      
    allparti{i,1} = parti_table ;
    
end
chunk_nochunk_table = table(string(Participants),chunk_individual_rt,chunk_individual_acc,chunk_individual_sqns_acc,...
        nochunk_individual_rt,nochunk_individual_acc,nochunk_individual_sqns_acc);

save('PtrnTable.mat','allparti','chunk_nochunk_table');
