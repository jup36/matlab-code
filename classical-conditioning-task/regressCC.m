function regressCC(cellFolder, binWindow, binStep)
%regressCC calculates coefficients for each behavioral variables
warning off;
tic;
rtdir = pwd;

% variables
if nargin == 0
    cellFolder = {};
end
if nargin < 2
    binWindow = 500;
    binStep = 100;
elseif nargin==2
    binStep = binWindow;
end

poisson = 0;

% load files
mList = mLoad(cellFolder);
if isempty(mList); return; end;
eList = cellfun(@(x) [fileparts(x),'\Events.mat'], mList, 'UniformOutput',false);

nF = length(mList);
for iF = 1:nF
    disp(['### Analyzing ',mList{iF},'...']);
    [cellDir,cellName,~] = fileparts(mList{iF});

    load(mList{iF});
    load(eList{iF});

    [reg_time, reg_spk] = spikeBin(spikeTime, win, binWindow, binStep);
    [regRw_time, regRw_spk] = spikeBin(spikeTimeRw, winRw, binWindow, binStep);
    
    inRegress = (cue==1 | cue==4);
    reg_spk = reg_spk(inRegress,:);
    regRw_spk = regRw_spk(inRegress,:);
    
    nTrial = sum(inRegress);
    mods = unique(modulation);
    nMod = length(mods);
    m = zeros(nTrial, nMod-1);
    [c, r, p] = deal(zeros(nTrial, nMod));
    for iMod = 1:nMod
        c(modulation(inRegress)==mods(iMod) & cue(inRegress)==4, iMod) = 1;
        c(modulation(inRegress)==mods(iMod) & cue(inRegress)==1, iMod) = -1;
        r(modulation(inRegress)==mods(iMod) & cue(inRegress)==1 & reward(inRegress)==1, iMod) = 1;
        r(modulation(inRegress)==mods(iMod) & cue(inRegress)==1 & reward(inRegress)==0, iMod) = -1;
        p(modulation(inRegress)==mods(iMod) & cue(inRegress)==4 & punishment(inRegress)==1, iMod) = 1;
        p(modulation(inRegress)==mods(iMod) & cue(inRegress)==4 & punishment(inRegress)==0, iMod) = -1;
        
        for jMod = 1:min([iMod nMod-1])
            if iMod == jMod
                m(modulation(inRegress)==mods(iMod), jMod) = -(nMod-jMod);
            else
                m(modulation(inRegress)==mods(iMod), jMod) = 1;
            end
        end
    end
    
    cm = c(:, 2:end) + repmat(c(:, 1), 1, nMod-1);
    rm = r(:, 2:end) + repmat(r(:, 1), 1, nMod-1);
    pm = p(:, 2:end) + repmat(p(:, 1), 1, nMod-1);
    
    inRw = ~isnan(rewardLickTime);
    inRw = inRw(inRegress);
    
    predictor = [m, c, r, p, cm, rm, pm];
    
    reg_crm = slideReg(reg_time, reg_spk, predictor, nMod, poisson);
    regRw_crm = slideReg(regRw_time, regRw_spk(inRw, :), predictor(inRw, :), nMod, poisson);
    save(mList{iF}, 'reg_crm', 'regRw_crm', '-append');
end
disp('### Regression analysis done!');
toc;
end
    
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
                varIndex{iMod, iType} = [varIndex{iMod, iType} varCum(jType+1)+[1 iMod+1]];
            else
                varIndex{iMod, iType} = [varIndex{iMod, iType} varCum(jType+4)+1];
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