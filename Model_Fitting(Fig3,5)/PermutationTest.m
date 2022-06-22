% Random Permutation Tests between Participants
close all,
clear,
clc;

addpath(genpath('Functions'));

saveOn = 0;
textOn = 1;
CTM = 'median';

%% Data Loading
dataSetName = {'A4R'; 'C4R'; 'M4R'};
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
ptpN = size(dataSetName, 1);

comb = nchoosek(1:ptpN, 2);
combN = size(comb, 1);

mdls = {'CCM_Og'; 'CCM_Cs'; 'CCM_Cn'; 'CCM_Pl'; 'CCM_Pc'};
mdlNum = 1;
mdlName = mdls{mdlNum};

loadPath = ['FittingResults4PT\', mdlName, '\'];
loadPath0 = ['FittingResults_', CTM, 'PinBS\', mdlName, '\'];

pHAT.oneTail = [];
pHAT.twoTail = [];
pCI.oneTail = [];
pCI.twoTail = [];

for i = 1:combN
    %% One-tailed
    [pHATtemp, pCItemp, dataSetNameComb, ~] = PermTest(comb(i, :), dataSetName, loadPath0, loadPath, 1, 0.001);
    pHAT.oneTail = [pHAT.oneTail; pHATtemp];
    pCI.oneTail = [pCI.oneTail; pCItemp];
    
    %% Two-tailed
    [pHATtemp, pCItemp, ~, ~] = PermTest(comb(i, :), dataSetName, loadPath0, loadPath, 2, 0.001);
    pHAT.twoTail = [pHAT.twoTail; pHATtemp];
    pCI.twoTail = [pCI.twoTail; pCItemp];
    
    %% Print Results
    if textOn == 1
        % Two-tailed
        txt.lambda = [pHAT.twoTail.lambda(i, :), pCI.twoTail.lambda(i, :)];
        txt.kappa  = [pHAT.twoTail.kappa(i, :), pCI.twoTail.kappa(i, :)];
        txt.eta    = [pHAT.twoTail.eta(i, :), pCI.twoTail.eta(i, :)];
        
        fprintf([dataSetNameComb, ': \npHAT.lambda = %.4f \npCI = [%.4f %.4f] \n'], txt.lambda);
        fprintf('------------------- \npHAT.kappa  = %.4f \npCI = [%.4f %.4f] \n', txt.kappa);
        fprintf('------------------- \npHAT.eta    = %.4f \npCI = [%.4f %.4f] \n \n \n', txt.eta);
    end
end

%% Save Results

if saveOn == 1
    savePath = 'FittingResults4PT\PermutationTestResults\';
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    save([savePath, mdlName, '-', method, '-', num2str(N), '.mat'], ...
        'pHAT', 'pCI');
end

