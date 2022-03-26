close all,
clear,
clc;

addpath(genpath('Functions'));

%% Parameters Setting
loadPath1 = 'FittingResults\CCM_Og\';
loadPath2 = 'PatternSet\';

dataSetName = {'A4R'; 'C4R'; 'M4R'};
ptpName = {'Adults'; 'Children'; 'Monkeys'};
ptpN = size(ptpName, 1);
col = 1;
row = 1;


color = [185 170 130; ...
    50 139 135; ...
    115 60 20; ...
    165 110 70]./255; % khaki, teal, coffee, light brown

spx = 0.32;
spy = 0.28;
% dx = 0.6;
% dy = 0.2;
sclx = 0.6;
scly = sclx*col/row;

set(gcf, 'Position', [0, 0, 250*col, 250*row]);
%% H
meanAcc = zeros(2, ptpN);
err = zeros(1, ptpN);
ACCptp = cell(1, 3);
for i = 1:ptpN
    load([loadPath1, dataSetName{i}, '.mat']);
    load([loadPath2, dataSetName{i}, '.mat']);
    Acc = patternSet.ACCptp;
    ACCptp{i} = Acc;
    meanAcc(1, i) = mean(Acc);
    meanAcc(2, i) = FittingResults.Q.AllTargetOnly(1);
%     err(i) = std(Acc)./sqrt(length(Acc)); % SEM
    err(i) = std(Acc); % STD
end

% subplot(row, col, 1);

X1 = 1:ptpN;
plotBar(X1, meanAcc(1, :), color + 0.5*(1 - color), 0.7);
hold on;
errorbar(X1, meanAcc(1, :), err, 'LineWidth', 2, 'Linestyle', 'None', 'Color', [1 1 1].*(0.5));
hold off;

xlim([0.25, ptpN + 0.75]);

set(gca, 'Position', [spx, spy, sclx, scly]);

set(gca, 'XTick', X1, 'XTickLabel', ptpName, 'XTickLabelRotation', -45, 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'YTick', [0 0.5 1]);
title('Data', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold'); 
% xlabel('Data', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
ylabel({'P(correct)'; 'Entire Sequence'}, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');

% Significant Test
x = nchoosek(1:ptpN, 2);
% y = [1.05, 1.15, 0.9]; 
p_value = [2e-16, 1.9e-10, 5.1e-06]; % use R

d = [1 2.5 1];
Y = meanAcc(1, :) + err;
h = max(Y, [], 'all');

% for i = 1:pN
for i = 1:ptpN
    y = max(Y(x(i, :))) + 0.15*h*d(i);
    hold on;
    plot(x(i, :), y + zeros(1, 2), 'k', 'LineWidth', 1);
    hold off;
    p = p_value(i);
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
        text(mean(x(i, :)), y, sign, ...
            'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'Rotation', 0, ...
            'VerticalAlignment', 'bottom');
    else
        text(mean(x(i, :)), y + h.*0.03, sign, ...
            'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'Rotation', 0);
    end
end

