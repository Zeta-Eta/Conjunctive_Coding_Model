function s = plotDistErr(dataSet, RetrievalPMF, alpha, delta)
%Plot Distance Error

Prop = dataSet.proportion;
T = dataSet.targets;
N = size(dataSet.responses, 2);
order = 1:size(T, 2);
dist = 1:(N/2);
pattern = 1:length(Prop);

P = zeros(length(Prop), N/2);
y = zeros(length(order), N/2);
c = [180 65 55; ...
    220 139 55; ...
    90 139 60; ...
    50 115 169]./255; % red, orange, green, blue

hold on;
for t = order
    for p = pattern
        for d = dist
            P(p, d) = sum(RetrievalPMF(...
                abs(dataSet.allRespTypes(:, t) - T(p, t)) == d | ...
                abs(dataSet.allRespTypes(:, t) - T(p, t)) == N - d, p));
        end
    end
    y(t, :) = Prop*P;
%     s(t) = plot(dist + delta, y(t, :), '.-', 'Color', [c(t, :), 1 - alpha], 'MarkerSize', 13, 'LineWidth', 2);
    s(t) = plot(dist + delta, y(t, :), '.-', 'Color', alpha + (1 - alpha).*c(t, :), 'MarkerSize', 13, 'LineWidth', 2);
end
hold off;

set(gca, 'XTick', dist);
set(gca, 'LineWidth', 1, 'FontSize', 15, 'FontName', 'Arial');
set(gca, 'TickLength', [0.02 0.025]);
set(gca, 'Tickdir', 'out');
% xlabel('Distance', 'FontName', 'Arial', 'FontSize', 15);
% ylabel('Accuracy', 'FontName', 'Arial', 'FontSize', 15);
xlim([0.5 length(dist)+0.5]);
% ylim([-0.05 1.05]);
ylim([min(min(y)) - 0.1*(max(max(y)) - min(min(y))), ...
    max(max(y)) + 0.1*(max(max(y)) - min(min(y)))]);
box off;
axis square;
end

