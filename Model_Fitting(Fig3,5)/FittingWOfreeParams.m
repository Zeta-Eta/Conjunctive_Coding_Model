% Fitting across all Patterns without Free Params

close all,
clear,
clc;

addpath(genpath('Models'));
addpath(genpath('Functions'));

%% Data Loading & Model Choosing
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
load(['PatternSet\', dataSetName, '.mat']);

mdls = {'CCM_Og'; 'CCM_Cs'; 'CCM_Cn'; 'CCM_Pl'; 'CCM_Pc'};
% Models:
% CCM_Og [Original]
% CCM_Cs [Chunk-size]
% CCM_Cn [Chunk-number]
% CCM_Pl [Path-length]
% CCM_Pc [Path-crossings]

for mdlsn = 1:size(mdls, 1)
    ModelName = mdls{mdlsn};
    load(['FittingResults\', ModelName, '\', dataSetName, '.mat']);
    
    %% Model Parameters Setting
    CplxDefMethod = ModelName(5:6);
    
    if strcmp(CplxDefMethod, 'Pl')
        modelParams = [FittingResults.ModelParams.w, ...
            FittingResults.ModelParams.kappa, ...
            FittingResults.ModelParams.lambda, ...
            FittingResults.ModelParams.a, ...
            FittingResults.ModelParams.b, ...
            FittingResults.ModelParams.eta];
    else
        modelParams = [FittingResults.ModelParams.w, ...
            FittingResults.ModelParams.kappa, ...
            FittingResults.ModelParams.lambda, ...
            FittingResults.ModelParams.eta];
    end
    
    %% Model Fitting
    tic;
    FittingResults = ModelFittingWOfreeParams(patternSet, ModelName, ...
        modelParams, Experiment);
    fprintf(['--------------------\n', ModelName, '\nBIC = %.4f \n'], ...
        FittingResults.MSC.BIC);
    toc;
    fprintf('--------------------\n');
    
    %% Fitting Results Saving
    savePath = ['FittingResultsWOfreeParams\', ModelName(1:6), '\'];
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    save([savePath, dataSetName], 'FittingResults');
    
end
