function regressCC(cellFolder, binWindow, binStep)
%regressCC calculates coefficients for each behavioral variables
warning off;

% find files
switch nargin
    case 0
        matFile = FindFiles('T*.mat','CheckSubdirs',0); 
    case 1 
        if ~iscell(cellFolder) 
            disp('Input argument is wrong. It should be cell array.');
            return;
        elseif isempty(cellFolder)
            matFile = FindFiles('T*.mat','CheckSubdirs',1);
        else
            nFolder = length(cellFolder);
            matFile = cell(0,1);
            for iFolder = 1:nFolder
                if exist(cellFolder{iFolder})==7
                    cd(cellFolder{iFolder});
                    matFile = [matFile;FindFiles('T*.mat','CheckSubdirs',1)];
                elseif strcmp(cellFolder{iFolder}(end-3:end),'.mat')
                    matFile = [matFile;cellFolder{iFolder}];
                end
            end
        end
end
if isempty(matFile)
    disp('Mat file does not exist!');
    return;
end
if nargin < 2
    binWindow = 500;
    binStep = 100;
elseif nargin==2
    binStep = binWindow;
end

rtdir = pwd;
nFile = length(matFile);

for iFile = 1:nFile
    disp(['### Analyzing ',matFile{iFile},'...']);
    [cellDir,cellName,~] = fileparts(matFile{iFile});

    cd(cellDir);
    load(matFile{iFile});
    load('Events.mat');

    [reg_time, reg_spk] = spikeBin(spikeTime, win, binWindow, binStep);
    [regRw_time, regRw_spk] = spikeBin(spikeTimeRw, winRw, binWindow, binStep);
    
    value = zeros(nTrial,1);
    for iCue = 1:4
        trialAll = 4*(iCue-1) + (1:4);
        if any(trialResult(trialAll))
            valueTemp = sum(trialResult(4*(iCue-1) + [1 2])) / sum(trialResult(trialAll));
        end
        value(cue==iCue) = valueTemp;
    end    
    
    nomod = (modulation==0);
    mod = (modulation==1);
    inRw = ~isnan(rewardLickTime);
    
    % regression (cue, reward | modulation==0)
    if any(nomod)
        reg_cr_nomod = slideReg(reg_time, reg_spk(nomod,:), [value(nomod) reward(nomod) value(nomod).*reward(nomod)]);
        regRw_cr_nomod = slideReg(regRw_time, regRw_spk(nomod & inRw,:), [value(nomod & inRw) reward(nomod & inRw) value(nomod & inRw).*reward(nomod & inRw)]);
        save(matFile{iFile}, 'reg_cr_nomod', 'regRw_cr_nomod', '-append');
    end
    
    % regression (cue, reward | modulation==1)
    % regression (cue, reward, modulation)
    if any(mod)
        reg_cr_mod = slideReg(reg_time, reg_spk(mod,:), [value(mod) reward(mod) value(mod).*reward(mod)]);
        reg_crm = slideReg(reg_time, reg_spk, [value reward modulation value.*reward value.*modulation reward.*modulation]);
        regRw_cr_mod = slideReg(regRw_time, regRw_spk(mod & inRw,:), [value(mod & inRw) reward(mod & inRw) value(mod & inRw).*reward(mod & inRw)]);
        regRw_crm = slideReg(regRw_time, regRw_spk(inRw,:), [value(inRw) reward(inRw) modulation(inRw) value(inRw).*reward(inRw) value(inRw).*modulation(inRw) reward(inRw).*modulation(inRw)]);
        save(matFile{iFile}, 'reg_cr_mod', 'reg_crm', 'regRw_cr_mod', 'regRw_crm', '-append');
    end
end
disp('### Regression analysis done!');
end
    
function reg = slideReg(time, spk, predictor)
nBin = size(time,2);
nVar = size(predictor,2);

p = zeros(nVar,nBin);
src = zeros(nVar,nBin);
sse = zeros(nVar,nBin);

predStd = zeros(nVar,nBin);
for iVar = 1:nVar
    predStd(iVar,:) = std(predictor(:,iVar)) ./ std(spk,0,1);
end

for iBin = 1:nBin
    [beta,~,stats] = glmfit(predictor, spk(:,iBin),'poisson');
    
    src(:,iBin) = beta(2:end) .* predStd(:,iBin);
    sse(:,iBin) = stats.se(2:end) .* predStd(:,iBin);
    p(:,iBin) = stats.p(2:end);
end

outRange = (abs(src) > 10);
src(outRange) = 0;
sse(outRange) = 0;
p(outRange) = 1;

timesse = [time flip(time)];
sse = [src-1.96*sse flip(src+1.96*sse,2)];

reg = struct('time',time, 'p',p, 'src',src, 'timesse',timesse, 'sse',sse);
end