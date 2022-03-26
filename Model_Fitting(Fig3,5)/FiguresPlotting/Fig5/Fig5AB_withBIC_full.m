close all,
clear,
clc;

addpath(genpath('Functions'));

%% Parameters Setting
ts = 1;

dataSetName = {'A4R'; 'C4R'; 'M4R'};
mdlName = {'Original CCM'; 'Chunk-based'; 'Path-length-based';...
    'Path-crossings-based'};
CTM = 'median'; % Central Tendency Measures: 'median' or 'mean'
loadPath0 = ['FittingResults_', CTM, 'PinBS\'];
loadPath1 = {[loadPath0, 'CCM_Og\']; [loadPath0, 'CCM_Cs\']; ...
    [loadPath0, 'CCM_Cn\']; [loadPath0, 'CCM_Pl\']; [loadPath0, 'CCM_Pc\']};
loadPath1 = loadPath1([1:2, 4:5]);
loadpath2 = 'PatternSet\';
col = size(loadPath1, 1);
ptpName = {'Adults'; 'Children'; 'Monkeys'};
ptpName = ptpName(1:3);
ptpN = size(ptpName, 1);
row = ptpN;


color = [180 65 55; ...
    155 90 60; ...
    220 139 55; ...
    239 195 90; ...
    100 175 75; ...
    65 135 125; ...
    50 110 175; ...
    150 100 150]./255; % red brown orange yellow green teal blue purple

marker  = {'s'; '^'; 'o'; 'x'};
mkrSize = 121*[1, 0.5, 0.7, 1.35];
%% A & B
spx = 0.1;
spy = 0.72;
dx = 0;
dy = 0.11;
scl = 0.2;
dAB = 0.05;

bscBIC = zeros(col, 1);
for i = 1:ptpN
    load([loadPath1{2}, dataSetName{i}, '.mat']);
    x = FittingResults;
    bscBIC(i) = x.MSC.BIC;
end

lim = [0.825, 1.025;
    0.325, 0.775;
    0.5, 0.75];
tick = {linspace(0.85, 1, 4); linspace(0.4, 0.7, 4); linspace(0.5, 0.7, 3)};

for i = 1:ptpN
        for j = 1:col
            
            load([loadPath1{j}, dataSetName{i}, '.mat']);
            x = FittingResults;
            load([loadpath2, dataSetName{i}, '.mat']);
            
            
            if j == 1 && i == 1
                s = subplot('Position', [spx + (dx+scl)*(j-1), spy - (dy+scl)*(i-1), scl, scl]);
            else
                subplot('Position', [spx + (dx+scl)*(j-1), spy - (dy+scl)*(i-1), scl, scl]);
            end
            [PckAcc, PckErr, ckType, ckID] = Acc2ckAcc(x.P.TargetOnly(ts, :)', patternSet, 'SEM');
            [QckAcc, QckErr] = Acc2ckAcc(x.Q.TargetOnly(ts, :)', patternSet, 'SEM');
            
            [r, p] = corr(PckAcc, QckAcc);
            
            SST = sum((PckAcc - mean(PckAcc)).^2);
            SSE = sum((PckAcc - QckAcc).^2);
%             nParams = length(x.InitialParams);
%             nPoint = length(PckAcc);
%             Rsquared = 1 - (SSE/SST)*((nPoint-1)/(nPoint-nParams-1));
            Rsquared = 1 - SSE/SST;
            
            plotCorrSctrWithErrbarClrMkr(QckAcc, PckAcc, QckErr, PckErr, ...
                ckType, color, marker, mkrSize, lim(i, :));
            set(gca, 'XTick', tick{i}, 'YTick', tick{i}, 'XTickLabelRotation', 0);
%             set(gca,'LooseInset',get(gca,'TightInset'));
            set(gca, 'LineWidth', 1, 'FontSize', 14, 'FontName', 'Arial', 'FontWeight', 'bold');
            if j == 1
                if i == 1
                    ylabel({'P(correct)'; 'Data'; ['{\bf', ptpName{i}, '}']}, ...
                        'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
                else
                    ylabel(['\bf', ptpName{i}], 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
                end
                
                if i == ptpN
                    xlabel({'P(correct)'; 'Model'}, 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
                end
            end
            
            if i == 1
                title({['{\bf', mdlName{j}, '}']; ...
                    ['\DeltaBIC = ', int2str(x.MSC.BIC - bscBIC(i))]; ...
                    ['{\itR^2} = ', num2str(Rsquared, '%.3f')]},...
                    'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');   
            else
                title({['\DeltaBIC = ', int2str(x.MSC.BIC - bscBIC(i))]; ...
                    ['{\itR^2} = ', num2str(Rsquared, '%.3f')]},...
                    'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
            end
        end
end


%%
set(gcf, 'position', [0, 0, 300*col, 260*row]);

ckNum = sum(ckType ~= 0, 2);
ckMode = cell(size(ckNum, 1), 1);
for i = 1:size(ckNum, 1)
    ckMode{i} = strrep(num2str(ckType(i, 1:ckNum(i))), '  ', '-');
end
lgd = legend(s, [ckMode; 'SEM'], 'Position', [0.775 0.375 0.3 0.3], ...
    'Box', 'off', 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
title(lgd, {'Chunking'; 'Modes'}, 'FontName', 'Arial', 'FontSize', 15, ...
    'FontWeight', 'bold');
