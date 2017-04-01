function reg = slideReg(time, y, X, poisson)
% poission: 0 - normal / 1 - poisson
nBin = size(time,2);
nVar = size(X, 2);

[p, beta, ciDown, ciUp] = deal(zeros(nVar+1, nBin));
for iBin = 1:nBin
    if poisson==1
        mdl = fitglm(X, y(:, iBin), ...
            'Distribution', 'poisson');
    elseif poisson==0
        mdl = fitglm(X, y(:, iBin), ...
            'Distribution', 'normal');
    end
    
    beta(:, iBin) = mdl.Coefficients.Estimate;
    p(:, iBin) = mdl.Coefficients.pValue;
    ciTemp = coefCI(mdl);
    ciDown(:, iBin) = ciTemp(:, 1);
    ciUp(:, iBin) = ciTemp(:, 2);
end
timeci = [time flip(time)];
ci = [ciDown flip(ciUp,2)];

reg = struct('time',time, 'p',p, 'beta', beta, 'timeci',timeci, 'ci',ci);
end