function plotBar(x, y, color, d)
%Plot Params

I = 1:size(y, 2);
hold on;

if size(y, 1) ~= 1
    b = bar(y, d);
    for i = I
        set(b(i), 'FaceColor', color(i, :), 'EdgeColor', color(i, :));
    end
    set(gca, 'XTick', 1:size(y, 1));
else
    for i = I
        bar(x(i), y(i), d, 'FaceColor', color(i, :), 'EdgeColor', color(i, :));
    end
    set(gca, 'XTick', I);
end

hold off;

set(gca, 'LineWidth', 1, 'FontSize', 15, 'FontName', 'Arial');
set(gca, 'TickLength', [0.02 0.025]);
set(gca, 'Tickdir', 'out', 'Layer', 'top');
% ylabel('Accuracy', 'FontName', 'Arial', 'FontSize', 15);
% xlim([0.5 length(x)+0.5]);
% ylim([0 1]);
% ylim([min(y) - 0.1*(max(y) - min(y)), max(y) + 0.1*(max(y) - min(y))]);
box off;
axis square;
end

