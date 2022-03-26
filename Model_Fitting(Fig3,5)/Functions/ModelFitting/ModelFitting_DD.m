function FittingResults = ...
    ModelFitting_DD(trainingSet, testSet, ModelName, ...
    initialParams, Experiment, LossFunction, D1, D2, etaOn)

setsize = Experiment.setsize;
N = Experiment.N;
patternN = testSet.patternN;
RespTypeN = size(testSet.allRespTypes, 1);

Model = str2func(strcat('@', ModelName));

%% Fit the Model on Training Set

func = @(params) Model(params, Experiment, trainingSet, LossFunction, D1, D2, etaOn);

% Use fminsearch
options = optimset('fminsearch');
options.TolFun = 1e-7;
options.TolX = 1e-7;
options.Display = 'off';
modelParams = fminsearch(func, initialParams, options);

% Use fminunc
%     options = optimoptions('fminunc', 'MaxFunctionEvaluations', 10000, 'Display', 'off');
%     modelParams = fminunc(func, initialParams, options);

% Use initial parameters
%     modelParams = initialParams;

%% Validate the Model on Test Set
[RSS, ModelParams, EncodingMatrix, RetrievalPMF] =...
    Model(modelParams, Experiment, testSet, 'LSE', D1, D2, etaOn);

%% Model Selection Criteria(MSC)
% without the constant term "n*log(n)"
MSC = struct;

k = length(modelParams);
n = RespTypeN*patternN;

% Akaike Information Criterion(AIC)
MSC.AIC = n*log(RSS) + 2*k;

% Bayesian Information Criterion(BIC)
MSC.BIC = n*log(RSS) + k*log(n);

%% Coefficient of Determination(R squared) & Pearson Correlation Coefficient(PCC)

P = struct;
Q = struct;
SSE = struct;
Rsquared = struct;
PCC = struct;

Prop = testSet.proportion;
T = testSet.targets;
allRespTypes = testSet.allRespTypes;

% All
P.All = testSet.RespTypesPMF;
Q.All = RetrievalPMF;

SST = sum((P.All - mean(P.All, 'all')).^2, 'all');
SSE.All = RSS;
Rsquared.All = 1 - SSE.All/SST;
PCC.All = corr(P.All(:), Q.All(:));

% All Patterns
SST = sum((P.All - mean(P.All)).^2, 1);
SSE.AllPatterns = sum((P.All - Q.All).^2, 1);
Rsquared.AllPatterns = 1 - SSE.AllPatterns./SST;
[r, p] = corr(P.All, Q.All);
PCC.AllPatterns = [diag(r), diag(p)];

% All Responses
SST = sum((P.All - mean(P.All)).^2, 2);
SSE.AllResponses = sum((P.All - Q.All).^2, 2);
Rsquared.AllResponses = 1 - SSE.AllResponses./SST;
[r, p] = corr(P.All', Q.All');
PCC.AllResponses = [diag(r), diag(p)];

% Target-Only Responses
[P.TargetOnly, targetRespTypes] = A2T(P.All, T, Experiment);
Q.TargetOnly = A2T(Q.All, T, Experiment);

SST = sum((P.TargetOnly - mean(P.TargetOnly)).^2, 2);
SSE.TargetOnlyResponses = sum((P.TargetOnly - Q.TargetOnly).^2, 2);
Rsquared.TargetOnlyResponses = 1 - SSE.TargetOnlyResponses./SST;
[r, p] = corr(P.TargetOnly', Q.TargetOnly');
PCC.TargetOnlyResponses = [diag(r), diag(p)];

P.AllTargetOnly = P.TargetOnly*Prop';
Q.AllTargetOnly = Q.TargetOnly*Prop';

if setsize ~= N
    P.AllTargetOnly = [P.AllTargetOnly; 1 - sum(P.AllTargetOnly)];
    Q.AllTargetOnly = [Q.AllTargetOnly; 1 - sum(Q.AllTargetOnly)];
end
SST = sum((P.AllTargetOnly - mean(P.AllTargetOnly)).^2);
SSE.AllTargetOnlyResponses = sum((P.AllTargetOnly - Q.AllTargetOnly).^2);
Rsquared.AllTargetOnlyResponses = 1 - SSE.AllTargetOnlyResponses/SST;

% Accuracies's Correlation Coefficient

P.OrderAccuracies = PMF2Acc(P.All, T, allRespTypes);
Q.OrderAccuracies = PMF2Acc(Q.All, T, allRespTypes);

[r, p] = corr(P.OrderAccuracies, Q.OrderAccuracies);
PCC.OrderAccuracies = [diag(r), diag(p)];

P.AllOrderAccuracies = P.OrderAccuracies'*Prop';

Q.AllOrderAccuracies = Q.OrderAccuracies'*Prop';
[r, p] = corr(P.AllOrderAccuracies, Q.AllOrderAccuracies);
PCC.AllOrderAccuracies = [r, p];

%% Result Collection

FittingResults = struct;
FittingResults.InitialParams = initialParams;
FittingResults.ModelParams = ModelParams;
FittingResults.EncodingMatrix = EncodingMatrix;
FittingResults.RetrievalPMF = RetrievalPMF;
FittingResults.allRespTypes = testSet.allRespTypes;
FittingResults.targetRespTypes = targetRespTypes;
FittingResults.MSC = MSC;
FittingResults.P = P;
FittingResults.Q = Q;
FittingResults.SSE = SSE;
FittingResults.Rsquared = Rsquared;
FittingResults.PCC = PCC;

end

