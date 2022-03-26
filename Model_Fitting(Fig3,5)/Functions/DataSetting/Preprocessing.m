function [Experiment, data, dataSetName] = Preprocessing(...
    setsize, N, rule, touchType, participant, chosenData)

%% Experiment Setting

Experiment = struct();
Experiment.setsize = setsize;
Experiment.N = N;
Experiment.rule = rule;
Experiment.touchType = touchType;
Experiment.participant = participant;

%% Data Loading
load(chosenData, 'dataset');

%% Data Pre-processing
data = dataset(strcmp(dataset.participant, participant) & ...
    strcmp(dataset.touchType, touchType) & ...
    strcmp(dataset.rule, rule) & ...
    dataset.setsize == setsize, :);

if size(data, 1) == 0
    error('No data found under such conditions!');
end

% Load targets, responses & reaction-time according to the setsize
data.targets = data.targets(:, 1:setsize);
data.responses = data.responses(:, 1:setsize);
data.RT = data.RT(:, 1:setsize);

% Reverse targets' order (If the rule is "mirror")
if strcmp(rule, "mirror")
    data.targets = data.targets(:, end:-1:1);
end

% Remove invalid data
if strcmp(touchType, "freeTouch")
    [rmIdx, ~] = find(ismember(data.responses, 1:N) == 0);
    data(unique(rmIdx), :) = [];
end

% Remove repetitive training data (not necessary, just for monkeys' early training dataset)
if ~strcmp(participant, "Adults") && ~strcmp(participant, "Children")
    for i = size(data, 1):-1:2
        if data.targets(i, :) == data.targets(i - 1, :)
            data(i, :) = [];
        end
    end
end

% Remove repeated responses data
dataNbefore = size(data, 1);

delta = zeros(1, size(data.responses, 1));
for trial = 1:size(data.responses, 1)
    delta(trial) = length(data.responses(trial, :)) - length(unique(data.responses(trial, :)));
end
data(delta ~= 0, :) = [];

dataNafter = size(data, 1);
replacementER = (dataNbefore - dataNafter)/dataNbefore;

% Remove outliers according to RT
[u1, ~, uid1] = unique(data.group);
OutlierTF = [];
for i = 1:size(u1, 1)
    OutlierTF = [OutlierTF; isoutlier(data.RT(uid1 == i, :), 'mean')];
end
rmIdx = ~all(OutlierTF == 0, 2);
data(rmIdx, :) = [];

% Remove data with too few trials
[u2, ~, uid2] = unique(data.group);
% Threshold: 30 for 4 dots | 10 for 3 dots
if setsize == 3
    thrshd = 10;
else
    thrshd = 30;
end
rmIdx2 = [];
x = [];
for i = 1:size(u2, 1)
    tn = sum(uid2 == i);
    rmIdx2 = [rmIdx2; repmat(tn >= thrshd, tn, 1)];
    x = [x, tn];
end
data(rmIdx2 == 0, :) = [];

% Dataset Name
if strcmp(participant, "Adults") || strcmp(participant, "Children")
    dataSetName = participant{:}(1);
else
    dataSetName = participant{:}(1:2);
end

dataSetName = [dataSetName , num2str(setsize)];

if strcmp(rule, "repeat")
    dataSetName = [dataSetName , 'R'];
else
    dataSetName = [dataSetName , 'M'];
end

% [Data Set Name]
% [Participant] + [Setsize] + [Rule]
%  A/C/M/MO/MG  +   4/5/6   +  R/M
% e.g. A4R / C4R / M4R / MO4R / MG4R
% [Participant]
% A: Adults | C: Children | M: Monkeys
% MO: Monkey Ocean | MG: Monkey George
% [Setsize]
% 4/5/6 Targets
% [Rule]
% R: Repeat | M: Mirror

Experiment.dataNbefore = dataNbefore;
Experiment.dataNafter = dataNafter;
Experiment.replacementER = replacementER;

end

