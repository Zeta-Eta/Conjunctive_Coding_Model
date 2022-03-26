%% calculate correlation btw school performance and task performance
clear;
load('data/G1_Score_191023');
load('PtrnTable.mat')    % pattern
load('OverallTable.mat')   % table of overall acc
addpath('func')
%% Exam score

for i = 1:size(Score,1)
    Score.Code{i} = Score.Code{i}(1:5);
end
Score(isnan(Score.Chinese) | isnan(Score.Maths),:)=[];
rawAverage = mean([Score.Chinese,Score.Maths],2);

TransChinese = -log10(100-Score.Chinese);
TransMath = -log10(100-Score.Maths);
TransAverage = -log10(100-rawAverage);
parti_code = Score.Code;
% parti_code = unique(Score.Code,'rows');


%% Combine data
hugetable = [];
temp_count = 0;
for j = 1:size(Participants,1)        % participants in experiment
    for i = 1:size(parti_code,1)    % participant in 'exam score'
        
        if strcmp(parti_code{i},Participants{j})
            temp_count = temp_count + 1;
            if strcmp(Participants{j}(3),'M')
                gender = 1;
            else
                gender = 0;
            end
            classindex =string(Participants{j}(2));
            final_table(temp_count,:) = table(temp_count, string(Participants{j}),classindex,gender,...
                overall_table.RT(j,:),overall_table.itemACC(j,:),overall_table.ACC(j),...
                Score.Chinese(i),Score.Maths(i),rawAverage(i),TransChinese(i),TransMath(i),TransAverage(i),...
                chunk_nochunk_table.chunk_individual_sqns_acc(j,1),chunk_nochunk_table.nochunk_individual_sqns_acc(j,1),...
                'VariableName',{'Count','Participant','class','gender','RT','itemACC','ACC','rawChinese',...
                'rawMath','rawAverage','TransChinese','TransMath','TransAverage','weightedchunkACC','weightednochunkACC'});
                      
        end
    end
end


%% Plots
map = [60,60,60
    98,98,98
    150,150,150
    190,190,190]/255;

whether_excluOutlier = 1;
corr_type = 'Spearman'; %'Spearman'|'Pearson'
tempy = final_table.rawAverage;
tempx = [final_table.weightedchunkACC,final_table.weightednochunkACC];

      
[samplesize,newRHO,newp_cor] = corr_whetherChunk(tempx,tempy,corr_type ,map,whether_excluOutlier);
%



