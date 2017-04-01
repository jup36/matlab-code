function reg = slideReg(time, y, X, nMod, poisson)
% poission: 0 - normal / 1 - poisson
nBin = size(time,2);
nVar = 4*nMod-1;

% predictor
%   m: nMod-1, c: nMod, r: nMod, p: nMod
%   cm: nMod-1, rm: nMod-1, pm: nMod-1
varNum = [nMod-1, nMod, nMod, nMod, nMod-1, nMod-1, nMod-1];
varCum = [0 cumsum(varNum)];
varIndex = cell(nMod-1, 3);
for iMod = 1:nMod-1
    for iType = 1:3
        varIndex{iMod, iType} = 1:nMod-1;
        for jType = 1:3
            if iType~=jType
                varIndex{iMod, iType} = [varIndex{iMod, iType} varCum(jType+1)+(1:nMod)];
            else
                varIndexTemp = varCum(jType+1) + (2:nMod);
                varIndexTemp(iMod) = [];
                varIndex{iMod, iType} = [varIndex{iMod, iType} [varCum(jType+4)+iMod, varIndexTemp]];
            end
        end
    end
end

[p, beta, ciDown, ciUp, pMod] = deal(zeros(nVar+1, nBin));
pMod = zeros(3, nMod-1, nBin);
for iBin = 1:nBin
    if poisson==1
        mdl = fitglm(X(:, 1:nVar), y(:, iBin), ...
            'Distribution', 'poisson');
    elseif poisson==0
        mdl = fitglm(X(:, 1:nVar), y(:, iBin), ...
            'Distribution', 'normal');
    end

    beta(:, iBin) = mdl.Coefficients.Estimate;
    p(:, iBin) = mdl.Coefficients.pValue;
    ciTemp = coefCI(mdl);
    ciDown(:, iBin) = ciTemp(:, 1);
    ciUp(:, iBin) = ciTemp(:, 2);
    
    for iMod = 1:(nMod-1)
        for iType = 1:3 % cue / reward / punishment
            if poisson==1
                mdlReduced = fitglm(X(:, varIndex{iMod, iType}), y(:, iBin), ...
                    'Distribution', 'poisson');
                pMod(iType, iMod, iBin) = 1 - chi2cdf(mdlReduced.Deviance - mdl.Deviance, 1);
            elseif poisson==0
                mdlReduced = fitglm(X(:, varIndex{iMod, iType}), y(:, iBin), ...
                    'Distribution', 'normal');
                pMod(iType, iMod, iBin) = 1 - fcdf((mdlReduced.SSE - mdl.SSE)/(mdl.SSE / mdl.DFE), 1, mdl.DFE);
            end
        end
    end
end
timeci = [time flip(time)];
ci = [ciDown flip(ciUp,2)];

reg = struct('time',time, 'p',p, 'beta', beta, 'timeci',timeci, 'ci',ci, 'pMod', pMod);
end
