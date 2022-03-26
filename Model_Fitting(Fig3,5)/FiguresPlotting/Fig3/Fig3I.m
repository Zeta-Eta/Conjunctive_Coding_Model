close all,
clear,
clc;

addpath(genpath('Functions'));

%% Parameters Setting
CTM = 'median'; % Central Tendency Measures: 'median' or 'mean'
loadPath1 = ['FittingResults_', CTM, 'PinBS\CCM_Og\'];
loadPath2 = 'PatternSet\';

dataSetName = {'A4R'; 'C4R'; 'M4R'};
ptpName = {'Adults'; 'Children'; 'Monkeys'};
ptpN = size(ptpName, 1);
col = ptpN;
row = 1;

color = [185 170 130; ...
    50 139 135; ...
    115 60 20; ...
    165 110 70]./255; % khaki, teal, coffee, light brown

lim = [0.75, 1.05;
    0.2 0.8;
    0.5 0.8];
tick = {linspace(0.8, 1, 3); linspace(0.3, 0.7, 3); linspace(0.6, 0.7, 2)};

ts = 1;

spx = 0.12;
spy = 0.28;
dx = 0.2;
% dy = 0.2;
sclx = 0.2;
scly = (sclx*col/row)*250/300;

set(gcf, 'Position', [0, 0, 250*col, 300*row]);
%% I

for i = 1:ptpN
    load([loadPath1, dataSetName{i}, '.mat']);
    load([loadPath2, dataSetName{i}, '.mat']);
    
    subplot(row, col, i);
    Pacc = FittingResults.P.TargetOnly(ts, :)';
    Qacc = FittingResults.Q.TargetOnly(ts, :)';
    
    SST = sum((Pacc - mean(Pacc)).^2);
    SSE = sum((Pacc - Qacc).^2);
    Rsquared = 1 - SSE/SST;
    
    set(gca, 'Position', [spx + (dx + spx)*(i - 1), spy, sclx, scly]);
    
    plotCorrSctr(Qacc, Pacc, 20, [0 0 0], color(i, :), lim(i, :));
    set(gca, 'XTick', tick{i}, 'YTick', tick{i});
    set(gca, 'LineWidth', 1, 'FontSize', 13, 'FontName', 'Arial', 'FontWeight', 'bold');
    if i == 1
        xlabel({'P(correct)'; 'Model'}, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel({'P(correct)'; 'Data'}, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
    end
%     box off;
    text(0.5, 1, {ptpName{i}; ' '}, 'Units', 'normalized', 'HorizontalAlignment', 'center', ...
        'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom');
    if Rsquared >= 0.001
        text(0.02, 1, ['{\itR^2} = ', num2str(Rsquared, '%.3f')], 'Units', 'normalized', ...
            'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom');
    else
        text(0.02, 1, '{\itR^2} < 0.001', 'Units', 'normalized', ...
            'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom');
    end

end

