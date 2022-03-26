% Fitting across all Patterns with the Central Tendency Measures of the Parameters in Bootstrap

close all,
clear,
clc;

addpath(genpath('Models'));
addpath(genpath('Functions'));

N = 1000; % number of repetition times
CTM = 'median'; % Central Tendency Measures: 'median' or 'mean'

%% Data Loading & Model Choosing
ptp = {'A4R'; 'C4R'; 'M4R'};
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

mdls = {'CCM_Og'; 'CCM_Cs'; 'CCM_Cn'; 'CCM_Pl'; 'CCM_Pc'};
% Models:
% CCM_Og [Original]
% CCM_Cs [Chunk-size]
% CCM_Cn [Chunk-number]
% CCM_Pl [Path-length]
% CCM_Pc [Path-crossings]

for mdlsn = 1:size(mdls, 1)
    ModelName = mdls{mdlsn};
    
    dataSetNameBS = [ModelName, '-BS-', num2str(N), '.mat'];
    params = load(['FittingResults4BS\Parameters\', dataSetNameBS]);
    
    %% Fixed Model Parameters Setting
    
    w = eval(['squeeze(' CTM '(params.w, ''omitnan''))']);
    w = w./sum(w, 1);
    
    lambda = eval(['squeeze(' CTM '(params.lambda, ''omitnan''))']);
    
    kappa = eval([CTM '(params.kappa, ''omitnan'')']);
    eta = eval([CTM '(params.eta, ''omitnan'')']);
    
    CplxDefMethod = ModelName(5:6);
    if strcmp(CplxDefMethod, 'Pl')
        a = eval([CTM '(params.a, ''omitnan'')']);
        b = eval([CTM '(params.b, ''omitnan'')']);
        fixedParams = [w; kappa; lambda; a; b; eta];
    else
        fixedParams = [w; kappa; lambda; eta];
    end
    
    %% Model Fitting
    for ptpn = 1:size(ptp, 1)
        
        dataSetName = ptp{ptpn};
        load(['PatternSet\', dataSetName, '.mat']);
        
        tic;
        FittingResults = ModelFittingWOfreeParams(patternSet, ModelName, ...
            fixedParams(:, ptpn)', Experiment);
        fprintf(['--------------------\n', ModelName, ' | ', dataSetName, ...
            '\nBIC = %.4f \n'], FittingResults.MSC.BIC);
        toc;
        fprintf('--------------------\n');
        
        %% Fitting Results Saving
        pathName = ['FittingResults_', CTM, 'PinBS\', ModelName(1:6), '\'];
        if ~exist(pathName, 'dir')
            mkdir(pathName);
        end
        save([pathName, dataSetName], 'FittingResults');
        
    end
end
