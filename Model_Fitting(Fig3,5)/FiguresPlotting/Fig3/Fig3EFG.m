close all,
clear,
clc;

addpath(genpath('Functions'));

%% Parameters Setting
CTM = 'median'; % Central Tendency Measures: 'median' or 'mean'
loadPath1 = ['FittingResults_', CTM, 'PinBS\CCM_Og\'];

dataSetName = {'A4R'; 'C4R'; 'M4R'};
ptpName = {'Adults'; 'Children'; 'Monkeys'};
ptpN = size(ptpName, 1);
col = 1;
row = ptpN;

prmName = {'lambda'; 'kappa'};
prmN = size(prmName, 1);
prmText = {'{\it\bf\lambda}'; '{\it\bf\kappa}'};

xlbd = [0.3 0.3 0.3];

color = [185 170 130; ...
    50 139 135; ...
    115 60 20; ...
    165 110 70]./255; % khaki, teal, coffee, light brown

spx = 0.3;
spy = 0.11;
% dx = 0.2;
dy = 0.2;
scly = 0.2;
sclx = scly*row/col;

set(gcf, 'Position', [0, 0, 250*col, 250*row]);


loadPath0 = 'FittingResults4BS\Parameters\';
mdls = {'CCM_Og'; 'CCM_Cs'; 'CCM_Cn'; 'CCM_Pl'; 'CCM_Pc'}; 
dataSetNameBS = [mdls{1}, '*.mat'];
files = dir([loadPath0, dataSetNameBS]);
params = load([loadPath0, files.name]);

%% E
subplot(row, col, 1);
x = [];
for k = 1:ptpN
    load([loadPath1, dataSetName{k}, '.mat']);
    x = [x; FittingResults.ModelParams.w];
end

Ntemp = size(x', 1);

plotBar(1:Ntemp, x', color, 0.7);

set(gca, 'LineWidth', 1, 'FontSize', 13, 'FontName', 'Arial', ...
    'XTick', 1:Ntemp, 'FontWeight', 'bold');
xlabel('Order', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');

xlm = [0.25, Ntemp + 0.75];
xlim(xlm);
ylim(ylim);

set(gca, 'Position', [spx, spy + 2*(dy + spy), sclx, scly]);

text(xlbd(1)*(xlm(1) - xlm(2)), mean(ylim), '{\it\bfw}', ...
    'FontName', 'Times', 'FontSize', 18, ...
    'HorizontalAlignment', 'center', 'Rotation', 0);

legend(ptpName, 'Position', [0.75 0.88 0.02 0.03], 'Box', 'off', ...
    'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');

%% F&G
load([loadPath1, dataSetName{1}, '.mat']);
for i = 1:prmN
    l = eval(['length(FittingResults.ModelParams.', prmName{i}, ')']);
    eval([prmName{i}, ' = zeros(l, ptpN);']);
end

for i = 1:prmN
    subplot(row, col, 1 + i);
    
    for k = 1:ptpN
        load([loadPath1, dataSetName{k}, '.mat']);
        eval([prmName{i}, '(:, k) = FittingResults.ModelParams.', prmName{i}, ';']);
    end
    
    x = eval(prmName{i});
    plotBar(1:ptpN, x, color, 0.7);
    
    x2 = eval(['params.' prmName{i}]);
    if strcmp(CTM, 'median')
        p2 = 47.5;
        maxY = plotErr(x2, '.', [0 0 0], 0.5, 0, 'fractiles', 'dscrt', 50 + p2*[-1, 1]);
    elseif strcmp(CTM, 'mean')
        maxY = plotErr(x2, '.', [0 0 0], 0.5, 0, 'STD', 'dscrt', 50 + p2*[-1, 1]);
    end
    
    set(gca, 'LineWidth', 1, 'FontSize', 13, 'FontName', 'Arial', 'FontWeight', 'bold');
    
    set(gca, 'XTickLabel', ptpName, 'XTickLabelRotation', -45);
    
    comb = nchoosek(1:ptpN, 2);
    d = [1, 3, 1];
    hM = max(maxY);
    
    load('FittingResults4PT\PermutationTestResults\CCM_Og-BS_M-1000.mat', 'pHAT')
    for j = 1:size(comb, 1)
        Y = max(maxY(comb(j, :))) + 0*mean(maxY(comb(j, :))) + 0.06*hM*d(j);
        hold on;
        plot(comb(j, :), Y + zeros(1, 2), 'k', 'LineWidth', 1);
        hold off;
        p = eval(['pHAT.twoTail.', prmName{i}, '(:, j)']);
        if     0.05  <= p && p < 0.1
            sign = '.';
        elseif 0.01  <= p && p < 0.05
            sign = '*';
        elseif 0.001 <= p && p < 0.01
            sign = '**';
        elseif p < 0.001
            sign = '***';
        else
            sign = 'n.s.';
        end
        if p >= 0.05
            text(mean(comb(j, :)), Y, sign, ...
                'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'Rotation', 0, ...
                'VerticalAlignment', 'bottom');
        else
            text(mean(comb(j, :)), Y + hM.*0.03, sign, ...
                'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'Rotation', 0);
        end
        
    end
    xlm = [0.25, ptpN + 0.75];
    xlim(xlm);
%     ylim(ylim);
    
    set(gca, 'Position', [spx, spy + (dy + spy)*(2-i), sclx, scly]);
    
    text(xlbd(i + 1)*(xlm(1) - xlm(2)), mean(ylim), prmText{i}, ...
        'FontName', 'Times', 'FontSize', 18, ...
        'HorizontalAlignment', 'center', 'Rotation', 0);
    
end

