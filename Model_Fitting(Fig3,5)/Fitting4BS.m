% Fitting across all Patterns for Bootstrap

close all,
clear,
clc;

addpath(genpath('Models'));
addpath(genpath('Functions'));

N = 1000; % number of repetition times

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

for ptpn = 1:size(ptp, 1)
    for n = 1:N
        dataSetName = [ptp{ptpn}, '-', num2str(n)];
        load(['PatternSet4BS\', dataSetName]);
        
        for mdlsn = 1:size(mdls, 1)
            ModelName = mdls{mdlsn};
            
            %% Initial Parameters Setting
            tempSet = patternSet;
            setsize = Experiment.setsize;
            UckSN   = tempSet.UckSN;
            UckNN   = tempSet.UckNN;
            UpathCN = tempSet.UpathCN;
            
            CplxDefMethod = ModelName(5:6);
            %          A  |  C  |  M
            %  lambda  2  |  1  |  1
            %  kappa   30 |  10 |  15 / Cn:10
            if     strcmp(dataSetName(1), 'A')
                lambda = 2;
                kappa  = 30;
            elseif strcmp(dataSetName(1), 'C')
                lambda = 1;
                kappa  = 10;
            elseif strcmp(dataSetName(1), 'M')
                lambda = 1;
                if strcmp(CplxDefMethod, 'Cn')
                    kappa  = 10;
                else
                    kappa  = 15;
                end
            end
            
            w = 1 + zeros(1, setsize);
            eta = 1e-3;
            
            if     strcmp(CplxDefMethod, 'Cs')
                lambda = lambda + zeros(1, UckSN);
                initialParams = [w, kappa, lambda, eta];
            elseif strcmp(CplxDefMethod, 'Cn')
                lambda = lambda + zeros(1, UckNN);
                initialParams = [w, kappa, lambda, eta];
            elseif strcmp(CplxDefMethod, 'Pl')
                a = 0.1;
                b = 0;
                initialParams = [w, kappa, lambda, a, b, eta];
            elseif strcmp(CplxDefMethod, 'Pc')
                lambda = lambda + zeros(1, UpathCN);
                initialParams = [w, kappa, lambda, eta];
            else
                initialParams = [w, kappa, lambda, eta];
            end
            
            %% Model Fitting
            tic;
            FittingResults = ModelFitting(patternSet, patternSet, ModelName, ...
                initialParams, Experiment, 'LSE');
            fprintf(['--------------------\n', ModelName, ' | ', dataSetName, ...
                '\nBIC = %.4f \n'], FittingResults.MSC.BIC);
            toc;
            fprintf('--------------------\n');
            
            %% Fitting Results Saving
            savePath = ['FittingResults4BS\', ModelName(1:6), '\'];
            if ~exist(savePath, 'dir')
                mkdir(savePath);
            end
            save([savePath, dataSetName], 'FittingResults');
            
        end
    end
end
