close all,
clear,
clc;

addpath(genpath('Functions'));

%% Parameters Setting
N = 1000; % number of repetition times
CTM = 'median'; % Central Tendency Measures: 'median' or 'mean'
loadPath1 = ['FittingResults_', CTM, 'PinBS\CCM_Og\'];
loadPath2 = 'PatternSet\';

dataSetName = {'A4R'; 'C4R'; 'M4R'};
ptpName = {'Adults'; 'Children'; 'Monkeys'};
ptpN = size(ptpName, 1);
col = ptpN;
row = 3;

ylim1 = [0.9, 1; 0.6, 0.8; 0.6, 1];
ylim2 = [0, 0.04; 0, 0.2; 0, 0.15];

spx = 0.12;
spy = 0.11;
dx = 0.2;
dy = 0.2;
sclx = 0.2;
scly = sclx*col/row;

set(gcf, 'Position', [0, 0, 250*col, 250*row]);

%% Load the order accuracy
load(['FittingResults4BS\Parameters\CCM_Og-BS-', num2str(N), '.mat'], 'odrACC');

%%

for i = 1:ptpN
    load([loadPath1, dataSetName{i}, '.mat']);
    load([loadPath2, dataSetName{i}, '.mat']);
    
    %% subplot 1
    subplot(row, col, i);
    
    if strcmp(CTM, 'median')
        % median & 95%CI
        ftp = 47.5;
        plotErr(odrACC(:, :, i), '.', [0 0 0], 0.8, 0, 'fractiles', 'cntns', 50 + ftp*[-1, 1]);
    elseif strcmp(CTM, 'mean')
        % mean & STD
        plotErr(odrACC(:, :, i), '.', [0 0 0], 0.8, 0, 'STD', 'cntns', []);
    end
    
    plotAcc(FittingResults.Q.AllOrderAccuracies, '-', [0 0 0], 0, 0);
    
    set(gca, 'Position', [spx + (dx + spx)*(i - 1), spy + 2*(dy + spy), sclx, scly]);
    set(gca, 'LineWidth', 1, 'FontSize', 13, 'FontName', 'Arial', 'FontWeight', 'bold');
    title(ptpName{i}, 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    ylim(ylim1(i, :));
    
    if i == 1
        xlabel('Order', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('P(correct)', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    %% subplot 2
    subplot(row, col, i + col);
    plotOrderErr(patternSet, FittingResults.RetrievalPMF, 0, 0);
    
    set(gca, 'Position', [spx + (dx + spx)*(i - 1), spy + (dy + spy), sclx, scly]);
    set(gca, 'LineWidth', 1, 'FontSize', 13, 'FontName', 'Arial', 'FontWeight', 'bold');
    
    if i == 1
        xlabel('Order', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('P(response)', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    %% subplot 3
    subplot(row, col, i + 2*col);
    plotDistErr(patternSet, FittingResults.RetrievalPMF, 0, 0);
    ylim(ylim2(i, :));
    
    set(gca, 'Position', [spx + (dx + spx)*(i - 1), spy + 0*(dy + spy), sclx, scly]);
    set(gca, 'LineWidth', 1, 'FontSize', 13, 'FontName', 'Arial', 'FontWeight', 'bold');
    
    if i == 1
        xlabel('Distance', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('P(response)', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
    end
    
end
