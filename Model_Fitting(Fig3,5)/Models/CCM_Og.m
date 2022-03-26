%% Conjunctive Coding Model
% Original Version
% with Laplace Distribution(Order) & von Mises Distribution(Item)
% with Weight
% with Background Noise

function [L, ModelParams, EncodingMatrix, RetrievalPMF] = ...
    CCM_Og(Params, Experiment, dataSet, LF)

setsize = Experiment.setsize;
N = Experiment.N;
patternN = dataSet.patternN;

w      = abs(Params(1:setsize)); % Weight
w      = w./sum(w, 2); % Normalization
kappa  = abs(Params(setsize + 1)); % Item Precision Parameter
lambda = abs(Params(setsize + 2)); % Order Precision Parameter

eta    = abs(Params(end)); % Background Noise

ModelParams = struct;
ModelParams.w = w;
ModelParams.kappa = kappa;
ModelParams.lambda = lambda;
ModelParams.eta = eta;

%% Encoding

% Order Layer to Target Layer (Rule Learning)
Order = 1:setsize;

Order2Target = exp(- lambda.*abs(Order' - Order));
Order2Target = w.*Order2Target;

EncodingMatrix = zeros(setsize, N, patternN);
allRespTypes = dataSet.allRespTypes;
RespTypeN = size(allRespTypes, 1);
RetrievalPMF = zeros(RespTypeN, patternN);

% Target Layer to Item Layer (Hebbian Learning)
T = dataSet.targets;
N2D = 2*pi/N;
TargetDgrs = T*N2D;
ItemDgrs = (1:N)*N2D;

for pattern = 1:patternN
    
    Target2Item = exp(kappa.*(cos(ItemDgrs - TargetDgrs(pattern, :)') - 1));
    
    % Encoding Matrix
    Order2Item = Order2Target*Target2Item + eta;
    
    EncodingMatrix(:, :, pattern) = Order2Item./sum(Order2Item, 2); % Normalization
    
    %% Retrieval
    
    for RTN = 1:RespTypeN
        EM = EncodingMatrix(:, :, pattern);
        for order = 1:setsize - 1
            EM((order + 1):end, allRespTypes(RTN, order)) = 0;
        end
        EM = EM./sum(EM, 2);
        %         EM(isnan(EM)) = 0;
        RetrievalPMF(RTN, pattern) = prod(diag(EM(:, allRespTypes(RTN, :))));
    end
    
end

% Normalization
% It's unnecessary because sum(RetrievalPMF, 1) is theoretically equal to 1.
% RetrievalPMF = RetrievalPMF./sum(RetrievalPMF, 1);

%% Loss Function

if  strcmp(LF, 'Acc')
    % Accuracy
    if patternN == 1
        Acc = RetrievalPMF(ismember(allRespTypes, T, 'rows'));
    else
        Acc = diag(RetrievalPMF);
    end
    L = - sum(Acc);
    
elseif  strcmp(LF, 'MLE')
    % MLE(Maximum Likelihood Estimation)
    % The MLE is asymptotically minimizing Kullback-Leibler(KL) divergence.
    % (equivalent in the discrete case)
    p = dataSet.RespTypesPMF + eps;
    q = RetrievalPMF + eps;
    temp = - p'.*log(q');
    temp(isnan(temp) | isinf(temp)) = 0;
    ptrnL = sum(temp, 2);
    L = dataSet.proportion * ptrnL;
    
elseif  strcmp(LF, 'LSE')
    % LSE(Least Square Estimation/Quadratic Loss Function)
    % If the errors belong to a normal distribution, the least-squares
    % estimators are the maximum likelihood estimators in a linear model.
    p = dataSet.RespTypesPMF;
    q = RetrievalPMF;
    L = sum((p - q).^2, 'all');
    
elseif  strcmp(LF, 'LSEe')
    % LSE only for Errors
    p = dataSet.RespTypesPMF;
    p(logical(eye(size(p)))) = 0;
    q = RetrievalPMF;
    q(logical(eye(size(q)))) = 0;
    L = sum((p - q).^2, 'all');
    
elseif  strcmp(LF, 'EMD')
    % EMD(Earth Mover's Distance)
    % (not recommended because it's too slow)
    p = dataSet.RespTypesPMF;
    q = RetrievalPMF;
    L = sum(EMD(p', q'));
    
end

end
