% Parametric Statistics for Bootstrap Results
close all,
clear,
clc;

addpath(genpath('Functions'));

saveOn = 0;
plotOn = 1;

mdlNum = 1;

setsize = 4;

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

ptp = {'Adults'; 'Children'; 'Monkey'};
ptpN = size(dataSetName, 1);

mdls = {'CCM_Og'; 'CCM_Cs'; 'CCM_Cn'; 'CCM_Pl'; 'CCM_Pc'};
% Models:
% CCM_Og [Original]
% CCM_Cs [Chunk-size]
% CCM_Cn [Chunk-number]
% CCM_Pl [Path-length]
% CCM_Pc [Path-crossings]
mdlName = mdls{mdlNum};

loadPath = ['FittingResults4BS\', mdlName, '\'];

files1 = dir([loadPath, dataSetName{1}, '*.mat']);
files2 = dir([loadPath, dataSetName{2}, '*.mat']);
files3 = dir([loadPath, dataSetName{3}, '*.mat']);

N = max([length(files1), length(files2), length(files3)]);

if any(mdlNum == [2, 3, 5])
    lambdaN = 0;
    for i = 1:ptpN
        files = dir([loadPath, dataSetName{i}, '*.mat']);
        for n = 1:length(files)
            load([loadPath, files(n).name]);
            lambdaN = max(length(FittingResults.ModelParams.lambda), lambdaN);
        end
    end
    lambda = NaN(N, lambdaN, ptpN);
elseif mdlNum == 4
    a = NaN(N, ptpN);
    b = NaN(N, ptpN);
    lambda = NaN(N, ptpN);
else
    lambda = NaN(N, ptpN);
end
kappa  = NaN(N, ptpN);
eta    = NaN(N, ptpN);
w      = NaN(N, setsize, ptpN);
odrACC = NaN(N, setsize, ptpN);
BIC    = NaN(N, ptpN);

for i = 1:ptpN
    files = dir([loadPath, dataSetName{i}, '*.mat']);
    for n = 1:length(files)
        load([loadPath, files(n).name]);
        if any(mdlNum == [2, 3, 5])
            lambda(n, :, i) = FittingResults.ModelParams.lambda;
        else
            lambda(n, i) = FittingResults.ModelParams.lambda;
        end
        if mdlNum == 4
            a(n, i) = FittingResults.ModelParams.a;
            b(n, i) = FittingResults.ModelParams.b;
        end
        kappa(n, i)     = FittingResults.ModelParams.kappa;
        eta(n, i)       = FittingResults.ModelParams.eta;
        w(n, :, i)      = FittingResults.ModelParams.w;
        odrACC(n, :, i) = FittingResults.Q.AllOrderAccuracies;
        BIC(n, i)       = FittingResults.MSC.BIC;
    end
end

lambda(isoutlier(lambda, 1)) = NaN;
kappa(isoutlier(kappa, 1))   = NaN;
w(isoutlier(w, 1))           = NaN;
eta(isoutlier(eta, 1))       = NaN;
% odrACC(isoutlier(odrACC, 1)) = NaN;

if mdlNum == 4
    a(isoutlier(a, 1)) = NaN;
    b(isoutlier(b, 1)) = NaN;
end

if saveOn
    savePath = 'FittingResults4BS\Parameters\';
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    if mdlNum == 4
        save([savePath, mdlName, '-BS-', num2str(N), '.mat'], ...
            'lambda', 'kappa', 'w', 'a', 'b', 'eta', 'odrACC', 'BIC');
    else
        save([savePath, mdlName, '-BS-', num2str(N), '.mat'], ...
            'lambda', 'kappa', 'w', 'eta', 'odrACC', 'BIC');
    end
end

%% Kernel Smoothing Density Figure
if plotOn
    close all;
    
    color = [185 170 130; ...
        50 139 135; ...
        115 60 20; ...
        165 110 70]./255; % 卡其 青绿 咖啡 浅棕
    
    tempData = lambda; % squeeze(w(:, odrNum, :));
    
    figure(1)
    set(gcf, 'Position', [0, 0, 600, 400]);
    
    hold on;
    for i = 1:ptpN
        [y, x] = ksdensity(tempData(:, i), 'Support', 'positive', 'BoundaryCorrection', 'reflection');
        plot(x, y, 'LineWidth', 2, 'Color', color(i, :));
    end
    hold off;
    
    legend(ptp, 'Box', 'off');
    
    set(gca, 'LineWidth', 1, 'FontSize', 15, 'FontName', 'Arial', 'FontWeight', 'bold');
    set(gca, 'TickLength', [0.02 0.025]);
    set(gca, 'Tickdir', 'out', 'Layer', 'top');
    
    xlabel('\it\bf\lambda', 'FontName', 'Arial', 'FontSize', 18);
    ylabel('Probability Density', 'FontName', 'Arial', 'FontSize', 18);
    
    title('Bootstrap', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
    
end
