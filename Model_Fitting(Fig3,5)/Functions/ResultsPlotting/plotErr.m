function maxY = plotErr(data, setting, color, alpha, d, errType, plotType, range)
%Plot Errbar

X = d + (1:size(data, 2));

if strcmp(errType, 'SEM')
    Y = mean(data, 'omitnan');
    Yerr = std(data, 'omitnan')./sqrt(sum(~isnan(data)));
    maxY = Y + Yerr;
elseif strcmp(errType, 'STD')
    Y = mean(data, 'omitnan');
    Yerr = squeeze(std(data, 'omitnan')); % STD
    maxY = Y + Yerr;
elseif strcmp(errType, 'fractiles')
    Y = median(data, 'omitnan');
    Yneg = abs(Y - prctile(data, range(1)));
    Ypos = abs(Y - prctile(data, range(2)));
    maxY = Y + Ypos;
end

hold on;

if strcmp(errType, 'fractiles')
    if strcmp(plotType, 'dscrt')
        errorbar(X, Y, Yneg, Ypos, setting, 'Color', alpha + (1 - alpha).*color, ...
            'MarkerSize', 1, 'LineWidth', 2);
    elseif strcmp(plotType, 'cntns')
        fill([X, flip(X)], [prctile(data, range(1)), flip(prctile(data, range(2)))], ...
            color, 'FaceAlpha', 1 - alpha, 'LineStyle', 'none');
    end
else
    if strcmp(plotType, 'dscrt')
        errorbar(X, Y, Yerr, setting, 'Color', alpha + (1 - alpha).*color, ...
            'MarkerSize', 1, 'LineWidth', 2);
    elseif strcmp(plotType, 'cntns')
        fill([X, flip(X)], [Y - Yerr, flip(Y + Yerr)], color, 'FaceAlpha', 1 - alpha, 'LineStyle', 'none');
    end
end

hold off;

end

