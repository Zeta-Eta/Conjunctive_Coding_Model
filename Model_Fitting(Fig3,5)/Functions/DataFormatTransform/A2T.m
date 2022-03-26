function [targetRespTypesPMF, targetRespTypes] = A2T(allRespTypesPMF, targets, Experiment)
% All Response Types to Target-only Response Types

allRespTypes = WoR(Experiment.setsize, Experiment.N);
targetRespTypes = WoR(Experiment.setsize, Experiment.setsize);
targetRespTypesPMF = zeros(size(targetRespTypes, 1), size(targets, 1));
for pattern = 1:size(targets, 1)
    ptrnT = targets(pattern, :);
    ptrnRespTypes = ptrnT(targetRespTypes);
    for type = 1:size(targetRespTypes, 1)
        targetRespTypesPMF(type, pattern) = allRespTypesPMF(ismember(allRespTypes, ptrnRespTypes(type, :), 'rows'), pattern);
    end
end

end

