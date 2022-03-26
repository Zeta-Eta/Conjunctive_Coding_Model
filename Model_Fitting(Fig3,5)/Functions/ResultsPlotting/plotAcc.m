function plotAcc(Acc, setting, color, alpha, d)
%Plot Accuracy

order = 1:length(Acc);

hold on;
plot(order + d, Acc, setting, 'Color', [color, 1 - alpha], 'MarkerSize', 13, 'LineWidth', 2);
hold off;

set(gca, 'XTick', order);
% set(gca, 'YTick', 0.5:0.1:1);
set(gca, 'LineWidth', 1, 'FontSize', 15, 'FontName', 'Arial');
set(gca, 'TickLength', [0.02 0.025]);
set(gca, 'Tickdir', 'out');
% xlabel('Order', 'FontName', 'Arial', 'FontSize', 15);
% ylabel('Accuracy', 'FontName', 'Arial', 'FontSize', 15);
xlim([0.5 length(order) + 0.5]);
ylim([0.45 1.05]);
% ylim([min(y) - 0.1*(max(y) - min(y)), max(y) + 0.1*(max(y) - min(y))]);
box off;
axis square;
end

