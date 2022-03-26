close all,
clear,
clc;

addpath(genpath('Functions'));

%% Parameters Setting

dataSetName = {'A4R'; 'C4R'; 'M4R'};
mdlName = {'Original CCM'; 'Chunk-based'; 'Path-length-based';...
    'Path-crossings-based'};
CTM = 'median'; % Central Tendency Measures: 'median' or 'mean'
loadPath0 = ['FittingResults_', CTM, 'PinBS\'];
loadPath1 = {[loadPath0, 'CCM_Og\']; [loadPath0, 'CCM_Cs\']; ...
    [loadPath0, 'CCM_Cn\']; [loadPath0, 'CCM_Pl\']; [loadPath0, 'CCM_Pc\']};
loadPath1 = loadPath1([1:2, 4:5]);

ptpName = {'Adults'; 'Children'; 'Monkeys'};
ptpName = ptpName(1:3);
ptpN = size(ptpName, 1);

row = 1;

prmName = {'w'; 'lambda'; 'kappa'};
prmN = size(prmName, 1);
prmText = {'\it\bfw'; '{\it\bf\lambda}'; '{\it\bf\kappa}'};
col = prmN;

color2 = [185 170 130; ...
    50 139 135; ...
    115 60 20]./255; % khaki teal coffee


%%
spx = 0.12;
spy = 0.32;
dx = 0.2;
% dy = 0.2;
sclx = 0.2;
scly = sclx*col/row;

set(gcf, 'Position', [0, 0, 250*col, 250*row]);


%%
loadPath0 = 'FittingResults4BS\Parameters\';
mdls = {'CCM_Og'; 'CCM_Cs'; 'CCM_Cn'; 'CCM_Pl'; 'CCM_Pc'}; 
dataSetNameBS = [mdls{1}, '*.mat'];
files = dir([loadPath0, dataSetNameBS]);
params = load([loadPath0, files.name]);


%% C
% ylabelx = [0.3, 0.25, 0.25]; % 2
ylabelx = [0.3, 0.2, 0.25]; % 3
for i = 1:prmN
    subplot(row, col, i);
    x = [];
    
    for k = 1:ptpN
        load([loadPath1{2}, dataSetName{k}, '.mat']);
        x = eval(['[x; FittingResults.ModelParams.', prmName{i}, ']']);
    end
    
    Ntemp = size(x', 1);
    if Ntemp == 1
        plotBar(1:ptpN, x', color2, 0.7);
        xlm = [0.25, ptpN + 0.75];
        
%         x2 = eval(['params.' prmn{i}]);
%         p2 = 47.5;
%         maxY = plotErr(x2, '.', [0 0 0], 0.5, 0, 'fractiles', 'dscrt', 50 + p2*[-1, 1]);
        
    else
        plotBar(1:Ntemp, x', color2, 0.7);
        xlm = [0.25, Ntemp + 0.75];
        
    end
    
    
    set(gca, 'Position', [spx + (dx + spx)*(i - 1), spy, sclx, scly], 'Layer', 'top');
    
    if i == 1
        set(gca, 'LineWidth', 1, 'FontSize', 14, 'FontName', 'Arial', ...
            'XTick', 1:Ntemp, 'FontWeight', 'bold');
        xlabel('Order', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    elseif i == 2
        set(gca, 'LineWidth', 1, 'FontSize', 14, 'FontName', 'Arial', ...
            'XTick', 1:Ntemp, 'FontWeight', 'bold');
        xlabel('Chunk Size', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    else
        set(gca, 'LineWidth', 1, 'FontSize', 13, 'FontName', 'Arial', 'FontWeight', 'bold');
        set(gca, 'XTickLabel', ptpName, 'XTickLabelRotation', -50);
    end
    
    xlim(xlm);
    ylim(ylim);
    text(ylabelx(i)*(xlm(1) - xlm(2)), mean(ylim), prmText{i}, ...
        'FontName', 'Times', 'FontSize', 20, ...
        'HorizontalAlignment', 'center', 'Rotation', 0);
    
    if i == 1
%         legend(pn, 'Position', [0.35 0.75 0.1 0.05], 'Box', 'off', ...
%             'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
        legend(ptpName, 'Position', [0.255 0.8 0.03 0.02], 'Box', 'off', ...
            'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');
    end
    
end

