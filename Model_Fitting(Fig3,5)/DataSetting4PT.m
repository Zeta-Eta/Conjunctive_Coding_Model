% Data and Experiment Setting for Random Permutation Tests

close all,
clear,
clc;

addpath(genpath('Functions'));
rng('shuffle');

N = 1000; % number of repetition times

%% Data Loading
dataSetName = {'A4R'; 'C4R'; 'M4R'};
% [Dataset Name]
% [Participant] + [Setsize] + [Rule]
%  A/C/M/MO/MG  +   4/5/6   +  R/M
% e.g. A4R / C4R / M4R / MO4R / MG4R
% [Participant]
% A: Adults | C: Children | M: Monkeys
% MO: Monkey Ocean | MG: Monkey George
% [Setsize]
% 4/5/6 Targets
% [Rule]
% R: Repeat | M: Mirror

ptpN = size(dataSetName, 1);
comb = nchoosek(1:ptpN, 2);

for combn = 1:size(comb, 1)
    dataSetName1 = dataSetName{comb(combn, 1)};
    load(['DataSetAfterPreprocessing\', dataSetName1, '.mat']);
    if strcmp(dataSetName1(1), 'M')
        data.ID = cellstr(num2str(data.ID));
    else
        data.date = cellstr(datestr(data.date));
    end
    data1 = data;
    participant1 = Experiment.participant;
    dataN1 = size(data1, 1);
    
    dataSetName2 = dataSetName{comb(combn, 2)};
    load(['DataSetAfterPreprocessing\', dataSetName2, '.mat']);
    if strcmp(dataSetName2(1), 'M')
        data.ID = cellstr(num2str(data.ID));
    else
        data.date = cellstr(datestr(data.date));
    end
    data2 = data;
    participant2 = Experiment.participant;
    dataN2 = size(data2, 1);
    
    data = [data1; data2];
    dataN = dataN1 + dataN2;
    dataSetNameComb = [dataSetName1(1), dataSetName2(1)];
    
    Experiment.dataNbefore = [];
    Experiment.dataNafter = [];
    Experiment.replacementER = [];
    
    %% Data Shuffling & Splitting
    savePath = 'PatternSet4PT\';
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    
    for n = 1:N
        
        randpermID = randperm(dataN);
        randpermID1 = randpermID(1:dataN1);
        randpermID2 = randpermID(dataN1+1:end);
        
        Experiment.randpermID = randpermID;
        
        Experiment.dataN = dataN1;
        Experiment.participant = participant1;
        patternSet = PatternSetting(data(randpermID1, :), Experiment);
        patternSet.originalData = [];
        save([savePath, [dataSetName1, '-', num2str(n), ...
            '-', dataSetNameComb]], 'Experiment', 'patternSet');
        
        Experiment.dataN = dataN2;
        Experiment.participant = participant2;
        patternSet = PatternSetting(data(randpermID2, :), Experiment);
        patternSet.originalData = [];
        save([savePath, [dataSetName2, '-', num2str(n), ...
            '-', dataSetNameComb]], 'Experiment', 'patternSet');
    end
    
    
end

