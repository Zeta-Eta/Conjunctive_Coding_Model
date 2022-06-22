% Model Params and Statistics (e.g. BIC, R-squared...) Table for Repeated K-fold Cross-Validation using some other Different Distributions
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

dstrbtns1 = {'Exp'; 'Norm'; 'logNorm'; 'Beta'; 'ExpCDF'}; 
dstrbtns2 = {'vonMises'; 'warpNorm'}; 
DDname = cellfun(@(x) strcat(x, '-', dstrbtns2{1}), dstrbtns1, 'UniformOutput', false);
DDname = [DDname; [dstrbtns1{1}, '-', dstrbtns2{2}]; [DDname{1}, '_without_eta']];
DDk = [1:7];%
DDname = DDname(DDk);
dN = size(DDname, 1);
dNv = dN - [1, 1, 0];% if the last was chosen
% dNv = dN - [0, 0, 0];% if the last was chosen

N = 100;
K = 3;

paramsN = NaN(ptpN, dN);
deltaAICmean = NaN(ptpN, dN);
AIC = NaN(N*K, dN);
deltaBICmean = NaN(ptpN, dN);
BIC = NaN(N*K, dN);
for i = 1:ptpN
    for dn = 1:dNv(i)
        for n = 1:N
            for k = 1:K
                dataSetNameCV = [dataSetName{i}, '-', num2str(n), '-', num2str(k)];
                load(['FittingResults4DDCV\', DDname{dn}, '\', dataSetNameCV]);
                AIC(K*(n-1)+k, dn) = FittingResults.MSC.AIC;
                BIC(K*(n-1)+k, dn) = FittingResults.MSC.BIC;
            end
        end
        paramsN(i, dn) = length(FittingResults.InitialParams);
    end
    deltaAIC = AIC - AIC(:, 1);
    deltaAICmean(i, :) = round(mean(deltaAIC, 1));
    deltaBIC = BIC - BIC(:, 1);
%     deltaBIC(BIC > 0) = 0;
%     deltaBICmean(i, :) = round(sum(deltaBIC, 1)./sum(BIC <= 0));
    deltaBICmean(i, :) = round(mean(deltaBIC, 1));
end
deltaAICmean = deltaAICmean';
deltaBICmean = deltaBICmean';
paramsN = paramsN';

