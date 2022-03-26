function [pHAT, pCI, dataSetNameComb, BIC] = PermTest(comb, dataSetName, loadPath0, loadPath, method, precision)
% Random Permutation Test

dataSetName1 = dataSetName{comb(1)};
dataSetName2 = dataSetName{comb(2)};
dataSetNameComb = [dataSetName1(1), dataSetName2(1)];

load([loadPath0, dataSetName1,'.mat'], 'FittingResults');
ACC1    = FittingResults.Q.AllTargetOnly(1);
lambda1 = FittingResults.ModelParams.lambda;
kappa1  = FittingResults.ModelParams.kappa;
eta1    = FittingResults.ModelParams.eta;

load([loadPath0, dataSetName2,'.mat'], 'FittingResults');
ACC2    = FittingResults.Q.AllTargetOnly(1);
lambda2 = FittingResults.ModelParams.lambda;
kappa2  = FittingResults.ModelParams.kappa;
eta2    = FittingResults.ModelParams.eta;
    

delta.ACC0    = ACC1    - ACC2;
delta.lambda0 = lambda1 - lambda2;
delta.kappa0  = kappa1  - kappa2;
delta.eta0    = eta1    - eta2;

files1 = dir([loadPath, dataSetName1, '*', dataSetNameComb, '.mat']);
files2 = dir([loadPath, dataSetName2, '*', dataSetNameComb, '.mat']);
N = min([length(files1), length(files2)]);

delta.ACC    = NaN(N, 1);
delta.lambda = NaN(N, 1);
delta.kappa  = NaN(N, 1);
delta.eta    = NaN(N, 1);
BIC = NaN(N, 2);

for n = 1:N
    
    load([loadPath, files1(n).name], 'FittingResults');
    ACC1 = FittingResults.Q.AllTargetOnly(1);
    lambda1 = FittingResults.ModelParams.lambda;
    kappa1 = FittingResults.ModelParams.kappa;
    eta1 = FittingResults.ModelParams.eta;
    BIC(n, 1) = FittingResults.MSC.BIC;
    
    load([loadPath, files2(n).name], 'FittingResults');
    ACC2 = FittingResults.Q.AllTargetOnly(1);
    lambda2 = FittingResults.ModelParams.lambda;
    kappa2 = FittingResults.ModelParams.kappa;
    eta2 = FittingResults.ModelParams.eta;
    BIC(n, 2) = FittingResults.MSC.BIC;
    
    delta.ACC(n) = ACC1 - ACC2;
    delta.lambda(n) = lambda1 - lambda2;
    delta.kappa(n) = kappa1 - kappa2;
    delta.eta(n) = eta1 - eta2;
    
end

%% One-tailed
if method == 1
    if delta.ACC0 > 0
        pHAT.ACC = mean(delta.ACC > delta.ACC0);
    else
        pHAT.ACC = mean(delta.ACC < delta.ACC0);
    end
    
    if delta.lambda0 > 0
        pHAT.lambda = mean(delta.lambda > delta.lambda0);
    else
        pHAT.lambda = mean(delta.lambda < delta.lambda0);
    end
    
    if delta.kappa0 > 0
        pHAT.kappa = mean(delta.kappa > delta.kappa0);
    else
        pHAT.kappa = mean(delta.kappa < delta.kappa0);
    end
    
    if delta.eta0 > 0
        pHAT.eta = mean(delta.eta > delta.eta0);
    else
        pHAT.eta = mean(delta.eta < delta.eta0);
    end
    
end

%% Two-tailed
if method == 2
    pHAT.ACC    = mean(abs(delta.ACC)    > abs(delta.ACC0));
    pHAT.lambda = mean(abs(delta.lambda) > abs(delta.lambda0));
    pHAT.kappa  = mean(abs(delta.kappa)  > abs(delta.kappa0));
    pHAT.eta    = mean(abs(delta.eta)    > abs(delta.eta0));
end
pHAT = struct2table(pHAT);
pHAT.Properties.RowNames = {dataSetNameComb};

%% Confidence Interval of the estimated p-value.
% need to use '[~, CI] = binofit(p*N, N, precision = 0.001)' to get
% the 99.9%( = 1 - 0.001) Confidence Interval of the estimated p-value.

[~, pCI.ACC]    = binofit(pHAT.ACC.*N,    N, precision);
[~, pCI.lambda] = binofit(pHAT.lambda.*N, N, precision);
[~, pCI.kappa]  = binofit(pHAT.kappa.*N,  N, precision);
[~, pCI.eta]    = binofit(pHAT.eta.*N,    N, precision);
pCI = struct2table(pCI);
pCI.Properties.RowNames = {dataSetNameComb};

end
