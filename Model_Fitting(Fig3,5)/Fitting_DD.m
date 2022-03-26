% Fitting across all Patterns (with some other Different Distribution)

close all,
clear,
clc;

addpath(genpath('Models'));
addpath(genpath('Functions'));

%% Data Loading & Model Choosing
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
load(['PatternSet\', dataSetName, '.mat']);

ModelName = 'CCM_Og4DD';
% Model:
% CCM_Og4DD [Original Version for Different Distributions]

dstrbtns1 = {'Exp'; 'Norm'; 'logNorm'; 'Beta'; 'ExpCDF'};
dstrbtns2 = {'vonMises'; 'warpNorm'};

D1 = dstrbtns1{1};
D2 = dstrbtns2{1};

etaOn = 1;

%% Initial Parameters Setting
tempSet = patternSet;
setsize = Experiment.setsize;

%          A  |  C  |  M
%  lambda  2  |  1  |  1
%  kappa   30 |  10 |  15
if strcmp(dataSetName(1), 'A')
    lambda = 2 ;
    kappa  = 30;
elseif strcmp(dataSetName(1), 'C')
    lambda = 1 ;
    kappa  = 10;
elseif strcmp(dataSetName(1), 'M')
    lambda = 1 ;
    kappa  = 15;
end

w  = 1 + zeros(1, setsize);

initialParams = [w, kappa, lambda];

if etaOn == 1
    eta = 1e-3;
    initialParams = [initialParams, eta];
    DDEname = [D1, '-', D2, '-etaOn'];
else
    DDEname = [D1, '-', D2, '-etaOff'];
end

%% Model Fitting
tic;
FittingResults = ModelFitting_DD(patternSet, patternSet, ModelName, ...
    initialParams, Experiment, 'LSE', D1, D2, etaOn);
fprintf(['--------------------\n', ModelName, '\n', DDEname, ...
    '\nBIC = %.4f \n'], FittingResults.MSC.BIC);
toc;
fprintf('--------------------\n');

%% Fitting Results Saving
savePath = ['FittingResults_DD\', DDEname, '\'];
if ~exist(savePath, 'dir')
    mkdir(savePath);
end
save([savePath, dataSetName], 'FittingResults');

