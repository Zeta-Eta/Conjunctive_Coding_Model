function s = plotOrderErr(dataSet, RetrievalPMF, alpha, d)
%Plot Order Error

Prop = dataSet.proportion;
T = dataSet.targets;
order = 1:size(T, 2);
pattern = 1:length(Prop);

P = zeros(length(Prop), length(order));
y = zeros(length(order));
c = [180 65 55; ...
    220 139 55; ...
    90 139 60; ...
    50 115 169]./255; % red, orange, green, blue

hold on;
for t = order
    for p = pattern
        for o = order
            P(p, o) = sum(RetrievalPMF(dataSet.allRespTypes(:, t) == T(p, o), p));
        end
    end
    y(t, :) = Prop*P;
%     s(t) = plot(order + d, y(t, :), '.-', 'Color', [c(t, :), 1 - alpha], 'MarkerSize', 13, 'LineWidth', 2);
    s(t) = plot(order + d, y(t, :), '.-', 'Color', alpha + (1 - alpha).*c(t, :), 'MarkerSize', 13, 'LineWidth', 2);
end
hold off;

set(gca, 'XTick', order);
set(gca, 'YTick', 0:0.25:1);
set(gca, 'LineWidth', 1, 'FontSize', 15, 'FontName', 'Arial');
set(gca, 'TickLength', [0.02 0.025]);
set(gca, 'Tickdir', 'out');
% xlabel('Order', 'FontName', 'Arial', 'FontSize', 15);
% ylabel('Accuracy', 'FontName', 'Arial', 'FontSize', 15);
xlim([0.5 length(order)+0.5]);
ylim([-0.05 1.05]);
% ylim([min(y) - 0.1*(max(y) - min(y)), max(y) + 0.1*(max(y) - min(y))]);
box off;
axis square;
end

