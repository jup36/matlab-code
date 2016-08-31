function regressCC(cellFolder, binWindow, binStep)
%regressCC calculates coefficients for each behavioral variables
% warning off;
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
    modulationF = zeros(nTrial, nMod-1);
    cueF = zeros(nTrial, nMod);
    rewardF = zeros(nTrial, nMod);
    punishmentF = zeros(nTrial, nMod);
    for iMod = 1:nMod
        cueF(modulation(inRegress)==mods(iMod) & cue(inRegress)==4, iMod) = 1;
        cueF(modulation(inRegress)==mods(iMod) & cue(inRegress)==1, iMod) = -1;
        rewardF(modulation(inRegress)==mods(iMod) & cue(inRegress)==1 & reward(inRegress)==1, iMod) = 1;
        rewardF(modulation(inRegress)==mods(iMod) & cue(inRegress)==1 & reward(inRegress)==0, iMod) = -1;
        punishmentF(modulation(inRegress)==mods(iMod) & cue(inRegress)==4 & punishment(inRegress)==1, iMod) = 1;
        punishmentF(modulation(inRegress)==mods(iMod) & cue(inRegress)==4 & punishment(inRegress)==0, iMod) = -1;
        
        for jMod = 1:min([iMod nMod-1])
            if iMod == jMod
                modulationF(modulation(inRegress)==mods(iMod), jMod) = -(nMod-jMod);
            else
                modulationF(modulation(inRegress)==mods(iMod), jMod) = 1;
            end
        end
    end
    
    inRw = ~isnan(rewardLickTime);
    inRw = inRw(inRegress);
    
    predictor = [modulationF, cueF, rewardF, punishmentF];
    
    reg_crm = slideReg(reg_time, reg_spk, predictor);
    regRw_crm = slideReg(regRw_time, regRw_spk(inRw, :), predictor(inRw, :));
    save(mList{iF}, 'reg_crm', 'regRw_crm', '-append');
end
disp('### Regression analysis done!');
end
    
function reg = slideReg(time, spk, predictor)
nBin = size(time,2);
nVar = size(predictor,2);

% predStd = std(predictor) ./ repmat(std(spk,0,1), 1, nVar);

p = zeros(nVar,nBin);
src = zeros(nVar,nBin);
sse = zeros(nVar,nBin);
for iBin = 1:nBin
    mdl = fitglm(predictor, spk(:,iBin), ...
        'Distribution', 'normal');
    
%     src(:,iBin) = beta(2:end) .* predStd(:,iBin);
%     sse(:,iBin) = stats.se(2:end) .* predStd(:,iBin);
%     p(:,iBin) = stats.p(2:end);
end

outRange = (abs(src+1.96*sse) > 10);
src(outRange) = 0;
sse(outRange) = 0;
p(outRange) = 1;

timesse = [time flip(time)];
sse = [src-1.96*sse flip(src+1.96*sse,2)];

reg = struct('time',time, 'p',p, 'src',src, 'timesse',timesse, 'sse',sse, 'stats', stats);
end