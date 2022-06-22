% Model Params and Statistics (e.g. BIC, R-squared...) Table for Repeated K-fold Cross-Validation
close all,
clear,
clc;

addpath(genpath('Functions'));

%% Data Loading
dataSetName = {'A4R'; 'C4R'; 'M4R'};
ptpName = {'Adults'; 'Children'; 'Monkeys'};
ptpN = size(ptpName, 1);
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
mdlsN = size(mdls, 1);
mdlName = {'Original Model'; 
    'Model with Chunk-size'; 'Model with Chunk-number'; ...
    'Model with Path-length'; 'Model with Path-crossings'};

N = 100;
K = 3;

paramsN = NaN(ptpN, mdlsN);
deltaAICmean = NaN(ptpN, mdlsN);
AIC = NaN(N*K, mdlsN);
deltaBICmean = NaN(ptpN, mdlsN);
BIC = NaN(N*K, mdlsN);
for i = 1:ptpN
    for mdlsn = 1:mdlsN
        for n = 1:N
            for k = 1:K
                dataSetNameCV = [dataSetName{i}, '-', num2str(n), '-', num2str(k)];
                load(['FittingResults4CV\', mdls{mdlsn}, '\', dataSetNameCV]);
                AIC(K*(n-1)+k, mdlsn) = FittingResults.MSC.AIC;
                BIC(K*(n-1)+k, mdlsn) = FittingResults.MSC.BIC;
            end
        end
        paramsN(i, mdlsn) = length(FittingResults.InitialParams);
    end
    deltaAIC = AIC - AIC(:, 2);
    deltaAICmean(i, :) = round(mean(deltaAIC, 1));
    deltaBIC = BIC - BIC(:, 2);
    deltaBICmean(i, :) = round(mean(deltaBIC, 1));
end
deltaAICmean = deltaAICmean';
deltaBICmean = deltaBICmean';
paramsN = paramsN';

