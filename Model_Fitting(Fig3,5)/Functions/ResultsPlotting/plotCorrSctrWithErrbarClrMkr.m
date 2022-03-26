function plotCorrSctrWithErrbarClrMkr(x, y, xErr, yErr, ckType, ...
    color, marker, mkrSize, lim)
% Plot Correlation Scatter Diagram
if isempty(lim)
    A = [x + xErr, x - xErr, y + yErr, y - yErr];
    r = 0.1;
    m = min(A, [], 'all') - r*(max(A, [], 'all') - min(A, [], 'all'));
    M = max(A, [], 'all') + r*(max(A, [], 'all') - min(A, [], 'all'));
    lim = [m, M];
end


% xm = min(x) - 0.1*(max(x) - min(x));
% xM = max(x) + 0.1*(max(x) - min(x));
% ym = min(y) - 0.1*(max(y) - min(y));
% yM = max(y) + 0.1*(max(y) - min(y));

hold on;

h = plot(lim, lim, 'k--');
set(get(get(h, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle','off');

ckNum = sum(ckType ~= 0, 2);
for i = 1:size(ckNum, 1)
    scatter(x(i), y(i), mkrSize(ckNum(i)), color(i, :), ...
        marker{ckNum(i)}, 'LineWidth', 2);
end

errorbar(x, y, yErr, yErr, xErr, xErr, '.', 'Color', [1 1 1].*(0.5));

hold off;

set(gca, 'LineWidth', 1, 'FontSize', 15, 'FontName', 'Arial');
xlim(lim);
ylim(lim);
axis square;

box on;

end

