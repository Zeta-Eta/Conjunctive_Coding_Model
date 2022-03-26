function plotCorrSctr(x, y, mkrSize, color1, color2, lim)

% Plot Correlation Scatter Diagram
if isempty(lim)
    A = [x, y];
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

scatter(x, y, mkrSize, 'MarkerEdgeColor', color1, 'MarkerFaceColor', color2);

hold off;

set(gca, 'LineWidth', 1, 'FontSize', 15, 'FontName', 'Arial');
xlim(lim);
ylim(lim);
axis square;

box on;

end

