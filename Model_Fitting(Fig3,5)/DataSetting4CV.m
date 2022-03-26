% Data and Experiment Setting for Repeated K-fold Cross-Validation

close all,
clear,
clc;

addpath(genpath('Functions'));
rng('shuffle');

N = 100; % number of repetition times 
K = 3; % K-fold

%% Data Loading
dataSetName = 'C4R';
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

load(['DataSetAfterPreprocessing\', dataSetName, '.mat']);

%% Data Shuffling & Splitting
dataN = size(data, 1);

savePath = 'PatternSet4CV\';
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

for n = 1:N
    
    CV = cvpartition(dataN, 'Kfold', K);
    
    for k = 1:K
        trainingSet = PatternSetting(data(CV.training(k), :), Experiment);
        trainingSet.originalData = [];
        testSet = PatternSetting(data(CV.test(k), :), Experiment);
        testSet.originalData = [];
        
        save([savePath, [dataSetName, '-', num2str(n), '-', num2str(k)]], ...
            'CV', 'Experiment', 'trainingSet', 'testSet');
    end
    
end




