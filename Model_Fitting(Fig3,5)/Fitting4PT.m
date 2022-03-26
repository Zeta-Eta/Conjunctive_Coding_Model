% Fitting across all Patterns for Random Permutation Tests

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

ptpN = size(ptp, 1);
comb = nchoosek(1:ptpN, 2);

mdls = {'CCM_Og'; 'CCM_Cs'; 'CCM_Cn'; 'CCM_Pl'; 'CCM_Pc'};
% Models:
% CCM_Og [Original]
% CCM_Cs [Chunk-size]
% CCM_Cn [Chunk-number]
% CCM_Pl [Path-length]
% CCM_Pc [Path-crossings]

for ptpn = 1:ptpN
    for combn = 1:size(comb, 1)
        for n = 1:N
            dataSetName = [ptp{ptpn}, '-', num2str(n), '-', ptp{comb(combn, 1)}(1), ptp{comb(combn, 2)}(1)];
            load(['PatternSet4PT\', files(k).name]);
            
            for mdlsn = 1%:size(mdls, 1)
                ModelName = mdls{mdlsn};
                
                %% Initial Parameters Setting
                tempSet = patternSet;
                setsize = Experiment.setsize;
                UckSN   = tempSet.UckSN;
                UckNN   = tempSet.UckNN;
                UpathCN = tempSet.UpathCN;
                
                lambda = 1;
                kappa  = 10;
                w      = 1 + zeros(1, setsize);
                eta    = 1e-3;
                
                CplxDefMethod = ModelName(5:6);
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
                fprintf(['--------------------\n', ModelName, '\n', dataSetName, ...
                    '\nBIC = %.4f \n'], FittingResults.MSC.BIC);
                toc;
                fprintf('--------------------\n');
                
                %% Fitting Results Saving
                savePath = ['FittingResults4PT\', ModelName(1:6), '\'];
                if ~exist(savePath, 'dir')
                    mkdir(savePath);
                end
                save([savePath, dataSetName], 'FittingResults');
                
            end
        end
    end
end
