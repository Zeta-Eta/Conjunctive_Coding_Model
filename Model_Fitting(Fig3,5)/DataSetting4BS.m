% Data and Experiment Setting for Bootstrap

close all,
clear,
clc;

addpath(genpath('Functions'));
rng('shuffle');

N = 1000; % number of repetition times 

%% Data Loading
dataSetName = 'M4R';
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

%% Data Resampling
dataN = size(data, 1);

savePath = 'PatternSet4BS\';
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

for n = 1:N
    bsID = randi(dataN, dataN, 1);
    Experiment.bsID = bsID;
    
    patternSet = PatternSetting(data(bsID, :), Experiment);
    patternSet.originalData = [];
    
    save([savePath, [dataSetName, '-', num2str(n)]], ...
        'Experiment', 'patternSet');
end




