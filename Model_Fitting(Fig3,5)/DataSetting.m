% Data Setting

close all,
clear,
clc;

addpath(genpath('Functions'));

%                           1      2     3     4
flowCtrl = [0 0 0 0]; % [0/1/2/3  0/1  0/1/2  0/1]

% [1 1 1 1] and [2 1 1 1] are common options

%% 1.1 Data Processing
if flowCtrl(1) == 1
    %% 1.1.1 Experiment Setting
    setsize     = 4;           % Sequence Length
    N           = 6;           % Number of Dots around a Circle
    rule        = "repeat";    % repeat | mirror
    touchType   = "freeTouch"; % errorStop | freeTouch
    participant = "Children";        % Adults | Children | MG | MO
    
    chosenData  = "Datasets/Dataset_Children_4dots";
    % Dataset File Names:
    % Dataset_Adults_3-6dots
    % Dataset_Children_3dots
    % Dataset_Children_4dots
    % Dataset_Monkey_George_3-4dots
    % Dataset_Monkey_Ocean_3-4dots
    
    %% 1.1.2 Data Loading & Preprocessing
    [Experiment, data, dataSetName] = Preprocessing(...
        setsize, N, rule, touchType, participant, chosenData);
    
    % [Data Set Name]
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
    
    %% 1.1.3 Item Layout Index Alignment
    %
    %        Adults           Children & MO              MG
    %   (Unified Layout)
    %         1  2                 6  1                 5  6
    %       6      3             5      2             4      1
    %         5  4                 4  3                 3  2
    
    if strcmp(Experiment.participant, "Adults")
        r = 0;
    elseif strcmp(Experiment.participant, "Children") || strcmp(Experiment.participant, "MO")
        r = 1;
    elseif strcmp(Experiment.participant, "MG")
        r = 2;
    end
    
    data.targets = mod(data.targets + r, N);
    data.targets(data.targets == 0) = N;
    
    data.responses = mod(data.responses + r, N);
    data.responses(data.responses == 0) = N;
    
end

%% 1.2 Combine together Monkeys' Data
if flowCtrl(1) == 2
    dataSetName1 = 'MG3R'; % MG+3/4+R/M
    dataSetName2 = 'MO3R'; % MO+3/4+R/M
    dataSetName  = 'M3R';  % M +3/4+R/M
    
    load(['DataSetAfterPreprocessing\', dataSetName1, '.mat']);
    data1 = data;
    dataNbefore1 = Experiment.dataNbefore;
    dataNafter1 = Experiment.dataNafter;
    
    load(['DataSetAfterPreprocessing\', dataSetName2, '.mat']);
    data2 = data;
    dataNbefore2 = Experiment.dataNbefore;
    dataNafter2 = Experiment.dataNafter;
    
    data = [data1; data2];
    dataNbefore = dataNbefore1 + dataNbefore2;
    dataNafter = dataNafter1 + dataNafter2;
    replacementER = (dataNbefore - dataNafter)/dataNbefore;
    
    Experiment.participant = "Monkeys";
    Experiment.dataNbefore = dataNbefore;
    Experiment.dataNafter = dataNafter;
    Experiment.replacementER = replacementER;
    
end

%% 1.3 Load the Data Set after Preprocessing
if flowCtrl(1) == 3
    dataSetName = 'C4R';
    load(['DataSetAfterPreprocessing\', dataSetName]);
end

%% 2 Save the Data Set after Preprocessing
if flowCtrl(2) == 1
    savePath = 'DataSetAfterPreprocessing\';
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    save([savePath, dataSetName], 'data', 'Experiment');
end

%% 3.1 Pattern Setting
if flowCtrl(3) == 1
    patternSet = PatternSetting(data, Experiment);
end

%% 3.2 Sequence Setting
if flowCtrl(3) == 2
    theta = 0;
    sequenceSet = SequenceSetting(data, Experiment, theta);
end

%% 4 Save the Pattern/Sequence Set
if flowCtrl(4) == 1
    if flowCtrl(3) == 1
        savePath = 'PatternSet\';
        if ~exist(savePath, 'dir')
            mkdir(savePath);
        end
        save([savePath, dataSetName], 'patternSet', 'Experiment');
    elseif flowCtrl(3) == 2
        savePath = 'SequenceSet\';
        if ~exist(savePath, 'dir')
            mkdir(savePath);
        end
        save([savePath, dataSetName], 'sequenceSet', 'Experiment');
    end
end


